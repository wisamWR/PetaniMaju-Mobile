import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/services/supabase_service.dart';
import '../../data/models/tip_model.dart';
import '../../widgets/app_ui.dart';

class TipsListScreen extends StatefulWidget {
  const TipsListScreen({super.key});

  @override
  State<TipsListScreen> createState() => _TipsListScreenState();
}

class _TipsListScreenState extends State<TipsListScreen> {
  late Future<List<Tip>> _tipsFuture;
  String _searchQuery = "";
  String _activeCategory = "Semua";

  @override
  void initState() {
    super.initState();
    _tipsFuture = SupabaseService().getTips();
  }

  Future<void> _refresh() async {
    final future = SupabaseService().getTips();
    setState(() => _tipsFuture = future);
    await future;
  }

  List<Tip> _filter(List<Tip> tips) {
    final q = _searchQuery.toLowerCase();
    return tips.where((tip) {
      final matchesSearch = tip.judul.toLowerCase().contains(q) ||
          tip.deskripsi.toLowerCase().contains(q);
      final matchesCategory =
          _activeCategory == "Semua" || tip.kategori == _activeCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar("Tips Bertani"),
      body: FutureBuilder<List<Tip>>(
        future: _tipsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return EmptyState(
              icon: Icons.wifi_off,
              title: "Gagal memuat tips",
              subtitle: "Periksa koneksi internet lalu coba lagi.",
              action: ElevatedButton(
                onPressed: _refresh,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white),
                child: const Text("Coba Lagi"),
              ),
            );
          }

          final allTips = snapshot.data ?? [];
          final categories = [
            "Semua",
            ...{for (final t in allTips) t.kategori}.where((c) => c.isNotEmpty),
          ];
          final tips = _filter(allTips);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SearchField(
                  hint: "Cari tips bertani...",
                  onChanged: (q) => setState(() => _searchQuery = q),
                ),
              ),
              const SizedBox(height: 12),
              if (categories.length > 2)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: categories
                        .map((cat) => FilterChipPill(
                              label: cat,
                              active: _activeCategory == cat,
                              onTap: () =>
                                  setState(() => _activeCategory = cat),
                            ))
                        .toList(),
                  ),
                ),
              if (categories.length > 2) const SizedBox(height: 12),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: tips.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 40),
                            EmptyState(
                              icon: Icons.lightbulb_outline,
                              title: allTips.isEmpty
                                  ? "Belum ada tips"
                                  : "Tips tidak ditemukan",
                              subtitle: allTips.isEmpty
                                  ? null
                                  : "Coba kata kunci atau kategori lain.",
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: tips.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) =>
                              _buildTipCard(tips[index]),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTipCard(Tip tip) {
    return InkWell(
      onTap: () => context.push('/tips/detail', extra: tip),
      borderRadius: BorderRadius.circular(16),
      child: InfoCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: tip.imageUrl ?? tip.getFallbackImage(),
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(height: 150, color: Colors.grey[200]),
                errorWidget: (context, url, error) => CachedNetworkImage(
                  imageUrl: tip.getFallbackImage(),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    height: 150,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (tip.kategori.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(tip.kategori,
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ),
                      const Spacer(),
                      Text(DateFormat('dd MMM yyyy').format(tip.createdAt),
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(tip.judul,
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(tip.deskripsi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700], height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
