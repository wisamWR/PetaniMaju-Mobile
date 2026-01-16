class CalendarEvent {
  final int id;
  final String userId;
  final String title;
  final DateTime date;
  final String type; // 'Tanam', 'Pupuk', 'Rawat', 'Panen'
  final String? notes;
  final bool completed;
  final DateTime createdAt;

  CalendarEvent({
    required this.id,
    required this.userId,
    required this.title,
    required this.date,
    required this.type,
    this.notes,
    required this.completed,
    required this.createdAt,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate = DateTime.parse(json['date']);
    String? notesObj = json['notes'];

    // Check for Time Tag in Notes to fix 00:00 issue
    if (notesObj != null) {
      final timeRegex = RegExp(r'\[TIME:(\d{2}):(\d{2})\]');
      final match = timeRegex.firstMatch(notesObj);
      if (match != null) {
        final hour = int.parse(match.group(1)!);
        final minute = int.parse(match.group(2)!);
        parsedDate = DateTime(
            parsedDate.year, parsedDate.month, parsedDate.day, hour, minute);
        // Clean notes display - remove the tag
        notesObj = notesObj.replaceAll(timeRegex, '').trim();
        if (notesObj.isEmpty) notesObj = null;
      }
    }

    return CalendarEvent(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      date: parsedDate,
      type: json['type'],
      notes: notesObj,
      completed: json['completed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'date': date.toIso8601String(),
      'type': type,
      'notes': notes,
      'completed': completed,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
