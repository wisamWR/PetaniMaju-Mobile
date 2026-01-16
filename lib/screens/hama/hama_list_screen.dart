import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/supabase_service.dart';
import '../../data/models/hama_model.dart';

class HamaListScreen extends StatefulWidget {
  const HamaListScreen({super.key});

  @override
  State<HamaListScreen> createState() => _HamaListScreenState();
}

class _HamaListScreenState extends State<HamaListScreen> {
  late Future<List<Hama>> _hamaFuture;
  List<Hama> _allHama = [];
  List<Hama> _filteredHama = [];
  String _searchQuery = "";
  String _activeCategory = "Semua";

  @override
  void initState() {
    super.initState();
    _fetchHama();
  }

  void _fetchHama() {
    _hamaFuture = SupabaseService().getHama().then((data) {
      setState(() {
        _allHama = data;
        _applyFilter();
      });
      return data;
    });
  }

  void _applyFilter() {
    setState(() {
      _filteredHama = _allHama.where((hama) {
        final matchesSearch = hama.nama
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            hama.deskripsi.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesCategory =
            _activeCategory == "Semua" || hama.type == _activeCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _applyFilter();
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _activeCategory = category;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Hama & Penyakit",
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Cari hama atau penyakit...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Category Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ["Semua", "Hama", "Penyakit", "Gulma"].map((cat) {
                final isActive = _activeCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => _onCategoryChanged(cat),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF166534)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: isActive
                                ? const Color(0xFF166534)
                                : Colors.grey[300]!),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Content
          Expanded(
            child: FutureBuilder<List<Hama>>(
              future: _hamaFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 40, color: Colors.red),
                        const SizedBox(height: 8),
                        Text("Gagal memuat data: ${snapshot.error}"),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _fetchHama();
                            });
                          },
                          child: const Text("Coba Lagi"),
                        )
                      ],
                    ),
                  );
                }

                if (_filteredHama.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          "Tidak ditemukan hasil",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredHama.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final hama = _filteredHama[index];
                    return _buildHamaCard(hama);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'penyakit':
        return Colors.orange;
      case 'gulma':
        return Colors.green;
      case 'hama':
      default:
        return Colors.red;
    }
  }

  Widget _buildHamaCard(Hama hama) {
    final typeColor = _getTypeColor(hama.type);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          context.push('/hama/detail', extra: hama);
        },
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Image Section
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: SizedBox(
                width: 100,
                height: 100,
                child: CachedNetworkImage(
                  imageUrl: hama.imageUrl ?? hama.getFallbackImage(),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.bug_report, color: Colors.grey),
                  ),
                ),
              ),
            ),

            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: typeColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        hama.type,
                        style: TextStyle(
                            fontSize: 10,
                            color: typeColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hama.nama,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hama.deskripsi,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
