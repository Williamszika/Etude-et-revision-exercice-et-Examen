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
/// (Stand 23.10.2026: Neustart 16.10., bis 23.10. Mo–Sa, seit 23.10. jeden
/// zweiten Tag auch sonntags, drei Lektionen pro Thema, das Programm einmal,
/// 99 Lektionen bis 25.04.2027). Die Webseite und die App müssen dieselben
/// Zahlen liefern.
void main() {
  const k = Takt(start: '2026-10-16');
  const gesamt = 99;

  group('Bis zum 23.10.2026: jeden Tag außer Sonntag', () {
    test('Freitag 16.10.2026 ist Lektion 1', () {
      expect(Zyklus.istLektionstag(k, '2026-10-16'), isTrue);
      expect(Zyklus.lektionsNr(k, '2026-10-16', gesamt), 1);
    });

    test('Sonntag 18.10. ist Ruhetag, keine Lektion', () {
      expect(Zyklus.istRuhetag(k, '2026-10-18'), isTrue);
      expect(Zyklus.istLektionstag(k, '2026-10-18'), isFalse);
      expect(Zyklus.istUebungstag(k, '2026-10-18'), isTrue);
      expect(Zyklus.lektionsNr(k, '2026-10-18', gesamt), 2);
    });

    test('Freitag 23.10. ist Lektion 7', () {
      expect(Zyklus.istLektionstag(k, '2026-10-23'), isTrue);
      expect(Zyklus.lektionsNr(k, '2026-10-23', gesamt), 7);
    });

    test('vor dem Start gibt es nichts', () {
      expect(Zyklus.istLektionstag(k, '2026-10-15'), isFalse);
      expect(Zyklus.istUebungstag(k, '2026-10-15'), isFalse);
      expect(Zyklus.lektionsNr(k, '2026-10-15', gesamt), 0);
    });
  });

  group('Seit dem 23.10.2026: jeden zweiten Tag, auch sonntags', () {
    test('Samstag 24.10. ist Übungstag, kein Ruhetag', () {
      expect(Zyklus.istLektionstag(k, '2026-10-24'), isFalse);
      expect(Zyklus.istUebungstag(k, '2026-10-24'), isTrue);
      expect(Zyklus.istRuhetag(k, '2026-10-24'), isFalse);
      expect(Zyklus.lektionsNr(k, '2026-10-24', gesamt), 7);
    });

    test('Sonntag 25.10. ist Lektion 8 — kein Ruhetag mehr', () {
      expect(Zyklus.istRuhetag(k, '2026-10-25'), isFalse);
      expect(Zyklus.istLektionstag(k, '2026-10-25'), isTrue);
      expect(Zyklus.lektionsNr(k, '2026-10-25', gesamt), 8);
    });

    test('Dienstag 27.10. ist Lektion 9', () {
      expect(Zyklus.lektionsNr(k, '2026-10-27', gesamt), 9);
    });
  });

  group('Drei Lektionen pro Thema, das Programm einmal', () {
    test('Block 1 = Lektion 1–3, Block 2 fängt mit Lektion 4 an', () {
      expect(Zyklus.blockVon(k, 1), 1);
      expect(Zyklus.blockVon(k, 3), 1);
      expect(Zyklus.blockVon(k, 4), 2);
      expect(Zyklus.themenBlock(k, '2026-10-20'), 2); // L4
    });

    test('Lektion 45 am 07.01.2027 schließt Kurs B1.1 (Thema 15)', () {
      expect(Zyklus.lektionsNr(k, '2027-01-07', gesamt), 45);
      expect(Zyklus.blockVon(k, 45), 15);
      expect(k.kursB11, 45);
    });

    test('Lektion 87 am 01.04.2027 schließt Thema 29', () {
      expect(Zyklus.lektionsNr(k, '2027-04-01', gesamt), 87);
      expect(Zyklus.blockVon(k, 87), 29);
      expect(Zyklus.istWiederholung(k, '2027-04-01'), isFalse);
    });

    test('ab Lektion 88 am 03.04.2027 ist Wiederholung', () {
      expect(Zyklus.lektionsNr(k, '2027-04-03', gesamt), 88);
      expect(Zyklus.istWiederholung(k, '2027-04-03'), isTrue);
    });

    test('die letzte Lektion ist Nummer 99 am 25.04.2027', () {
      expect(Zyklus.lektionsNr(k, '2027-04-25', gesamt), 99);
      expect(Zyklus.lektionsNr(k, '2027-06-30', gesamt), 99); // gedeckelt
    });
  });

  group('Pausen aus pausen.json', () {
    const alt = Takt(start: '2026-10-16', pausen: [
      {'von': '2026-10-20', 'bis': '2026-10-21'},
    ]);
    const schiebt = Takt(start: '2026-10-16', pausen: [
      {'von': '2026-10-25', 'bis': '2026-10-25'},
    ]);
    const zaehlend = Takt(start: '2026-10-16', pausen: [
      {'von': '2026-10-25', 'bis': '2026-10-25', 'zaehlt': true},
    ]);

    test('vor dem Wechsel: ein Pausentag ist kein Lektionstag', () {
      expect(Zyklus.istLektionstag(alt, '2026-10-20'), isFalse);
      expect(Zyklus.lektionsNr(alt, '2026-10-22', gesamt), 4);
    });

    test('nach dem Wechsel schiebt eine Pause den Takt: die Lektion kommt am Tag danach', () {
      expect(Zyklus.istLektionstag(schiebt, '2026-10-25'), isFalse);
      expect(Zyklus.istLektionstag(schiebt, '2026-10-26'), isTrue);
      expect(Zyklus.lektionsNr(schiebt, '2026-10-26', gesamt), 8);
    });

    test('eine mitzählende Pause schiebt den Takt nicht', () {
      expect(Zyklus.istLektionstag(zaehlend, '2026-10-26'), isFalse);
      expect(Zyklus.istLektionstag(zaehlend, '2026-10-27'), isTrue);
      expect(Zyklus.lektionsNr(zaehlend, '2026-10-27', gesamt), 8);
    });
  });

  group('Die Tagesleiste: Ruhetag, Übungstag und fehlende Lektion', () {
    final daten = Daten.ausJson({
      'start': '2026-10-16',
      'lektionenGesamt': 99,
      'themenGesamt': 29,
      'etappeEnde': '2027-04-25',
      'ruhetag': 7,
      'wechsel': '2026-10-23',
      'takt': 2,
      'proThema': 3,
      'durchgaenge': 1,
      'pausen': [],
      'lektionen': [
        // 25.10. (Sonntag, Lektionstag) fehlt absichtlich.
        {'datum': '2026-10-27', 'zyklus': {'lektion': 9}},
        {'datum': '2026-10-23', 'zyklus': {'lektion': 7}},
        {'datum': '2026-10-17', 'zyklus': {'lektion': 2}},
        {'datum': '2026-10-16', 'zyklus': {'lektion': 1}},
      ],
    });
    final tage = Tag.bauen(daten);
    Tag am(String d) => tage.firstWhere((t) => t.datum == d);

    test('Sonntag 18.10. ist ein Ruhetag, nicht fehlend', () {
      expect(am('2026-10-18').uebung, isTrue);
      expect(am('2026-10-18').ruhetag, isTrue);
      expect(am('2026-10-18').fehlt, isFalse);
    });

    test('Samstag 24.10. ist ein geplanter Übungstag', () {
      expect(am('2026-10-24').uebung, isTrue);
      expect(am('2026-10-24').ruhetag, isFalse);
      expect(am('2026-10-24').fehlt, isFalse);
    });

    test('Sonntag 25.10. ohne Datei ist als fehlend gekennzeichnet', () {
      expect(am('2026-10-25').uebung, isTrue);
      expect(am('2026-10-25').fehlt, isTrue);
      expect(am('2026-10-25').lektion.datum, '2026-10-23');
    });

    test('Lektionstage sind keine Übungstage', () {
      expect(am('2026-10-23').uebung, isFalse);
      expect(am('2026-10-27').uebung, isFalse);
    });

    test('die Leiste ist neueste zuerst sortiert', () {
      expect(tage.first.datum.compareTo(tage.last.datum), greaterThan(0));
    });

    test('alte app-daten.json ohne neue Felder bekommt die neuen Regeln', () {
      final alt = Daten.ausJson({'start': '2026-10-16'});
      expect(alt.ruhetag, 7);
      expect(alt.takt.grammatikLektionen, 87);
      expect(alt.takt.taktTage, 2);
      expect(alt.lektionenGesamt, 99);
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
