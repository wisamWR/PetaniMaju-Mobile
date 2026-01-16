import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/tip_model.dart';

import '../../data/services/supabase_service.dart';

class TipsDetailScreen extends StatefulWidget {
  final Tip tip;

  const TipsDetailScreen({super.key, required this.tip});

  @override
  State<TipsDetailScreen> createState() => _TipsDetailScreenState();
}

class _TipsDetailScreenState extends State<TipsDetailScreen> {
  bool _isBookmarked = false;
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    final status =
        await _supabaseService.isItemBookmarked(widget.tip.id, 'tip');
    if (mounted) {
      setState(() {
        _isBookmarked = status;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    try {
      await _supabaseService.toggleBookmark(widget.tip.id, 'tip');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isBookmarked
                ? "Tips disimpan ke koleksi"
                : "Tips dihapus dari koleksi"),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Revert if failed
      if (mounted) {
        setState(() {
          _isBookmarked = !_isBookmarked;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menyimpan")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                imageUrl: widget.tip.imageUrl ?? widget.tip.getFallbackImage(),
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
                      color: const Color(0xFF166534).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.tip.kategori,
                      style: const TextStyle(
                        color: Color(0xFF166534),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.tip.judul,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('dd MMMM yyyy')
                        .format(widget.tip.createdAt.toLocal()),
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const Divider(height: 32),
                  Html(
                    data: widget.tip.konten,
                    style: {
                      "body": Style(
                        fontSize: FontSize(15.0),
                        lineHeight: LineHeight(1.6),
                        color: Colors.black87,
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        fontFamily: "Inter",
                      ),
                      "p": Style(
                          margin: Margins.only(bottom: 12),
                          textAlign: TextAlign.justify),
                      "h1": Style(fontSize: FontSize(20.0)),
                      "h2": Style(fontSize: FontSize(18.0)),
                      "li": Style(
                        margin: Margins.only(bottom: 4),
                      ),
                    },
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
}
