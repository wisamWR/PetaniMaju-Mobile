import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/hama_model.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../data/services/supabase_service.dart';

class HamaDetailScreen extends StatefulWidget {
  final Hama hama;

  const HamaDetailScreen({super.key, required this.hama});

  @override
  State<HamaDetailScreen> createState() => _HamaDetailScreenState();
}

class _HamaDetailScreenState extends State<HamaDetailScreen> {
  bool _isBookmarked = false;
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    final status =
        await _supabaseService.isItemBookmarked(widget.hama.id, 'hama');
    if (mounted) setState(() => _isBookmarked = status);
  }

  Future<void> _toggleBookmark() async {
    setState(() => _isBookmarked = !_isBookmarked);
    try {
      await _supabaseService.toggleBookmark(widget.hama.id, 'hama');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              _isBookmarked ? "Info disimpan" : "Info dihapus dari bookmark"),
          duration: const Duration(seconds: 1),
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isBookmarked = !_isBookmarked);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Gagal menyimpan")));
      }
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'penyakit':
        return Colors.orange;
      case 'gulma':
        return Colors.green;
      default: // Hama
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(widget.hama.type);
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF166534),
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 18,
                child: Icon(Icons.arrow_back, color: Colors.black, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 18,
                  child: IconButton(
                    icon: Icon(
                      _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: const Color(0xFF166534),
                      size: 20,
                    ),
                    onPressed: _toggleBookmark,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl:
                    widget.hama.imageUrl ?? widget.hama.getFallbackImage(),
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: typeColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      widget.hama.type,
                      style: GoogleFonts.inter(
                        color: typeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.hama.nama,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Ditemukan pada dataran rendah hingga tinggi",
                    style: GoogleFonts.inter(
                        color: Colors.grey[600], fontSize: 13),
                  ),
                  const Divider(height: 32),
                  _buildSectionTitle("Deskripsi"),
                  const SizedBox(height: 8),
                  Text(
                    widget.hama.deskripsi,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Penanganan & Solusi"),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF166534).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFF166534).withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified,
                                color: Color(0xFF166534), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Solusi Organik",
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF166534),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        Html(
                          data: widget.hama.penanganan,
                          style: {
                            "body": Style(
                              fontSize: FontSize(14.0),
                              lineHeight: LineHeight(1.6),
                              color: Colors.black87,
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                              fontFamily: "Inter",
                            ),
                            "p": Style(margin: Margins.only(bottom: 8)),
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}
