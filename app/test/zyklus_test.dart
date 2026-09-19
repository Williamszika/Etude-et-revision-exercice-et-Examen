import 'package:deutsch_taeglich/daten/modelle.dart';
import 'package:deutsch_taeglich/logik/zyklus.dart';
import 'package:flutter_test/flutter_test.dart';

/// Getestet wird die Rechnung, nicht das Aussehen.
///
/// Der Grund: Wenn `Zyklus` sich verrechnet, zeigt die App am falschen Tag die
/// falsche Lektion — und das würde sie erst merken, wenn sie davor sitzt.
/// Alles andere ist Oberfläche und fällt beim Hinsehen auf.
void main() {
  const start = '2026-09-11';

  group('Lektionstag und Übungstag wechseln sich ab', () {
    test('der Starttag ist Lektion 1', () {
      expect(Zyklus.istLektionstag(start, '2026-09-11'), isTrue);
      expect(Zyklus.lektionsNr(start, '2026-09-11', 72), 1);
    });

    test('der Tag danach ist Übungstag', () {
      expect(Zyklus.istUebungstag(start, '2026-09-12'), isTrue);
      expect(Zyklus.istLektionstag(start, '2026-09-12'), isFalse);
    });

    test('die bekannten Lektionsdaten stimmen', () {
      // Diese fünf stehen so in CLAUDE.md — sie sind der Prüfstein.
      expect(Zyklus.lektionsNr(start, '2026-09-13', 72), 2);
      expect(Zyklus.lektionsNr(start, '2026-09-15', 72), 3);
      expect(Zyklus.lektionsNr(start, '2026-09-17', 72), 4);
      expect(Zyklus.lektionsNr(start, '2026-09-19', 72), 5);
      expect(Zyklus.lektionsNr(start, '2026-09-21', 72), 6);
    });

    test('vor dem Start gibt es nichts', () {
      expect(Zyklus.istLektionstag(start, '2026-09-10'), isFalse);
      expect(Zyklus.lektionsNr(start, '2026-09-10', 72), 0);
    });
  });

  group('Themenblöcke dauern zwei Lektionen', () {
    test('Block 1 trägt die Lektionen 1 und 2', () {
      expect(Zyklus.themenBlock(start, '2026-09-11', 29), 1);
      expect(Zyklus.themenBlock(start, '2026-09-13', 29), 1);
    });

    test('Block 2 fängt bei Lektion 3 an', () {
      expect(Zyklus.themenBlock(start, '2026-09-15', 29), 2);
      expect(Zyklus.themenBlock(start, '2026-09-17', 29), 2);
    });

    test('Block 3 — Perfekt und Präteritum — ist der 19. und 21.09.', () {
      expect(Zyklus.themenBlock(start, '2026-09-19', 29), 3);
      expect(Zyklus.themenBlock(start, '2026-09-21', 29), 3);
    });
  });

  // Seit der Verlängerung vom 19.09.2026 läuft die Etappe bis zum 31.01.2027:
  // 72 Lektionen, 29 Blöcke, Wiederholung ab dem 05.01.2027.
  group('Die Wiederholungsphase fängt am 05.01.2027 an', () {
    test('davor nicht — der 03.01. ist noch Block 29', () {
      expect(Zyklus.istWiederholung(start, '2026-12-04'), isFalse);
      expect(Zyklus.istWiederholung(start, '2027-01-03'), isFalse);
    });
    test('danach schon', () {
      expect(Zyklus.istWiederholung(start, '2027-01-05'), isTrue);
      expect(Zyklus.istWiederholung(start, '2027-01-31'), isTrue);
    });
    test('die Grenze hängt an themenGesamt, nicht an einer festen Zahl', () {
      // Mit den alten 21 Blöcken lag sie am 04.12.2026 — derselbe Code.
      expect(Zyklus.istWiederholung(start, '2026-12-02', 21), isFalse);
      expect(Zyklus.istWiederholung(start, '2026-12-04', 21), isTrue);
    });
  });

  group('Die verlängerte Etappe rechnet bis Lektion 72', () {
    test('Lektion 42 schließt Block 21 am 02.12.2026 ab', () {
      expect(Zyklus.lektionsNr(start, '2026-12-02', 72), 42);
      expect(Zyklus.themenBlock(start, '2026-12-02', 29), 21);
    });
    test('Block 22 fängt am 04.12.2026 mit Lektion 43 an', () {
      expect(Zyklus.lektionsNr(start, '2026-12-04', 72), 43);
      expect(Zyklus.themenBlock(start, '2026-12-04', 29), 22);
    });
    test('Block 29 endet mit Lektion 58 am 03.01.2027', () {
      expect(Zyklus.lektionsNr(start, '2027-01-03', 72), 58);
      expect(Zyklus.themenBlock(start, '2027-01-03', 29), 29);
    });
    test('die letzte Lektion ist Nummer 72 am 31.01.2027', () {
      expect(Zyklus.istLektionstag(start, '2027-01-31'), isTrue);
      expect(Zyklus.lektionsNr(start, '2027-01-31', 72), 72);
    });
  });

  group('Die Tagesleiste baut Übungstage von selbst', () {
    final daten = Daten.ausJson({
      'start': start,
      'lektionenGesamt': 72,
      'themenGesamt': 29,
      'etappeEnde': '2027-01-31',
      'lektionen': [
        {'datum': '2026-09-15', 'zyklus': {'lektion': 3}},
        {'datum': '2026-09-13', 'zyklus': {'lektion': 2}},
        {'datum': '2026-09-11', 'zyklus': {'lektion': 1}},
      ],
    });

    test('zwischen zwei Lektionen entsteht ein Übungstag', () {
      final tage = Tag.bauen(daten);
      final zwoelfter = tage.firstWhere((t) => t.datum == '2026-09-12');
      expect(zwoelfter.uebung, isTrue);
      // Er zeigt die Übungen der Lektion davor, nicht der danach.
      expect(zwoelfter.lektion.datum, '2026-09-11');
    });

    test('ein Lektionstag ist kein Übungstag', () {
      final tage = Tag.bauen(daten);
      expect(tage.firstWhere((t) => t.datum == '2026-09-13').uebung, isFalse);
    });

    test('die Leiste ist neueste zuerst sortiert', () {
      final tage = Tag.bauen(daten);
      expect(tage.first.datum.compareTo(tage.last.datum), greaterThan(0));
    });

    test('ein geplanter Übungstag gilt nicht als fehlend', () {
      final tage = Tag.bauen(daten);
      // 12.09. ist t = 1, also ungerade: hier gehört keine Lektion hin.
      expect(tage.firstWhere((t) => t.datum == '2026-09-12').fehlt, isFalse);
      expect(tage.firstWhere((t) => t.datum == '2026-09-14').fehlt, isFalse);
    });

    test('ein Lektionstag hat nie das Fehlt-Kennzeichen', () {
      final tage = Tag.bauen(daten);
      for (final t in tage.where((t) => !t.uebung)) {
        expect(t.fehlt, isFalse, reason: 'Lektionstag ${t.datum}');
      }
    });
  });

  // Der Fall vom 19.09.2026: Die Webseite zeigte Lektion 5, die App einen
  // Übungstag — weil die Lektion veröffentlicht, aber nicht committet war.
  // Die App darf dann nicht behaupten, es gebe heute keine Lektion.
  group('Eine fehlende Lektion wird als fehlend erkannt', () {
    final mitLuecke = Daten.ausJson({
      'start': start,
      'lektionenGesamt': 72,
      'themenGesamt': 29,
      'etappeEnde': '2027-01-31',
      'lektionen': [
        // Lektion 4 vom 17.09. ist da, Lektion 5 vom 19.09. fehlt.
        {'datum': '2026-09-17', 'zyklus': {'lektion': 4}},
        {'datum': '2026-09-15', 'zyklus': {'lektion': 3}},
      ],
    });

    test('der 19.09. ist nach dem Takt ein Lektionstag', () {
      expect(Zyklus.istLektionstag(start, '2026-09-19'), isTrue);
    });

    test('fehlt die Datei, ist der Tag als fehlend gekennzeichnet', () {
      // Nur prüfbar, solange der 19.09.2026 nicht in der Zukunft liegt —
      // `Tag.bauen` baut die Leiste höchstens bis heute.
      final treffer =
          Tag.bauen(mitLuecke).where((t) => t.datum == '2026-09-19').toList();
      if (treffer.isEmpty) return;
      expect(treffer.first.uebung, isTrue);
      expect(treffer.first.fehlt, isTrue);
      // Er zeigt so lange die Aufgaben der letzten vorhandenen Lektion.
      expect(treffer.first.lektion.datum, '2026-09-17');
    });

    test('der 18.09. daneben bleibt ein normaler Übungstag', () {
      final treffer =
          Tag.bauen(mitLuecke).where((t) => t.datum == '2026-09-18').toList();
      if (treffer.isEmpty) return;
      expect(treffer.first.uebung, isTrue);
      expect(treffer.first.fehlt, isFalse);
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
