class Video {
  final int id;
  final String judul;
  final String url;
  final String? deskripsi;
  final DateTime createdAt;

  Video({
    required this.id,
    required this.judul,
    required this.url,
    this.deskripsi,
    required this.createdAt,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      // Schema: title, video_url, description
      judul: json['title'] ?? 'Video',
      url: json['video_url'] ?? '',
      deskripsi: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': judul,
      'video_url': url,
      'description': deskripsi,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get youtubeId {
    if (url.isEmpty) return '';
    try {
      // Use logic similar to YoutubePlayer.convertUrlToId for robustness
      final RegExp regExp = RegExp(
        r'^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).*',
        caseSensitive: false,
        multiLine: false,
      );
      final match = regExp.firstMatch(url);
      if (match != null && match.groupCount >= 7) {
        return match.group(7) ?? '';
      }
      return url; // Return original if not matched (might be already an ID)
    } catch (e) {
      return url;
    }
  }
}
