import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/drug_model.dart';
import '../../widgets/app_ui.dart';
import 'drug_list_screen.dart';

class DrugDetailScreen extends StatelessWidget {
  final Drug drug;
  const DrugDetailScreen({super.key, required this.drug});

  Future<void> _openBuyLink(BuildContext context) async {
    final link = drug.linkPembelian;
    if (link == null || link.isEmpty) return;
    final ok = await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka tautan pembelian')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = drugCategoryColor(drug.kategori);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 18,
                child: Icon(Icons.arrow_back, color: Colors.black, size: 20),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: drug.gambarUrl ?? '',
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  color: color.withValues(alpha: 0.15),
                  child: Icon(Icons.medication, size: 80, color: color),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Text(drug.kategori,
                        style: TextStyle(
                            color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const SizedBox(height: 8),
                  Text(drug.nama,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(drug.produsen, style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _stat(Icons.science, 'Bahan Aktif', drug.bahanAktif)),
                      const SizedBox(width: 12),
                      Expanded(child: _stat(Icons.opacity, 'Dosis', drug.dosis)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DetailSection(
                      icon: Icons.description, title: 'Deskripsi', content: drug.deskripsi),
                  _chipsSection(Icons.grass, 'Tanaman', drug.tanaman, Colors.green),
                  _chipsSection(Icons.bug_report, 'Sasaran Hama/Penyakit',
                      drug.sasaran, Colors.red),
                  DetailSection(
                      icon: Icons.checklist, title: 'Cara Pakai', content: drug.caraPakai),
                  DetailSection(
                    icon: Icons.warning_amber,
                    title: 'Peringatan',
                    content: drug.peringatan,
                    color: Colors.orange,
                  ),
                  if (drug.linkPembelian != null && drug.linkPembelian!.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _openBuyLink(context),
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('Cari di Toko Online'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String label, String value) {
    return InfoCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ]),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _chipsSection(IconData icon, String title, List<String> items, Color color) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InfoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(title,
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ]),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items
                  .map((t) => Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(t,
                            style: TextStyle(fontSize: 12, color: Colors.grey[800])),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
