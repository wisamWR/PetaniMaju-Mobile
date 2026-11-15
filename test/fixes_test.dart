import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/weather_icons.dart';
import 'package:mobile/data/models/forum_post_model.dart';
import 'package:mobile/data/services/weather_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('WeatherIcons mengikuti kode ikon OpenWeather', () {
    expect(WeatherIcons.iconFor('01d'), Icons.wb_sunny);
    expect(WeatherIcons.iconFor('01n'), Icons.nightlight_round);
    expect(WeatherIcons.iconFor('10d'), Icons.water_drop);
    expect(WeatherIcons.iconFor('11n'), Icons.thunderstorm);
    expect(WeatherIcons.iconFor('04d'), Icons.cloud);
    expect(WeatherIcons.iconFor(''), Icons.wb_cloudy_outlined);
  });

  Map<String, dynamic> post(dynamic comments) => {
        'id': 1,
        'user_id': 'u1',
        'content': 'Padi menguning',
        'likes_count': 4,
        'created_at': '2026-11-15T08:00:00Z',
        if (comments != null) 'forum_comments': comments,
      };

  test('ForumPost membaca jumlah komentar dari aggregate PostgREST', () {
    final p = ForumPost.fromJson(post([
      {'count': 7}
    ]));
    expect(p.likes, 4);
    expect(p.commentCount, 7);
  });

  test('ForumPost tanpa data komentar dianggap 0', () {
    expect(ForumPost.fromJson(post(null)).commentCount, 0);
    expect(ForumPost.fromJson(post(<dynamic>[])).commentCount, 0);
  });

  test('ForumPost toJson bisa dibaca ulang oleh fromJson', () {
    final p = ForumPost.fromJson(post([
      {'count': 2}
    ]));
    final again = ForumPost.fromJson(p.toJson());
    expect(again.likes, 4);
    expect(again.commentCount, 2);
  });

  test('Cek cuaca background tidak jalan sebelum ada lokasi tersimpan',
      () async {
    SharedPreferences.setMockInitialValues({});
    expect(await WeatherService().checkAlertsInBackground(), isFalse);
  });
}
