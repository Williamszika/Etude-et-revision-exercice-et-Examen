import 'package:deutsch_taeglich/daten/modelle.dart';
import 'package:deutsch_taeglich/logik/zyklus.dart';
import 'package:flutter_test/flutter_test.dart';

/// Getestet wird die Rechnung, nicht das Aussehen.
///
/// Der Grund: Wenn `Zyklus` sich verrechnet, zeigt die App am falschen Tag die
/// falsche Lektion — und das würde sie erst merken, wenn sie davor sitzt.
/// Alles andere ist Oberfläche und fällt beim Hinsehen auf.
///
/// **Die Sollwerte stammen aus `python3 deutsch-taeglich/heute.py --plan`**
/// (Stand 15.10.2026: Neustart 16.10., Mo–Sa, drei Lektionen pro Thema, das
/// ganze Programm zweimal, 186 Lektionen bis 20.05.2027). Die Webseite und die
/// App müssen dieselben Zahlen liefern.
void main() {
  const k = Takt(start: '2026-10-16');
  const gesamt = 186;

  group('Lektion jeden Tag außer Sonntag', () {
    test('Freitag 16.10.2026 ist Lektion 1', () {
      expect(Zyklus.istLektionstag(k, '2026-10-16'), isTrue);
      expect(Zyklus.lektionsNr(k, '2026-10-16', gesamt), 1);
    });

    test('Samstag 17.10. ist Lektion 2', () {
      expect(Zyklus.istLektionstag(k, '2026-10-17'), isTrue);
      expect(Zyklus.lektionsNr(k, '2026-10-17', gesamt), 2);
    });

    test('Sonntag 18.10. ist Ruhetag, keine Lektion', () {
      expect(Zyklus.istRuhetag(k, '2026-10-18'), isTrue);
      expect(Zyklus.istLektionstag(k, '2026-10-18'), isFalse);
      expect(Zyklus.istUebungstag(k, '2026-10-18'), isTrue);
      // Die Zählung bleibt bei 2 stehen.
      expect(Zyklus.lektionsNr(k, '2026-10-18', gesamt), 2);
    });

    test('Montag 19.10. ist Lektion 3', () {
      expect(Zyklus.lektionsNr(k, '2026-10-19', gesamt), 3);
    });

    test('vor dem Start gibt es nichts', () {
      expect(Zyklus.istLektionstag(k, '2026-10-15'), isFalse);
      expect(Zyklus.istUebungstag(k, '2026-10-15'), isFalse);
      expect(Zyklus.lektionsNr(k, '2026-10-15', gesamt), 0);
    });
  });

  group('Drei Lektionen pro Thema, zwei Durchgänge', () {
    test('Block 1 = Lektion 1–3, Block 2 fängt mit Lektion 4 an', () {
      expect(Zyklus.blockVon(k, 1), 1);
      expect(Zyklus.blockVon(k, 3), 1);
      expect(Zyklus.blockVon(k, 4), 2);
      expect(Zyklus.themenBlock(k, '2026-10-20'), 2); // L4
    });

    test('Lektion 87 am 25.01.2027 schließt Durchgang 1 mit Block 29', () {
      expect(Zyklus.lektionsNr(k, '2027-01-25', gesamt), 87);
      expect(Zyklus.blockVon(k, 87), 29);
      expect(Zyklus.durchgangVon(k, 87), 1);
    });

    test('Lektion 88 am 26.01.2027 beginnt Durchgang 2 wieder bei Block 1', () {
      expect(Zyklus.lektionsNr(k, '2027-01-26', gesamt), 88);
      expect(Zyklus.blockVon(k, 88), 1);
      expect(Zyklus.durchgangVon(k, 88), 2);
    });

    test('Lektion 174 am 06.05.2027 ist das Ende von Durchgang 2', () {
      expect(Zyklus.lektionsNr(k, '2027-05-06', gesamt), 174);
      expect(Zyklus.blockVon(k, 174), 29);
      expect(Zyklus.istWiederholung(k, '2027-05-06'), isFalse);
    });

    test('ab Lektion 175 am 07.05.2027 ist Wiederholung', () {
      expect(Zyklus.lektionsNr(k, '2027-05-07', gesamt), 175);
      expect(Zyklus.istWiederholung(k, '2027-05-07'), isTrue);
      expect(Zyklus.durchgangVon(k, 175), 0);
    });

    test('die letzte Lektion ist Nummer 186 am 20.05.2027', () {
      expect(Zyklus.lektionsNr(k, '2027-05-20', gesamt), 186);
      expect(Zyklus.lektionsNr(k, '2027-06-30', gesamt), 186); // gedeckelt
    });
  });

  group('Pausen aus pausen.json', () {
    const mitPause = Takt(start: '2026-10-16', pausen: [
      {'von': '2026-10-20', 'bis': '2026-10-21'},
    ]);
    const zaehlend = Takt(start: '2026-10-16', pausen: [
      {'von': '2026-10-20', 'bis': '2026-10-20', 'zaehlt': true},
    ]);

    test('ein Pausentag ist kein Lektionstag und schiebt den Plan', () {
      expect(Zyklus.istLektionstag(mitPause, '2026-10-20'), isFalse);
      expect(Zyklus.lektionsNr(mitPause, '2026-10-22', gesamt), 4);
    });

    test('eine mitzählende Pause schiebt den Plan nicht', () {
      expect(Zyklus.istLektionstag(zaehlend, '2026-10-20'), isFalse);
      expect(Zyklus.lektionsNr(zaehlend, '2026-10-21', gesamt), 5);
    });
  });

  group('Die Tagesleiste: Ruhetag und fehlende Lektion', () {
    final daten = Daten.ausJson({
      'start': '2026-10-16',
      'lektionenGesamt': 186,
      'themenGesamt': 29,
      'etappeEnde': '2027-05-20',
      'ruhetag': 7,
      'proThema': 3,
      'durchgaenge': 2,
      'pausen': [],
      'lektionen': [
        // 17.10. (Samstag) fehlt absichtlich, 18.10. ist Sonntag.
        {'datum': '2026-10-19', 'zyklus': {'lektion': 3}},
        {'datum': '2026-10-16', 'zyklus': {'lektion': 1}},
      ],
    });
    final tage = Tag.bauen(daten);
    Tag am(String d) => tage.firstWhere((t) => t.datum == d);

    test('der Sonntag ist ein Ruhetag, nicht fehlend', () {
      expect(am('2026-10-18').uebung, isTrue);
      expect(am('2026-10-18').ruhetag, isTrue);
      expect(am('2026-10-18').fehlt, isFalse);
    });

    test('ein Samstag ohne Datei ist als fehlend gekennzeichnet', () {
      expect(am('2026-10-17').uebung, isTrue);
      expect(am('2026-10-17').fehlt, isTrue);
      expect(am('2026-10-17').lektion.datum, '2026-10-16');
    });

    test('Lektionstage sind keine Übungstage', () {
      expect(am('2026-10-16').uebung, isFalse);
      expect(am('2026-10-19').uebung, isFalse);
    });

    test('die Leiste ist neueste zuerst sortiert', () {
      expect(tage.first.datum.compareTo(tage.last.datum), greaterThan(0));
    });

    test('alte app-daten.json ohne neue Felder bekommt die neuen Regeln', () {
      final alt = Daten.ausJson({'start': '2026-10-16'});
      expect(alt.ruhetag, 7);
      expect(alt.takt.grammatikLektionen, 174);
    });
  });

  group('Fett aus dem JSON wird echte Fettschrift', () {
    test('die Sternchen verschwinden', () {
      final roh = Daten.ausJson({
        'lektionen': [
          {
            'datum': '2026-09-15',
            'verb': {'titel': 'Das ist **wichtig** hier'},
          },
        ],
      });
      final t = textVon(roh.lektionen.first.block('verb')!['titel']);
      expect(t.contains('**'), isTrue, reason: 'roh bleibt roh');
    });
  });

  group('Fehlende Blöcke stürzen nicht ab', () {
    test('eine Lektion ohne Vokabeln liefert null statt zu werfen', () {
      final d = Daten.ausJson({
        'lektionen': [
          {'datum': '2026-09-15'},
        ],
      });
      expect(d.lektionen.first.block('vokabeln'), isNull);
      expect(d.lektionen.first.hat('diktat'), isFalse);
    });
  });
}
