import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/forum_post_model.dart';
import '../../data/models/forum_comment_model.dart';
import '../../data/services/supabase_service.dart';

class ForumDetailScreen extends StatefulWidget {
  final ForumPost post;

  const ForumDetailScreen({super.key, required this.post});

  @override
  State<ForumDetailScreen> createState() => _ForumDetailScreenState();
}

class _ForumDetailScreenState extends State<ForumDetailScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final TextEditingController _commentController = TextEditingController();

  List<ForumComment> _comments = [];
  bool _isLoadingComments = true;
  bool _isLiked = false;
  int _likeCount = 0;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likes;
    _checkIfLiked();
    _fetchComments();
  }

  Future<void> _checkIfLiked() async {
    final liked = await _supabaseService.hasLikedPost(widget.post.id);
    if (mounted) setState(() => _isLiked = liked);
  }

  Future<void> _fetchComments() async {
    final comments = await _supabaseService.getForumComments(widget.post.id);
    if (mounted) {
      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });
    }
  }

  bool _isLikeProcessing = false;

  Future<void> _toggleLike() async {
    if (_isLikeProcessing) return; // Prevent spam

    setState(() {
      _isLikeProcessing = true;
      // Optimistic Update
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    try {
      await _supabaseService.toggleLikePost(widget.post.id);
    } catch (e) {
      // Revert if error
      if (mounted) {
        setState(() {
          _isLiked = !_isLiked;
          _likeCount += _isLiked ? 1 : -1;
        });
      }
    } finally {
      if (mounted) setState(() => _isLikeProcessing = false);
    }
  }

  Future<void> _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isSending = true);
    try {
      await _supabaseService.addForumComment(
          widget.post.id, _commentController.text);
      _commentController.clear();
      await _fetchComments(); // Refresh list
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal mengirim komentar: $e")));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Postingan?"),
        content: const Text("Tindakan ini tidak dapat dibatalkan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabaseService.deleteForumPost(widget.post.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Postingan berhasil dihapus")),
          );
          context.pop(); // Return for list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal menghapus: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Diskusi"),
        actions: [
          if (_supabaseService.currentUser?.id == widget.post.userId)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Original Post ---
                  _buildPostHeader(),
                  const SizedBox(height: 16),
                  Text(widget.post.title ?? "",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const SizedBox(height: 8),
                  Text(widget.post.content,
                      style: const TextStyle(fontSize: 15, height: 1.5)),
                  const SizedBox(height: 16),
                  if (widget.post.imageUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: widget.post.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: const Center(
                                child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Like Button Row
                  Row(
                    children: [
                      InkWell(
                        onTap: _toggleLike,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                              color: _isLiked
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _isLiked
                                      ? Colors.green
                                      : Colors.grey[300]!)),
                          child: Row(
                            children: [
                              Icon(
                                _isLiked
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_outlined,
                                color:
                                    _isLiked ? Colors.green : Colors.grey[700],
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text("$_likeCount Suka",
                                  style: TextStyle(
                                      color: _isLiked
                                          ? Colors.green
                                          : Colors.grey[700],
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.comment_outlined,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("${_comments.length} Komentar",
                          style: const TextStyle(color: Colors.grey))
                    ],
                  ),
                  const Divider(height: 32),

                  // --- Comments Section ---
                  const Text("Komentar",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),

                  if (_isLoadingComments)
                    const Center(child: CircularProgressIndicator())
                  else if (_comments.isEmpty)
                    const Text("Belum ada komentar. Jadilah yang pertama!",
                        style: TextStyle(
                            color: Colors.grey, fontStyle: FontStyle.italic))
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _comments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: comment.userAvatar != null
                                  ? NetworkImage(comment.userAvatar!)
                                  : null,
                              child: comment.userAvatar == null
                                  ? Text(
                                      comment.userName?.substring(0, 1) ?? "?",
                                      style: const TextStyle(fontSize: 12))
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50], // Very light grey
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(comment.userName ?? "Petani",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13)),
                                        Text(
                                            DateFormat('dd MMM, HH:mm').format(
                                                comment.createdAt.toLocal()),
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(comment.content,
                                        style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    )
                ],
              ),
            ),
          ),

          // --- Input Area ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4))
            ]),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                        hintText: "Tulis komentar...",
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: Colors.grey)),
                        filled: true,
                        fillColor: Colors.grey[50]),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isSending ? null : _sendComment,
                  icon: _isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send),
                  style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF166534)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[200],
          backgroundImage: widget.post.userAvatar != null
              ? NetworkImage(widget.post.userAvatar!)
              : null,
          child: widget.post.userAvatar == null
              ? Text(widget.post.userName?.substring(0, 1) ?? "?")
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.post.userName ?? "Petani",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                "${widget.post.userLocation ?? 'Lokasi tidak diketahui'} • ${DateFormat('dd MMM yyyy, HH:mm').format(widget.post.createdAt.toLocal())}",
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
