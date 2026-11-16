import 'dart:convert';

class ChatAction {
  final String label;

  /// `prompt:<teks>` atau nama fitur (drugs, calendar, scanner, weather).
  final String target;
  const ChatAction(this.label, this.target);

  bool get isPrompt => target.startsWith('prompt:');
  String get prompt => Uri.decodeComponent(target.substring('prompt:'.length));
}

class ProposedSchedule {
  final String title;
  final DateTime date;
  final String type;
  final String? notes;
  const ProposedSchedule(this.title, this.date, this.type, this.notes);
}

/// Hasil pemecahan jawaban bot menjadi teks + elemen interaktif.
class ParsedBotMessage {
  final String text;
  final List<ChatAction> actions;
  final List<String> drugNames;
  final List<ProposedSchedule> schedules;
  final Map<String, dynamic>? weather;

  const ParsedBotMessage({
    required this.text,
    this.actions = const [],
    this.drugNames = const [],
    this.schedules = const [],
    this.weather,
  });
}

class ChatParser {
  static const _validTypes = ['Tanam', 'Pupuk', 'Rawat', 'Panen', 'Lainnya'];

  static final _actionLink = RegExp(r'\[([^\]]+)\]\(action:([^)]+)\)');
  static final _drugsTag =
      RegExp(r'\[RECOMMENDED_DRUGS:\s*([^\]]*)\]', caseSensitive: false);
  static final _scheduleTag = RegExp(
      r'\[PROPOSE_ACTION:\s*CREATE_CALENDAR_SCHEDULE\]\s*(```(?:json)?\s*[\s\S]*?```|\{[\s\S]*\})',
      caseSensitive: false);
  static final _weatherTag = RegExp(
      r'\[WEATHER_RECOMMENDATION\]\s*(```(?:json)?\s*[\s\S]*?```|\{[\s\S]*?\})',
      caseSensitive: false);

  /// [streaming] = true selama jawaban masih mengalir; tag yang belum
  /// lengkap disembunyikan agar JSON mentah tidak tampil.
  static ParsedBotMessage parse(String raw, {bool streaming = false}) {
    var text = raw;

    Map<String, dynamic>? weather;
    final w = _weatherTag.firstMatch(text);
    if (w != null) {
      weather = _decodeJson(w.group(1)!);
      text = text.replaceRange(w.start, w.end, '');
    }

    final schedules = <ProposedSchedule>[];
    final s = _scheduleTag.firstMatch(text);
    if (s != null) {
      final json = _decodeJson(s.group(1)!);
      final list = json?['schedules'];
      if (list is List) {
        for (final item in list) {
          if (item is! Map) continue;
          final date = DateTime.tryParse(
              (item['date'] ?? item['tanggal_tanam'] ?? '').toString());
          final title = (item['title'] ?? item['nama_tanaman'] ?? '').toString();
          if (date == null || title.isEmpty) continue;
          var type = (item['type'] ?? 'Lainnya').toString();
          if (!_validTypes.contains(type)) type = 'Lainnya';
          final notes = (item['notes'] ?? item['catatan'])?.toString();
          schedules.add(ProposedSchedule(title, date, type, notes));
        }
      }
      text = text.replaceRange(s.start, s.end, '');
    }

    final drugNames = <String>[];
    for (final m in _drugsTag.allMatches(text)) {
      drugNames.addAll(m.group(1)!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty));
    }
    text = text.replaceAll(_drugsTag, '');

    final actions = <ChatAction>[];
    for (final m in _actionLink.allMatches(text)) {
      actions.add(ChatAction(m.group(1)!.trim(), m.group(2)!.trim()));
    }
    text = text.replaceAll(_actionLink, '');

    if (streaming) {
      // Sembunyikan tag yang belum selesai dikirim.
      final cut = RegExp(r'\[(PROPOSE_ACTION|WEATHER_RECOMMENDATION|RECOMMENDED_DRUGS)[\s\S]*$',
              caseSensitive: false)
          .firstMatch(text);
      if (cut != null) text = text.substring(0, cut.start);
    }

    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();

    return ParsedBotMessage(
      text: text,
      actions: actions,
      drugNames: drugNames,
      schedules: schedules,
      weather: weather,
    );
  }

  static Map<String, dynamic>? _decodeJson(String block) {
    var body = block.trim();
    if (body.startsWith('```')) {
      body = body.replaceFirst(RegExp(r'^```(?:json)?'), '');
      body = body.replaceFirst(RegExp(r'```$'), '');
    }
    body = body.trim();
    try {
      final data = jsonDecode(body);
      return data is Map ? Map<String, dynamic>.from(data) : null;
    } catch (_) {
      return null;
    }
  }
}
