import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/drug_model.dart';
import '../models/scan_history_model.dart';
import 'drug_service.dart';
import 'gemini_service.dart';

class ScanResult {
  final String imagePath;
  final String plantType;
  final String disease;
  final double confidence;
  final String severity;
  final String description;
  final String recommendation;
  final String prevention;
  final List<Drug> drugs;
  final bool savedToHistory;

  ScanResult({
    required this.imagePath,
    required this.plantType,
    required this.disease,
    required this.confidence,
    required this.severity,
    required this.description,
    required this.recommendation,
    required this.prevention,
    required this.drugs,
    required this.savedToHistory,
  });

  bool get isHealthy {
    final d = disease.toLowerCase();
    return d == 'sehat' || d.contains('healthy');
  }
}

class NotAPlantException implements Exception {
  final String reason;
  NotAPlantException(this.reason);
  @override
  String toString() => reason;
}

/// Scanner penyakit tanaman + riwayat hasil scan (Supabase `prediction_history`).
class ScanService {
  static final ScanService _instance = ScanService._internal();
  factory ScanService() => _instance;
  ScanService._internal();

  static const String _bucket = 'scan_images';
  static const String _table = 'prediction_history';
  static const String _cacheKey = 'cached_scan_history';

  final GeminiService _gemini = GeminiService();
  SupabaseClient get _client => Supabase.instance.client;

  Future<ScanResult> analyze(String imagePath,
      {void Function(String message)? onProgress}) async {
    onProgress?.call('Menganalisis gambar daun tanaman...');
    final data = await _gemini.analyzePlantImage(File(imagePath));

    if (data['is_plant'] != true) {
      throw NotAPlantException((data['reason'] ?? '').toString().isNotEmpty
          ? 'Gambar tidak terdeteksi sebagai tanaman: ${data['reason']}'
          : 'Gambar tidak terdeteksi sebagai tanaman. Foto ulang daun dengan jelas.');
    }

    final plantType = (data['plant_type'] ?? 'Tanaman').toString();
    final disease = (data['disease_name'] ?? 'Sehat').toString();
    final confidence = (data['confidence'] is num)
        ? (data['confidence'] as num).toDouble().clamp(0.0, 1.0)
        : 0.8;

    onProgress?.call('Mencari rekomendasi obat...');
    final drugs =
        await DrugService().recommend(plantType: plantType, disease: disease);

    final record = {
      'plant_type': plantType,
      'disease': disease,
      'confidence': confidence,
      'severity': (data['severity'] ?? '-').toString(),
      'description': (data['description'] ?? '').toString(),
      'recommendation': (data['recommendation'] ?? '').toString(),
      'prevention': (data['prevention'] ?? '').toString(),
    };

    onProgress?.call('Menyimpan ke riwayat...');
    final saved = await _saveHistory(imagePath, record);

    return ScanResult(
      imagePath: imagePath,
      plantType: plantType,
      disease: disease,
      confidence: confidence,
      severity: record['severity'] as String,
      description: record['description'] as String,
      recommendation: record['recommendation'] as String,
      prevention: record['prevention'] as String,
      drugs: drugs,
      savedToHistory: saved,
    );
  }

  Future<String?> _uploadImage(String imagePath) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final ext = imagePath.split('.').last.toLowerCase();
    final path = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _client.storage.from(_bucket).upload(path, File(imagePath));
    return _client.storage.from(_bucket).getPublicUrl(path);
  }

  Future<bool> _saveHistory(String imagePath, Map<String, dynamic> record) async {
    final user = _client.auth.currentUser;
    if (user == null) return false;
    try {
      String? imageUrl;
      try {
        imageUrl = await _uploadImage(imagePath);
      } catch (e) {
        debugPrint('ScanService: upload gagal (lanjut tanpa gambar): $e');
      }
      await _client.from(_table).insert({
        'user_id': user.id,
        'image_url': imageUrl,
        ...record,
      });
      return true;
    } catch (e) {
      debugPrint('ScanService: gagal simpan riwayat: $e');
      return false;
    }
  }

  /// Ambil riwayat dari Supabase, fallback ke cache lokal saat offline.
  Future<List<ScanHistory>> getHistory() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${_cacheKey}_${user.id}', jsonEncode(data));
      return (data as List)
          .map((e) => ScanHistory.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      debugPrint('ScanService: load history error, pakai cache: $e');
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('${_cacheKey}_${user.id}');
      if (cached == null) rethrow;
      return (jsonDecode(cached) as List)
          .map((e) => ScanHistory.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
  }

  Future<void> deleteHistory(ScanHistory item) async {
    await _client.from(_table).delete().eq('id', item.id);
    await _removeImage(item.imageUrl);
  }

  Future<void> clearHistory() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    final items = await getHistory();
    await _client.from(_table).delete().eq('user_id', user.id);
    for (final item in items) {
      await _removeImage(item.imageUrl);
    }
  }

  Future<void> _removeImage(String? url) async {
    if (url == null) return;
    const marker = '/$_bucket/';
    final idx = url.indexOf(marker);
    if (idx == -1) return;
    try {
      await _client.storage.from(_bucket).remove([url.substring(idx + marker.length)]);
    } catch (e) {
      debugPrint('ScanService: gagal hapus gambar: $e');
    }
  }
}
