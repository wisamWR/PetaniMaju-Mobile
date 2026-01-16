import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../data/models/video_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/services/supabase_service.dart';

class VideoDetailScreen extends StatefulWidget {
  final Video video;
  const VideoDetailScreen({super.key, required this.video});

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  bool _isBookmarked = false;
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
    _controller = YoutubePlayerController(
      initialVideoId: widget.video.youtubeId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    )..addListener(_listener);
  }

  Future<void> _checkBookmarkStatus() async {
    final status =
        await _supabaseService.isItemBookmarked(widget.video.id, 'video');
    if (mounted) setState(() => _isBookmarked = status);
  }

  Future<void> _toggleBookmark() async {
    setState(() => _isBookmarked = !_isBookmarked);
    try {
      await _supabaseService.toggleBookmark(widget.video.id, 'video');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              _isBookmarked ? "Video disimpan" : "Video dihapus dari bookmark"),
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

  void _listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {});
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: const Color(0xFF166534),
        onReady: () {
          _isPlayerReady = true;
        },
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              "Putar Video",
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold, color: Colors.black),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            actions: [
              IconButton(
                icon: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: const Color(0xFF166534),
                ),
                onPressed: _toggleBookmark,
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video Player
                player,

                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.video.judul,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('dd MMMM yyyy', 'id_ID')
                                .format(widget.video.createdAt),
                            style: GoogleFonts.inter(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      if (widget.video.deskripsi != null) ...[
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),
                        Text(
                          "Deskripsi",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.video.deskripsi!,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            height: 1.6,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
