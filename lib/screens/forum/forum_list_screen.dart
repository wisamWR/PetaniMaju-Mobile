import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/forum_post_model.dart';
import '../../data/services/supabase_service.dart';
import 'forum_detail_screen.dart';

class ForumListScreen extends StatefulWidget {
  const ForumListScreen({super.key});

  @override
  State<ForumListScreen> createState() => _ForumListScreenState();
}

class _ForumListScreenState extends State<ForumListScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<ForumPost>> _postsFuture;
  String _selectedCategory = "Semua";

  final List<String> _categories = [
    "Semua",
    "Pertanyaan",
    "Tips & Trik",
    "Pengalaman",
    "Diskusi Umum"
  ];

  @override
  void initState() {
    super.initState();
    _refreshPosts();
  }

  void _refreshPosts() {
    setState(() {
      _postsFuture = _supabaseService.getForumPosts(useCache: false);
    });
  }

  Future<void> _confirmDelete(int postId) async {
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
        await _supabaseService.deleteForumPost(postId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Postingan berhasil dihapus")),
          );
          _refreshPosts();
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

  Color _getCategoryColor(String? category) {
    if (category == null) return Colors.grey;
    switch (category) {
      case "Pertanyaan":
        return Colors.blue;
      case "Tips & Trik":
        return Colors.green;
      case "Pengalaman":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forum Petani")),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  selectedColor: const Color(0xFF166534),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = category);
                  },
                );
              },
            ),
          ),

          // Post List
          Expanded(
            child: FutureBuilder<List<ForumPost>>(
              future: _postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off,
                            size: 60, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          "Anda sedang offline",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800]),
                        ),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32.0),
                          child: Text(
                            "Periksa koneksi internet Anda untuk melihat forum diskusi.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshPosts,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF166534),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Coba Lagi"),
                        )
                      ],
                    ),
                  );
                }
                final allPosts = snapshot.data ?? [];

                // Filter
                final posts = _selectedCategory == "Semua"
                    ? allPosts
                    : allPosts
                        .where((p) => p.category == _selectedCategory)
                        .toList();

                if (posts.isEmpty) {
                  return const Center(child: Text("Belum ada postingan."));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: posts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return _buildPostCard(post);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/forum/create');
          _refreshPosts();
        },
        backgroundColor: const Color(0xFF166534),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildPostCard(ForumPost post) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ForumDetailScreen(post: post),
            ),
          ).then((_) => _refreshPosts()); // Refresh when returning
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    backgroundImage: post.userAvatar != null
                        ? NetworkImage(post.userAvatar!)
                        : null,
                    radius: 20,
                    child: post.userAvatar == null
                        ? Text(post.userName?.substring(0, 1) ?? "?")
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                post.userName ?? "Petani",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(post.category)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    post.category ?? "Umum",
                                    style: TextStyle(
                                        color: _getCategoryColor(post.category),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                if (_supabaseService.currentUser?.id ==
                                    post.userId)
                                  SizedBox(
                                    height: 24, // Constrain height to align
                                    width: 24,
                                    child: PopupMenuButton<String>(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.more_vert,
                                          size: 18, color: Colors.grey),
                                      onSelected: (value) {
                                        if (value == 'delete') {
                                          _confirmDelete(post.id);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'delete',
                                          height: 32,
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete,
                                                  color: Colors.red, size: 16),
                                              SizedBox(width: 8),
                                              Text("Hapus",
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 14)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${post.userLocation ?? 'Lokasi tidak diketahui'} • ${DateFormat('dd MMM, HH:mm').format(post.createdAt.toLocal())}",
                          style:
                              const TextStyle(fontSize: 11, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (post.title != null)
                Text(post.title!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              const SizedBox(height: 4),
              Text(post.content, maxLines: 3, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              if (post.imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: post.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) =>
                          const SizedBox.shrink(), // Hide if error
                    ),
                  ),
                ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.thumb_up_alt_outlined,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("${post.likes} Suka",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const Icon(Icons.comment_outlined,
                      size: 20, color: Colors.grey),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
