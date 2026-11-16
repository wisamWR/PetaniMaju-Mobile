import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/screens/chatbot/chat_bubble.dart';

Future<void> _pump(WidgetTester tester, String kondisi) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeatherRecommendationCard(data: {
            'lokasi': 'Demak',
            'suhu': '30°C',
            'kelembapan': '82%',
            'kondisi': kondisi,
            'rekomendasi_irigasi': 'Tunda penyiraman',
            'saran_pemupukan': 'Tunda pemupukan',
          }),
        ),
      ),
    );

void main() {
  testWidgets('Kartu cuaca chat menampilkan awan saat mendung',
      (tester) async {
    await _pump(tester, 'Mendung');
    expect(find.byIcon(Icons.cloud), findsOneWidget);
    expect(find.byIcon(Icons.wb_sunny), findsNothing);
    expect(find.text('Mendung • Kelembapan 82%'), findsOneWidget);
  });

  testWidgets('Kartu cuaca chat menampilkan matahari saat cerah',
      (tester) async {
    await _pump(tester, 'Cerah');
    expect(find.byIcon(Icons.wb_sunny), findsOneWidget);
  });
}
