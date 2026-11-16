import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/app_ui.dart';

Widget _host(Widget child, {bool reduceMotion = false}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Scaffold(body: child),
      ),
    );

void main() {
  testWidgets('SkeletonList menampilkan kerangka dengan efek kilau',
      (tester) async {
    await tester.pumpWidget(_host(const SkeletonList(count: 3)));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(ShaderMask), findsOneWidget);
    expect(find.bySemanticsLabel('Memuat'), findsOneWidget);
    expect(find.byType(InfoCard), findsNWidgets(3));
  });

  testWidgets('Kilau dimatikan saat pengguna memilih kurangi animasi',
      (tester) async {
    await tester.pumpWidget(
        _host(const SkeletonList(count: 2, card: true), reduceMotion: true));

    expect(find.byType(ShaderMask), findsNothing);
    expect(find.byType(InfoCard), findsNWidgets(2));
  });
}
