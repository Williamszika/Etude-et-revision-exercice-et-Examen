import '../daten/modelle.dart';

/// Die Rechnung hinter Deutsch täglich — dieselbe wie im Web-Template und in
/// `CLAUDE.md`, nur in Dart.
///
///     t = (heute − 11.09.2026).days
///     t gerade und ≥ 0  →  Lektionstag,  lektion = t ~/ 2 + 1   (1 … 56)
///     t ungerade        →  Übungstag
///     themaBlock        =  t ~/ 4 + 1                            (1 … 21)
///
/// Ab t > 82 (also ab dem 04.12.2026) läuft die Wiederholungsphase: kein neues
/// Grammatikthema mehr.
class Zyklus {
  const Zyklus._();

  static DateTime tagVon(String iso) {
    final t = iso.split('-');
    if (t.length != 3) return DateTime.now();
    return DateTime(
      int.tryParse(t[0]) ?? 2026,
      int.tryParse(t[1]) ?? 1,
      int.tryParse(t[2]) ?? 1,
    );
  }

  static String isoVon(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static String get heute {
    final n = DateTime.now();
    return isoVon(DateTime(n.year, n.month, n.day));
  }

  static int tageZwischen(String von, String bis) =>
      tagVon(bis).difference(tagVon(von)).inDays;

  /// t für ein Datum.
  static int t(String start, String datum) => tageZwischen(start, datum);

  static bool istLektionstag(String start, String datum) {
    final x = t(start, datum);
    return x >= 0 && x.isEven;
  }

  static bool istUebungstag(String start, String datum) {
    final x = t(start, datum);
    return x >= 0 && x.isOdd;
  }

  static int lektionsNr(String start, String datum, int gesamt) {
    final x = t(start, datum);
    if (x < 0) return 0;
    final n = x ~/ 2 + 1;
    return n < 0 ? 0 : (n > gesamt ? gesamt : n);
  }

  static int themenBlock(String start, String datum, int gesamt) {
    final x = t(start, datum);
    if (x < 0) return 0;
    final n = x ~/ 4 + 1;
    return n < 0 ? 0 : (n > gesamt ? gesamt : n);
  }

  static bool istWiederholung(String start, String datum) =>
      t(start, datum) > 82;

  static const wochentage = [
    'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag',
    'Freitag', 'Samstag', 'Sonntag',
  ];

  static String wochentag(String datum) =>
      wochentage[(tagVon(datum).weekday - 1).clamp(0, 6)];

  /// „Dienstag, 15.09.2026“
  static String langesDatum(String datum) {
    final d = tagVon(datum);
    final tt = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '${wochentag(datum)}, $tt.$mm.${d.year}';
  }

  /// „15.09.“
  static String kurzesDatum(String datum) {
    final d = tagVon(datum);
    return '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.';
  }
}

/// Ein Tag in der Leiste — entweder eine Lektion oder ein Übungstag.
///
/// Gebaut wie `baueTage()` im Template: vom ältesten Lektionsdatum bis heute,
/// und jeder Tag ohne eigene Lektionsdatei wird zum Übungstag mit der letzten
/// vorangegangenen Lektion. Deshalb entsteht für einen Übungstag **keine
/// Datei** — er fällt von selbst an.
class Tag {
  Tag({
    required this.datum,
    required this.lektion,
    required this.uebung,
    this.fehlt = false,
  });

  final String datum;

  /// Bei einem Übungstag: die Lektion, deren Übungen gezeigt werden.
  final Lektion lektion;
  final bool uebung;

  /// **Der Unterschied, der am 19.09.2026 dazugekommen ist.**
  ///
  /// Ein Tag ohne Lektionsdatei kann zwei sehr verschiedene Dinge bedeuten:
  ///
  /// * `fehlt == false` — ein **geplanter Übungstag**. Nach dem Takt ist heute
  ///   kein Lektionstag, es soll gar keine Lektion geben.
  /// * `fehlt == true` — nach dem Takt **wäre** heute ein Lektionstag, aber die
  ///   Lektion ist nicht in `app-daten.json` angekommen.
  ///
  /// Vorher sahen beide Fälle gleich aus, und die App meldete „Heute gibt es
  /// keine neue Lektion“ — auch dann, wenn es sehr wohl eine gab, sie aber nur
  /// nicht committet worden war. Genau das ist ihr am 19.09.2026 passiert: Die
  /// Webseite zeigte Lektion 5, die App einen Übungstag. Die App hat also nicht
  /// versagt, sie hat **das Falsche behauptet**. Mit diesem Feld sagt sie
  /// stattdessen, dass etwas fehlt, und schickt sie auf die Webseite.
  final bool fehlt;

  static List<Tag> bauen(Daten d) {
    if (d.lektionen.isEmpty) return const [];
    final erste = Zyklus.tagVon(d.lektionen.last.datum);
    final neueste = Zyklus.tagVon(d.lektionen.first.datum);
    var ende = Zyklus.tagVon(Zyklus.heute);
    if (neueste.isAfter(ende)) ende = neueste;

    final raus = <Tag>[];
    Lektion? letzte;
    for (var x = erste; !x.isAfter(ende); x = x.add(const Duration(days: 1))) {
      final iso = Zyklus.isoVon(x);
      final l = d.amTag(iso);
      if (l != null) {
        letzte = l;
        raus.add(Tag(datum: iso, lektion: l, uebung: false));
      } else if (letzte != null) {
        // Kein Lektionsdatei für diesen Tag. Sagt der Takt, dass hier eine
        // hingehört, dann fehlt sie — sonst ist es ein geplanter Übungstag.
        raus.add(Tag(
          datum: iso,
          lektion: letzte,
          uebung: true,
          fehlt: Zyklus.istLektionstag(d.start, iso),
        ));
      }
    }
    return raus.reversed.toList(); // neueste zuerst
  }
}
