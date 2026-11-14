/// Satu entri di riwayat notifikasi.
class NotificationRecord {
  final int id;
  final String title;
  final String body;
  final String? payload;
  final DateTime time;
  final bool read;

  NotificationRecord({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
    required this.time,
    this.read = false,
  });

  NotificationRecord copyWith({bool? read}) => NotificationRecord(
        id: id,
        title: title,
        body: body,
        payload: payload,
        time: time,
        read: read ?? this.read,
      );

  factory NotificationRecord.fromJson(Map<String, dynamic> json) =>
      NotificationRecord(
        id: json['id'] ?? 0,
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        payload: json['payload'],
        time: DateTime.tryParse(json['time'] ?? '') ?? DateTime.now(),
        read: json['read'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'payload': payload,
        'time': time.toIso8601String(),
        'read': read,
      };
}
