import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/env.dart';
import '../../widgets/app_ui.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faqs = [
    (
      'Bagaimana cara scan penyakit tanaman?',
      'Buka menu Scan di beranda, ambil foto daun yang bergejala dari kamera atau galeri. '
          'Hasil diagnosa, penanganan, dan rekomendasi obat akan muncul otomatis.'
    ),
    (
      'Kenapa chat Asisten Tani dibatasi?',
      'Akun gratis mendapat 3 jawaban per hari. Upgrade ke PetaniMaju PRO untuk konsultasi tanpa batas.'
    ),
    (
      'Notifikasi tidak muncul?',
      'Pastikan notifikasi diaktifkan di Profil > Pengaturan Notifikasi dan izin notifikasi '
          'di pengaturan HP sudah diberikan. Cek juga jam Mode Tenang.'
    ),
    (
      'Apakah katalog obat butuh internet?',
      'Tidak. Katalog obat tersimpan di aplikasi sehingga bisa dibuka tanpa koneksi.'
    ),
    (
      'Bagaimana jika lupa kata sandi?',
      'Di halaman login, tekan "Lupa kata sandi?" lalu masukkan email untuk menerima tautan reset.'
    ),
  ];

  Future<void> _email(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: Env.supportEmail,
      query: 'subject=${Uri.encodeComponent('Bantuan PetaniMaju')}',
    );
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Tidak ada aplikasi email yang tersedia')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: buildAppBar('Bantuan & Dukungan'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (Env.supportEmail.isNotEmpty)
            InfoCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.green[50], shape: BoxShape.circle),
                    child: const Icon(Icons.support_agent,
                        color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Butuh bantuan?',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 2),
                        Text('Hubungi tim kami lewat email',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () => _email(context),
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    child: const Text('Email'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text('Pertanyaan Umum',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: _faqs
                  .map((f) => ExpansionTile(
                        shape: const Border(),
                        title: Text(f.$1,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14)),
                        childrenPadding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          Text(f.$2,
                              style: TextStyle(
                                  color: Colors.grey[700], height: 1.4)),
                        ],
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
