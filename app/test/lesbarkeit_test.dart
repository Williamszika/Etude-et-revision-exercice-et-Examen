import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_taeglich/ui/stil.dart';

/// **Der Test zum weißen Text vom 16.09.2026.**
///
/// Auf ihrem iPhone war der halbe Lektionstext unsichtbar: weiß auf hellem
/// Papier. Die Ursache war eine Eigenheit von Flutter, die man nicht sieht und
/// die der Analyzer nicht meldet — `RichText` erbt **nicht** vom
/// `DefaultTextStyle`, und ein `TextSpan` ohne `color` wird von der Engine
/// **weiß** gezeichnet. Überall, wo ein Aufrufer `MarkText` ein eigenes `stil`
/// ohne Farbe mitgab (`const TextStyle(fontSize: 14.5)` — rund zwanzig
/// Stellen), fiel damit die Farbe weg.
///
/// Diese Tests prüfen genau das und sonst nichts: Kommt am Ende eine Farbe an,
/// die zum Hintergrund passt? Sie müssen scheitern, sobald jemand `MarkText`
/// wieder so baut, dass der übergebene Stil den Standardstil **ersetzt**
/// statt ihn zu ergänzen.
void main() {
  /// Baut `MarkText` in einem echten Thema auf und gibt die Farbe zurück, mit
  /// der der Text am Ende wirklich gezeichnet wird.
  Future<Color?> farbeVon(
    WidgetTester tester, {
    required Brightness helligkeit,
    TextStyle? stil,
    String text = 'Ich **stelle** mich vor.',
  }) async {
    await tester.pumpWidget(MaterialApp(
      theme: Stil.thema(helligkeit),
      home: Scaffold(body: MarkText(text, stil: stil)),
    ));
    final rt = tester.widget<RichText>(find.byType(RichText));
    return (rt.text as TextSpan).style?.color;
  }

  group('MarkText bekommt immer eine Farbe', () {
    testWidgets('mit eigenem Stil ohne Farbe — hell', (tester) async {
      final f = await farbeVon(
        tester,
        helligkeit: Brightness.light,
        stil: const TextStyle(fontSize: 14.5),
      );
      expect(f, isNotNull, reason: 'ohne Farbe zeichnet die Engine weiß');
      expect(f, isNot(const Color(0xFFFFFFFF)),
          reason: 'weiß auf hellem Papier ist genau der Fehler von damals');
      expect(f, Stil.tinte);
    });

    testWidgets('mit eigenem Stil ohne Farbe — dunkel', (tester) async {
      final f = await farbeVon(
        tester,
        helligkeit: Brightness.dark,
        stil: const TextStyle(fontSize: 14.5),
      );
      expect(f, Stil.dTinte,
          reason: 'im dunklen Thema muss der Text hell sein');
    });

    testWidgets('ganz ohne Stil', (tester) async {
      final f = await farbeVon(tester, helligkeit: Brightness.light);
      expect(f, isNotNull);
      expect(f, isNot(const Color(0xFFFFFFFF)));
    });

    testWidgets('eine bewusst gesetzte Farbe gewinnt weiterhin',
        (tester) async {
      const eigene = Color(0xFFBB4D3F); // die telc-Blockfarbe
      final f = await farbeVon(
        tester,
        helligkeit: Brightness.light,
        stil: const TextStyle(fontSize: 15, color: eigene),
      );
      expect(f, eigene,
          reason: 'die Absicherung darf Aufrufer nicht überstimmen');
    });

    testWidgets('die Schriftgröße des Aufrufers bleibt erhalten',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: Stil.thema(Brightness.light),
        home: const Scaffold(
          body: MarkText('Text', stil: TextStyle(fontSize: 14.5)),
        ),
      ));
      final rt = tester.widget<RichText>(find.byType(RichText));
      expect((rt.text as TextSpan).style?.fontSize, 14.5,
          reason: 'gemerged heißt: Farbe dazu, Größe nicht verloren');
    });
  });

  group('Fett bleibt fett und behält die Farbe', () {
    testWidgets('der **fette** Teil wird nicht farblos', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: Stil.thema(Brightness.light),
        home: const Scaffold(
          body: MarkText('Ich **stelle** mich vor.',
              stil: TextStyle(fontSize: 15)),
        ),
      ));
      final rt = tester.widget<RichText>(find.byType(RichText));
      final kinder = (rt.text as TextSpan).children!;
      final fett = kinder.firstWhere(
        (s) => s is TextSpan && s.text == 'stelle',
      ) as TextSpan;
      expect(fett.style?.fontWeight, FontWeight.w700);
      expect(fett.style?.color, Stil.tinte);
    });
  });
}
