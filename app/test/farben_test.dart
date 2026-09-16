import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_taeglich/ui/stil.dart';

/// **Der Test zu den blassen Farben vom 16.09.2026.**
///
/// Sie hat gesagt: *„changer les couleurs aussi dans l'app, Je n'arrive pas a
/// bien les lires."* Nachgemessen hatte sie recht — im hellen Thema lagen
/// `gold` bei 3,49:1, `telc` bei 4,46 und `aussprache` bei 4,53 gegen das
/// Papier. Die Grenze für normalen Text ist **4,5:1**, und genau diese Farben
/// tragen die **kleinste** Schrift der App (Etiketten, 11 px, gesperrt).
///
/// Dieser Test rechnet den Kontrast nach der üblichen Formel aus (relative
/// Leuchtdichte, wie sie auch die Barrierefreiheits-Richtlinien benutzen) und
/// scheitert, sobald jemand eine Farbe wieder heller macht. Damit ist die
/// Lesbarkeit keine Geschmacksfrage mehr, sondern eine Zahl.
void main() {
  /// Relative Leuchtdichte einer Farbe — 0 ist schwarz, 1 ist weiß.
  double leuchte(Color f) {
    double kanal(double roh) =>
        roh <= 0.04045 ? roh / 12.92 : math.pow((roh + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * kanal(f.r) + 0.7152 * kanal(f.g) + 0.0722 * kanal(f.b);
  }

  /// Kontrastverhältnis zwischen zwei Farben: 1 = gleich, 21 = Schwarz/Weiß.
  double kontrast(Color a, Color b) {
    final x = leuchte(a), y = leuchte(b);
    return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
  }

  /// Alle Blocknamen, die in den Lektionen vorkommen.
  const bloecke = [
    'verb', 'wortschatz', 'vokabeln', 'grammatik', 'deklination', 'lesen',
    'leben', 'training', 'telc', 'probe', 'aussprache', 'diktat',
    'uebersetzung',
  ];

  /// Baut einen Kontext mit dem echten Thema, damit `blockFarbe` und die
  /// anderen Helfer genau das liefern, was auf dem Telefon ankommt.
  Future<BuildContext> kontextMit(WidgetTester tester, Brightness h) async {
    late BuildContext gefangen;
    await tester.pumpWidget(MaterialApp(
      theme: Stil.thema(h),
      home: Builder(builder: (c) {
        gefangen = c;
        return const SizedBox();
      }),
    ));
    return gefangen;
  }

  group('Helles Thema — jede Farbe ist auf Papier lesbar', () {
    testWidgets('die Blockfarben liegen über 6:1', (tester) async {
      final c = await kontextMit(tester, Brightness.light);
      for (final b in bloecke) {
        final v = kontrast(Stil.blockFarbe(c, b), Stil.papier);
        expect(v, greaterThanOrEqualTo(6.0),
            reason: 'Blockfarbe "$b" hat nur ${v.toStringAsFixed(2)}:1 — '
                'Etiketten sind 11 px, das ist zu blass');
      }
    });

    testWidgets('auch auf der helleren Karte', (tester) async {
      final c = await kontextMit(tester, Brightness.light);
      for (final b in bloecke) {
        expect(kontrast(Stil.blockFarbe(c, b), Stil.karte),
            greaterThanOrEqualTo(6.0),
            reason: 'Blockfarbe "$b" auf der Karte');
      }
    });

    testWidgets('Tinte, weiche Tinte, Akzent, Gold und Gut', (tester) async {
      final c = await kontextMit(tester, Brightness.light);
      final paare = <String, Color>{
        'tinte': Stil.tinte,
        'tinteWeich': Stil.weich(c),
        'akzent': Stil.akzentFarbe(c),
        'gold': Stil.goldFarbe(c),
        'gut': Stil.gutFarbe(c),
      };
      paare.forEach((name, f) {
        final v = kontrast(f, Stil.papier);
        expect(v, greaterThanOrEqualTo(5.5),
            reason: '$name hat nur ${v.toStringAsFixed(2)}:1');
      });
    });
  });

  group('Dunkles Thema — dieselbe Messlatte', () {
    testWidgets('die Blockfarben liegen über 6:1', (tester) async {
      final c = await kontextMit(tester, Brightness.dark);
      for (final b in bloecke) {
        final v = kontrast(Stil.blockFarbe(c, b), Stil.dPapier);
        expect(v, greaterThanOrEqualTo(6.0),
            reason: 'dunkle Blockfarbe "$b" hat nur ${v.toStringAsFixed(2)}:1');
      }
    });

    testWidgets('Tinte, weiche Tinte, Akzent, Gold und Gut', (tester) async {
      final c = await kontextMit(tester, Brightness.dark);
      final paare = <String, Color>{
        'dTinte': Stil.dTinte,
        'dTinteWeich': Stil.weich(c),
        'dAkzent': Stil.akzentFarbe(c),
        'dGold': Stil.goldFarbe(c),
        'dGut': Stil.gutFarbe(c),
      };
      paare.forEach((name, f) {
        final v = kontrast(f, Stil.dPapier);
        expect(v, greaterThanOrEqualTo(5.5),
            reason: '$name hat nur ${v.toStringAsFixed(2)}:1');
      });
    });
  });

  group('Die Rechnung selbst stimmt', () {
    test('Schwarz auf Weiß sind 21:1', () {
      expect(kontrast(const Color(0xFF000000), const Color(0xFFFFFFFF)),
          closeTo(21, 0.01));
    });
    test('eine Farbe gegen sich selbst ist 1:1', () {
      expect(kontrast(Stil.akzent, Stil.akzent), closeTo(1, 0.001));
    });
    test('die alte Goldfarbe wäre durchgefallen', () {
      // #B5731A — genau der Wert, über den sie sich beschwert hat.
      expect(kontrast(const Color(0xFFB5731A), Stil.papier), lessThan(4.5));
    });
  });
}
