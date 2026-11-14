import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/models/scan_history_model.dart';
import '../../data/services/scan_service.dart';
import '../../widgets/app_ui.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  final _service = ScanService();
  late Future<List<ScanHistory>> _future;
  String _filter = 'Semua';

  @override
  void initState() {
    super.initState();
    _future = _service.getHistory();
  }

  Future<void> _refresh() async {
    setState(() => _future = _service.getHistory());
    await _future;
  }

  Future<void> _delete(ScanHistory item, List<ScanHistory> source) async {
    setState(() => source.remove(item));
    try {
      await _service.deleteHistory(item);
    } catch (e) {
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _clearAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Semua Riwayat?'),
        content: const Text('Seluruh hasil scan dan fotonya akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _service.clearHistory();
      _refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar('Riwayat Scan', actions: [
        IconButton(
          tooltip: 'Hapus semua',
          icon: const Icon(Icons.delete_sweep_outlined),
          onPressed: _clearAll,
        ),
      ]),
      body: FutureBuilder<List<ScanHistory>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return EmptyState(
              icon: Icons.cloud_off,
              title: 'Gagal memuat riwayat',
              subtitle: '${snapshot.error}',
              action: TextButton(onPressed: _refresh, child: const Text('Coba Lagi')),
            );
          }
          final all = snapshot.data ?? [];
          if (all.isEmpty) {
            return EmptyState(
              icon: Icons.document_scanner_outlined,
              title: 'Belum ada riwayat scan',
              subtitle: 'Hasil deteksi penyakit tanaman akan tersimpan di sini.',
              action: FilledButton.icon(
                onPressed: () => context.push('/scan'),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Mulai Scan'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            );
          }

          final items = all.where((e) {
            if (_filter == 'Sehat') return e.isHealthy;
            if (_filter == 'Sakit') return !e.isHealthy;
            return true;
          }).toList();

          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: ['Semua', 'Sakit', 'Sehat']
                      .map((f) => FilterChipPill(
                          label: f,
                          active: f == _filter,
                          onTap: () => setState(() => _filter = f)))
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _buildItem(items[i], all),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItem(ScanHistory item, List<ScanHistory> source) {
    final color = item.isHealthy ? Colors.green : Colors.orange;
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
            color: Colors.red, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _delete(item, source),
      child: InkWell(
        onTap: () => context.push('/scan/history/detail', extra: item),
        borderRadius: BorderRadius.circular(16),
        child: InfoCard(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl ?? '',
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: 70,
                    height: 70,
                    color: color.withValues(alpha: 0.1),
                    child: Icon(Icons.eco, color: color),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.isHealthy ? 'Sehat' : item.disease,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(item.plantType,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text(
                        DateFormat('dd MMM yyyy, HH:mm', 'id_ID')
                            .format(item.createdAt.toLocal()),
                        style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ),
              Column(
                children: [
                  Text('${(item.confidence * 100).toStringAsFixed(0)}%',
                      style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
