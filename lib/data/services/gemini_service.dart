import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/env.dart';

/// Pembungkus REST API Google Gemini untuk:
/// - analisis foto tanaman (scanner penyakit)
/// - percakapan streaming (Asisten Tani)
class GeminiService {
  static const String _apiBase =
      'https://generativelanguage.googleapis.com/v1beta';

  void _ensureKey() {
    if (!Env.hasGeminiKey) {
      throw Exception(
          'GEMINI_API_KEY belum diatur. Jalankan aplikasi dengan --dart-define=GEMINI_API_KEY=...');
    }
  }

  static String mimeTypeOf(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    if (lower.endsWith('.heif')) return 'image/heif';
    return 'image/jpeg';
  }

  // ─── Scanner ─────────────────────────────────────────────────────────────

  static const String _scanPrompt = '''
Kamu adalah pakar penyakit tanaman (Plant Pathology) untuk petani Indonesia.
Analisis foto yang diunggah.

1. Jika gambar BUKAN tanaman/daun/hasil pertanian (selfie, kendaraan, gedung, hewan, dokumen, dll), set "is_plant": false dan beri alasan singkat.
2. Jika tanaman:
   - "is_plant": true
   - Identifikasi jenis tanaman (Padi, Jagung, Cabai, Tomat, Teh, Bawang, dll).
   - Diagnosa: "Sehat" atau nama penyakit/hama spesifik (sertakan nama lokal Indonesia).
   - "confidence" 0.0 - 1.0.
   - "severity": "Ringan" | "Sedang" | "Berat" (isi "-" jika sehat).
   - Deskripsi gejala singkat, tindakan penanganan, dan pencegahan.

Keluarkan HANYA JSON murni (tanpa markdown):
{
  "is_plant": true,
  "reason": "",
  "plant_type": "Nama Tanaman",
  "disease_name": "Nama Penyakit atau Sehat",
  "confidence": 0.9,
  "severity": "Sedang",
  "description": "Gejala",
  "recommendation": "Penanganan",
  "prevention": "Pencegahan"
}
''';

  Future<Map<String, dynamic>> analyzePlantImage(File image) async {
    _ensureKey();
    final bytes = await image.readAsBytes();
    final payload = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': _scanPrompt},
            {
              'inline_data': {
                'mime_type': mimeTypeOf(image.path),
                'data': base64Encode(bytes),
              }
            }
          ]
        }
      ],
      'generationConfig': {'responseMimeType': 'application/json'},
    });

    Object? lastError;
    for (final model in Env.geminiModels) {
      try {
        final res = await http
            .post(
              Uri.parse('$_apiBase/models/$model:generateContent'),
              headers: {
                'Content-Type': 'application/json',
                'x-goog-api-key': Env.geminiApiKey,
              },
              body: payload,
            )
            .timeout(const Duration(seconds: 45));

        if (res.statusCode != 200) {
          lastError = 'Gemini ($model) status ${res.statusCode}';
          debugPrint('GeminiService: $lastError ${res.body}');
          continue;
        }

        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final text = _extractText(data);
        if (text.isEmpty) {
          lastError = 'Respons kosong dari $model';
          continue;
        }
        return jsonDecode(_stripCodeFence(text)) as Map<String, dynamic>;
      } on TimeoutException {
        lastError = 'Koneksi timeout';
      } on SocketException {
        throw Exception('Tidak ada koneksi internet.');
      } catch (e) {
        lastError = e;
        debugPrint('GeminiService: error on $model: $e');
      }
    }
    throw Exception('Gagal menganalisis gambar: ${lastError ?? 'server sibuk'}');
  }

  // ─── Chat (streaming) ────────────────────────────────────────────────────

  /// [history] berisi daftar `{'role': 'user'|'model', 'parts': [...]}`.
  Stream<String> streamChat({
    required String systemPrompt,
    required List<Map<String, dynamic>> history,
  }) async* {
    _ensureKey();
    final body = json.encode({
      'systemInstruction': {
        'parts': [
          {'text': systemPrompt}
        ]
      },
      'contents': history,
    });

    Object? lastError;
    for (final model in Env.geminiModels) {
      final client = http.Client();
      var produced = false;
      try {
        final request = http.Request(
            'POST', Uri.parse('$_apiBase/models/$model:streamGenerateContent?alt=sse'))
          ..headers['Content-Type'] = 'application/json'
          ..headers['x-goog-api-key'] = Env.geminiApiKey
          ..body = body;

        final response =
            await client.send(request).timeout(const Duration(seconds: 30));

        if (response.statusCode != 200) {
          lastError =
              'Gemini ($model) ${response.statusCode}: ${await response.stream.bytesToString()}';
          debugPrint('GeminiService: $lastError');
          continue;
        }

        await for (final line in response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())) {
          if (!line.startsWith('data: ')) continue;
          final data = line.substring(6).trim();
          if (data.isEmpty || data == '[DONE]') continue;
          try {
            final text = _extractText(json.decode(data) as Map<String, dynamic>);
            if (text.isNotEmpty) {
              produced = true;
              yield text;
            }
          } catch (e) {
            debugPrint('GeminiService: SSE parse error: $e');
          }
        }
        if (produced) return;
      } on SocketException {
        throw Exception('Tidak ada koneksi internet.');
      } catch (e) {
        if (produced) rethrow;
        lastError = e;
        debugPrint('GeminiService: stream error on $model: $e');
      } finally {
        client.close();
      }
    }
    throw Exception(lastError ?? 'Server Gemini sedang sibuk, coba lagi nanti.');
  }

  String _extractText(Map<String, dynamic> data) {
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) return '';
    final parts = candidates[0]['content']?['parts'] as List?;
    if (parts == null) return '';
    return parts.map((p) => (p as Map)['text'] ?? '').join();
  }

  String _stripCodeFence(String raw) {
    var text = raw.trim();
    if (text.startsWith('```json')) {
      text = text.substring(7);
    } else if (text.startsWith('```')) {
      text = text.substring(3);
    }
    if (text.endsWith('```')) text = text.substring(0, text.length - 3);
    return text.trim();
  }
}
