class ForumComment {
  final int id;
  final int postId;
  final String userId;
  final String content;
  final DateTime createdAt;

  // Joined profile data
  final String? userName;
  final String? userAvatar;

  ForumComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.userName,
    this.userAvatar,
  });

  factory ForumComment.fromJson(Map<String, dynamic> json) {
    String? name;
    String? avatar;

    // Handle joined profile data
    if (json['profiles'] != null) {
      name = json['profiles']['nama'];
      avatar = json['profiles']['avatar_url'];
    }

    return ForumComment(
      id: json['id'],
      postId: json['post_id'],
      userId: json['user_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      userName: name ?? "Petani",
      userAvatar: avatar,
    );
  }
}
