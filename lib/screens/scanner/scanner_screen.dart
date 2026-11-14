import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/env.dart';
import '../../data/services/scan_service.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/drug_mini_card.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _picker = ImagePicker();
  String? _imagePath;
  String? _loadingMessage;
  String? _error;
  ScanResult? _result;

  Future<void> _scan(ImageSource source) async {
    if (!Env.hasGeminiKey) {
      setState(() => _error =
          'Fitur scanner belum aktif. Jalankan aplikasi dengan --dart-define=GEMINI_API_KEY=...');
      return;
    }
    final XFile? picked;
    try {
      picked = await _picker.pickImage(
          source: source, imageQuality: 60, maxWidth: 1080, maxHeight: 1080);
    } catch (e) {
      setState(() => _error = 'Gagal mengambil gambar: $e');
      return;
    }
    if (picked == null) return;

    setState(() {
      _imagePath = picked!.path;
      _result = null;
      _error = null;
      _loadingMessage = 'Menyiapkan gambar...';
    });

    try {
      final result = await ScanService().analyze(
        picked.path,
        onProgress: (m) {
          if (mounted) setState(() => _loadingMessage = m);
        },
      );
      if (mounted) setState(() => _result = result);
    } on NotAPlantException catch (e) {
      if (mounted) setState(() => _error = e.reason);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loadingMessage = null);
    }
  }

  void _reset() => setState(() {
        _imagePath = null;
        _result = null;
        _error = null;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: buildAppBar('Scan Tanaman', actions: [
        IconButton(
          tooltip: 'Riwayat Scan',
          icon: const Icon(Icons.history),
          onPressed: () => context.push('/scan/history'),
        ),
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImageArea(),
            const SizedBox(height: 20),
            if (_loadingMessage != null) _buildLoading(),
            if (_error != null) _buildError(),
            if (_result != null) _buildResult(_result!),
            if (_loadingMessage == null) ...[
              const SizedBox(height: 8),
              _buildActions(),
            ],
            if (_imagePath == null && _loadingMessage == null) ...[
              const SizedBox(height: 24),
              _buildTips(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageArea() {
    if (_imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.file(File(_imagePath!), height: 260, fit: BoxFit.cover),
      );
    }
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryLight, AppColors.accentBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.document_scanner, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text('Deteksi Penyakit Tanaman',
              style: GoogleFonts.plusJakartaSans(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Foto daun yang bergejala, AI akan mendiagnosa',
              style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return InfoCard(
      child: Row(
        children: [
          const SizedBox(
              width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3)),
          const SizedBox(width: 16),
          Expanded(child: Text(_loadingMessage!)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
              child: Text(_error!, style: TextStyle(color: Colors.red[900]))),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final hasImage = _imagePath != null;
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _scan(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: Text(hasImage ? 'Foto Ulang' : 'Kamera'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _scan(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Galeri'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        if (hasImage) ...[
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Bersihkan',
            onPressed: _reset,
            icon: const Icon(Icons.close),
          ),
        ],
      ],
    );
  }

  Widget _buildTips() {
    const tips = [
      'Foto satu daun yang bergejala dengan jelas dan fokus.',
      'Gunakan cahaya alami, hindari bayangan & silau.',
      'Isi sebagian besar frame dengan daun tanaman.',
    ];
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.lightbulb_outline, color: Colors.amber),
            SizedBox(width: 8),
            Text('Tips foto terbaik', style: TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          ...tips.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(t,
                            style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildResult(ScanResult r) {
    final color = r.isHealthy ? Colors.green : Colors.orange;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScanResultHeader(
          plantType: r.plantType,
          disease: r.disease,
          confidence: r.confidence,
          severity: r.severity,
          healthy: r.isHealthy,
        ),
        const SizedBox(height: 16),
        DetailSection(
            icon: Icons.info_outline, title: 'Gejala', content: r.description, color: color),
        DetailSection(
            icon: Icons.healing, title: 'Penanganan', content: r.recommendation),
        DetailSection(
            icon: Icons.shield_outlined,
            title: 'Pencegahan',
            content: r.prevention,
            color: AppColors.accentBlue),
        if (r.drugs.isNotEmpty) ...[
          Text('Rekomendasi Obat',
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          DrugMiniList(drugs: r.drugs),
          const SizedBox(height: 16),
        ],
        OutlinedButton.icon(
          onPressed: () => context.push('/asisten',
              extra: 'Tanaman ${r.plantType} saya terdeteksi ${r.disease}. '
                  'Apa langkah penanganan terbaik yang bisa saya lakukan?'),
          icon: const Icon(Icons.support_agent),
          label: const Text('Tanya Asisten Tani'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          r.savedToHistory
              ? 'Hasil tersimpan di Riwayat Scan.'
              : 'Hasil belum tersimpan ke riwayat (cek koneksi/database).',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// Kartu ringkasan hasil diagnosa (dipakai di hasil scan & detail riwayat).
class ScanResultHeader extends StatelessWidget {
  final String plantType;
  final String disease;
  final double confidence;
  final String severity;
  final bool healthy;

  const ScanResultHeader({
    super.key,
    required this.plantType,
    required this.disease,
    required this.confidence,
    required this.severity,
    required this.healthy,
  });

  @override
  Widget build(BuildContext context) {
    final color = healthy ? Colors.green : Colors.orange;
    return InfoCard(
      borderColor: color.withOpacity(0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(healthy ? Icons.eco : Icons.coronavirus, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plantType,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    Text(healthy ? 'Tanaman Sehat' : disease,
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold, fontSize: 17)),
                  ],
                ),
              ),
              if (!healthy && severity != '-')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _severityColor(severity).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(severity,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _severityColor(severity))),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tingkat keyakinan',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text('${(confidence * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: confidence,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static Color _severityColor(String s) {
    switch (s.toLowerCase()) {
      case 'berat':
        return Colors.red;
      case 'sedang':
        return Colors.orange;
      default:
        return Colors.amber[800]!;
    }
  }
}
