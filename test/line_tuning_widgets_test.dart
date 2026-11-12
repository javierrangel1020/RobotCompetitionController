import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joystick/l10n/app_localizations.dart';
import 'package:joystick/models/line_follower.dart';
import 'package:joystick/widgets/line_tuning.dart';

/// Pantalla de telefono angosto, en espanol (los textos mas largos).
Future<void> pumpNarrow(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: ListView(padding: const EdgeInsets.all(16), children: [child]),
    ),
  ));
}

void main() {
  testWidgets('grafica de posicion con linea perdida y error medio',
      (tester) async {
    final history = <int?>[
      for (var i = 0; i < 60; i++) (i % 20 - 10) * 300,
      null,
      null,
      3500,
    ];
    await pumpNarrow(
        tester, PositionChart(history: history, capacity: 100));
    expect(tester.takeException(), isNull);
    expect(find.text('Posición en el tiempo'), findsOneWidget);
    expect(find.textContaining('Error medio: '), findsOneWidget);
  });

  testWidgets('grafica vacia muestra error medio sin valor', (tester) async {
    await pumpNarrow(tester, const PositionChart(history: [], capacity: 100));
    expect(tester.takeException(), isNull);
    expect(find.text('Error medio: -'), findsOneWidget);
  });

  testWidgets('calibracion guardada: senala los sensores sin contraste',
      (tester) async {
    final cal = LineProtocol.parseCalibrationRanges(
        'CLB,10,12,14,16,18,20,22,24,200,210,220,230,240,250,40,255')!;
    await pumpNarrow(tester, CalibrationRangesCard(calibration: cal));
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Poco contraste en S6'), findsOneWidget);
    expect(find.text('190'), findsOneWidget); // contraste de S0
  });

  testWidgets('calibracion guardada: sin calibrar y esperando',
      (tester) async {
    final cal = LineProtocol.parseCalibrationRanges(
        'CLB,0,0,0,0,0,0,0,0,255,255,255,255,255,255,255,255')!;
    await pumpNarrow(tester, CalibrationRangesCard(calibration: cal));
    expect(find.text('El robot no está calibrado. Calibra antes de arrancar.'),
        findsOneWidget);

    await pumpNarrow(tester, const CalibrationRangesCard(calibration: null));
    expect(find.text('Esperando la calibración del robot'), findsOneWidget);
  });
}
