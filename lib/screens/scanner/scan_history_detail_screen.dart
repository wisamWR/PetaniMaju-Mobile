import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/models/drug_model.dart';
import '../../data/models/scan_history_model.dart';
import '../../data/services/drug_service.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/drug_mini_card.dart';
import 'scanner_screen.dart';

class ScanHistoryDetailScreen extends StatefulWidget {
  final ScanHistory item;
  const ScanHistoryDetailScreen({super.key, required this.item});

  @override
  State<ScanHistoryDetailScreen> createState() => _ScanHistoryDetailScreenState();
}

class _ScanHistoryDetailScreenState extends State<ScanHistoryDetailScreen> {
  late Future<List<Drug>> _drugs;

  @override
  void initState() {
    super.initState();
    _drugs = DrugService()
        .recommend(plantType: widget.item.plantType, disease: widget.item.disease);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
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
                imageUrl: item.imageUrl ?? '',
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  color: Colors.green[50],
                  child: const Icon(Icons.eco, size: 80, color: Colors.green),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Discan ${DateFormat('EEEE, dd MMMM yyyy • HH:mm', 'id_ID').format(item.createdAt.toLocal())}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  ScanResultHeader(
                    plantType: item.plantType,
                    disease: item.disease,
                    confidence: item.confidence,
                    severity: item.severity,
                    healthy: item.isHealthy,
                  ),
                  const SizedBox(height: 16),
                  DetailSection(
                      icon: Icons.info_outline,
                      title: 'Gejala',
                      content: item.description ?? '',
                      color: Colors.orange),
                  DetailSection(
                      icon: Icons.healing,
                      title: 'Penanganan',
                      content: item.recommendation ?? ''),
                  DetailSection(
                      icon: Icons.shield_outlined,
                      title: 'Pencegahan',
                      content: item.prevention ?? '',
                      color: AppColors.accentBlue),
                  FutureBuilder<List<Drug>>(
                    future: _drugs,
                    builder: (_, snap) {
                      final drugs = snap.data ?? [];
                      if (drugs.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rekomendasi Obat',
                              style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          DrugMiniList(drugs: drugs),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/asisten',
                        extra: 'Tanaman ${item.plantType} saya terdeteksi ${item.disease}. '
                            'Bagaimana cara menanganinya?'),
                    icon: const Icon(Icons.support_agent),
                    label: const Text('Tanya Asisten Tani'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
}
