import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/farming_advice.dart';
import 'package:mobile/data/models/drug_model.dart';
import 'package:mobile/data/models/notification_settings.dart';
import 'package:mobile/screens/chatbot/chat_parser.dart';

void main() {
  group('ChatParser', () {
    test('memisahkan tombol aksi, obat, jadwal, dan kartu cuaca', () {
      const raw = '''
Pupuk **Urea** sebaiknya pagi hari.
[RECOMMENDED_DRUGS: Dithane M-45, Score 250 EC]
[PROPOSE_ACTION: CREATE_CALENDAR_SCHEDULE]
```json
{"schedules":[{"title":"Pupuk Cabai","date":"2026-09-20T07:00:00","type":"Pupuk","notes":"2 g/l"},{"title":"Semprot","date":"2026-09-27T07:00:00","type":"Aneh"}]}
```
[WEATHER_RECOMMENDATION]
```json
{"lokasi":"Semarang","suhu":"30°C"}
```
[💊 Buka Katalog](action:drugs)
[Tanya lagi](action:prompt:Bagaimana%20dosisnya%3F)
''';
      final p = ChatParser.parse(raw);

      expect(p.text, 'Pupuk **Urea** sebaiknya pagi hari.');
      expect(p.drugNames, ['Dithane M-45', 'Score 250 EC']);
      expect(p.schedules, hasLength(2));
      expect(p.schedules.first.title, 'Pupuk Cabai');
      expect(p.schedules.first.date, DateTime(2026, 9, 20, 7));
      expect(p.schedules.last.type, 'Lainnya'); // tipe tak valid dinormalisasi
      expect(p.weather?['lokasi'], 'Semarang');
      expect(p.actions.map((a) => a.target), ['drugs', 'prompt:Bagaimana%20dosisnya%3F']);
      expect(p.actions.last.prompt, 'Bagaimana dosisnya?');
    });

    test('menyembunyikan tag yang belum lengkap saat streaming', () {
      final p = ChatParser.parse('Jawaban awal\n[PROPOSE_ACTION: CREATE_CAL',
          streaming: true);
      expect(p.text, 'Jawaban awal');
      expect(p.schedules, isEmpty);
    });
  });

  group('NotificationSettings', () {
    test('mode tenang lintas tengah malam', () {
      const s = NotificationSettings(quietStartHour: 22, quietEndHour: 5);
      expect(s.isQuietAt(DateTime(2026, 1, 1, 23)), isTrue);
      expect(s.isQuietAt(DateTime(2026, 1, 1, 3)), isTrue);
      expect(s.isQuietAt(DateTime(2026, 1, 1, 5)), isFalse);
      expect(s.isQuietAt(DateTime(2026, 1, 1, 12)), isFalse);
    });

    test('mode tenang nonaktif tidak pernah menahan notifikasi', () {
      const s = NotificationSettings(quietModeEnabled: false);
      expect(s.isQuietAt(DateTime(2026, 1, 1, 23)), isFalse);
    });

    test('filter jenis peringatan cuaca', () {
      const s = NotificationSettings(heavyRainAlertEnabled: false);
      expect(s.allowsWeatherAlert('Potensi Hujan Lebat'), isFalse);
      expect(s.allowsWeatherAlert('Angin Kencang'), isTrue);
    });

    test('toJson/fromJson bolak-balik', () {
      const s = NotificationSettings(morningBriefingHour: 7, quietEndHour: 6);
      final back = NotificationSettings.fromJson(s.toJson());
      expect(back.morningBriefingHour, 7);
      expect(back.quietEndHour, 6);
    });
  });

  test('FarmingAdvice memprioritaskan suhu tinggi & hujan', () {
    expect(
      FarmingAdvice.plantCare(
              temperature: 35, humidity: 50, windSpeed: 1, iconCode: '01d', description: 'cerah')
          .title,
      'Suhu Tinggi Terdeteksi',
    );
    expect(
      FarmingAdvice.plantCare(
              temperature: 27, humidity: 80, windSpeed: 1, iconCode: '10d', description: 'hujan ringan')
          .isUrgent,
      isTrue,
    );
    for (var m = 1; m <= 12; m++) {
      expect(FarmingAdvice.forMonth(m).items, isNotEmpty);
    }
  });

  test('Drug.fromJson menerima tanaman berupa list atau string', () {
    final d = Drug.fromJson({
      'id': 'X',
      'nama_obat': 'Obat',
      'tanaman': 'Padi',
      'sasaran': ['Wereng'],
    });
    expect(d.tanaman, ['Padi']);
    expect(d.sasaran, ['Wereng']);
  });
}
