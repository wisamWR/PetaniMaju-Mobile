class ForumPost {
  final int id;
  final String userId;
  final String? title;
  final String content;
  final String? category;
  final String? imageUrl;
  final int likes;
  final int commentCount;
  final DateTime createdAt;

  // Joined fields
  final String? userName;
  final String? userAvatar;
  final String? userLocation;

  ForumPost({
    required this.id,
    required this.userId,
    this.title,
    required this.content,
    this.category,
    this.imageUrl,
    this.likes = 0,
    this.commentCount = 0,
    required this.createdAt,
    this.userName,
    this.userAvatar,
    this.userLocation,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    // Handle joined profile data if available
    String? name;
    String? avatar;
    String? location;

    if (json['profiles'] != null) {
      name = json['profiles']['nama'];
      avatar = json['profiles']['avatar_url'];
      final p = json['profiles'];
      location = p['kecamatan'] ?? p['kabupaten'] ?? p['provinsi'] ?? p['kota'];
    } else if (json['profiles!forum_posts_user_id_fkey'] != null) {
      // Handle explicit FK reference
      final p = json['profiles!forum_posts_user_id_fkey'];
      name = p['nama'];
      avatar = p['avatar_url'];
      location = p['kecamatan'] ?? p['kabupaten'] ?? p['provinsi'] ?? p['kota'];
    }

    return ForumPost(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      imageUrl: json['image_url'],
      likes: json['likes_count'] ?? 0, // Fixed: DB uses likes_count
      commentCount: _parseCount(json['forum_comments'] ?? json['comment_count']),
      createdAt: DateTime.parse(json['created_at']),
      userName: name ?? 'Petani',
      userAvatar: avatar,
      userLocation: location,
    );
  }

  // PostgREST aggregate `forum_comments(count)` -> [{"count": n}]
  static int _parseCount(dynamic raw) {
    if (raw is int) return raw;
    if (raw is List && raw.isNotEmpty && raw.first is Map) {
      return (raw.first['count'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'category': category,
      'image_url': imageUrl,
      'likes_count': likes,
      'comment_count': commentCount,
      'created_at': createdAt.toIso8601String(),
      'profiles': {
        'nama': userName,
        'avatar_url': userAvatar,
        'kota': userLocation
      }
    };
  }
}
