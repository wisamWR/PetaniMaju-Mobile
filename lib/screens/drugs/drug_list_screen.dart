import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/drug_model.dart';
import '../../data/services/drug_service.dart';
import '../../widgets/app_ui.dart';

Color drugCategoryColor(String kategori) {
  switch (kategori.toLowerCase()) {
    case 'fungisida':
      return Colors.orange;
    case 'insektisida':
      return Colors.red;
    case 'bakterisida':
      return Colors.purple;
    case 'akarisida':
      return Colors.brown;
    case 'organik':
      return Colors.green;
    default:
      return Colors.blueGrey;
  }
}

class DrugListScreen extends StatefulWidget {
  final String? initialQuery;
  const DrugListScreen({super.key, this.initialQuery});

  @override
  State<DrugListScreen> createState() => _DrugListScreenState();
}

class _DrugListScreenState extends State<DrugListScreen> {
  List<Drug> _all = [];
  List<String> _categories = [];
  String _query = '';
  String _category = 'Semua';
  bool _grid = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery ?? '';
    _load();
  }

  Future<void> _load() async {
    try {
      final service = DrugService();
      final drugs = await service.getDrugs();
      final cats = await service.getCategories();
      if (!mounted) return;
      setState(() {
        _all = drugs;
        _categories = ['Semua', ...cats];
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  List<Drug> get _filtered {
    final q = _query.toLowerCase();
    return _all.where((d) {
      final matchCat = _category == 'Semua' || d.kategori == _category;
      if (!matchCat) return false;
      if (q.isEmpty) return true;
      return d.nama.toLowerCase().contains(q) ||
          d.bahanAktif.toLowerCase().contains(q) ||
          d.sasaran.any((s) => s.toLowerCase().contains(q)) ||
          d.tanaman.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar('Katalog Obat', actions: [
        IconButton(
          tooltip: _grid ? 'Tampilan daftar' : 'Tampilan grid',
          icon: Icon(_grid ? Icons.view_list : Icons.grid_view),
          onPressed: () => setState(() => _grid = !_grid),
        ),
      ]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SearchField(
              hint: 'Cari obat, bahan aktif, atau hama...',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _categories
                  .map((c) => FilterChipPill(
                        label: c,
                        active: c == _category,
                        onTap: () => setState(() => _category = c),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return EmptyState(
          icon: Icons.error_outline, title: 'Gagal memuat katalog', subtitle: _error);
    }
    final items = _filtered;
    if (items.isEmpty) {
      return const EmptyState(icon: Icons.search_off, title: 'Tidak ditemukan hasil');
    }

    if (_grid) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => _buildGridCard(items[i]),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) => _buildListCard(items[i]),
    );
  }

  Widget _image(Drug d, {double? width, double? height}) {
    return CachedNetworkImage(
      imageUrl: d.gambarUrl ?? '',
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: Colors.grey[200]),
      errorWidget: (_, __, ___) => Container(
        width: width,
        height: height,
        color: drugCategoryColor(d.kategori).withValues(alpha: 0.1),
        child: Icon(Icons.medication, color: drugCategoryColor(d.kategori)),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(text,
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildListCard(Drug d) {
    final color = drugCategoryColor(d.kategori);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push('/obat/detail', extra: d),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: _image(d, width: 100, height: 100),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _badge(d.kategori, color),
                    const SizedBox(height: 4),
                    Text(d.nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(d.bahanAktif,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(Drug d) {
    final color = drugCategoryColor(d.kategori);
    return InkWell(
      onTap: () => context.push('/obat/detail', extra: d),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: _image(d, width: double.infinity, height: 110),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _badge(d.kategori, color),
                  const SizedBox(height: 6),
                  Text(d.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(d.bahanAktif,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
