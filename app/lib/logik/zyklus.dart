import '../daten/modelle.dart';

/// Die Rechnung hinter Deutsch täglich — dieselbe wie `deutsch-taeglich/heute.py`,
/// nur in Dart.
///
/// **Neustart am 16.10.2026, seit dem 23.10.2026 jeden zweiten Tag** (ihre Wahl:
/// „une fois chaque deux jours“, das B1-Programm einmal, auch sonntags):
///
///     Lektionstag  = bis 23.10.2026: jeder Tag ab Start außer Sonntag
///                    ab 23.10.2026:  jeder zweite Tag, auch Sonntag
///                    — Pausentage nie, und verschiebende Pausen schieben den Takt
///     lektion      = Zahl der Lektionstage vom Start bis heute (1 … 99)
///     themaBlock   = (lektion − 1) ~/ 3 + 1
///     themenTag    = (lektion − 1) % 3 + 1   — entdecken · üben · anwenden
///     ab Lektion 88: Wiederholung bis zum 25.04.2027
///
/// Eine Pause mit `zaehlt: true` ist ein Tag ohne Lektion, verschiebt den Takt
/// aber nicht — wie in `heute.py`.
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

  static Map<String, dynamic>? _pause(Takt k, String datum) {
    for (final p in k.pausen) {
      final von = (p['von'] ?? '') as String, bis = (p['bis'] ?? '') as String;
      if (von.isNotEmpty && datum.compareTo(von) >= 0 && datum.compareTo(bis) <= 0) {
        return p;
      }
    }
    return null;
  }

  static bool istPause(Takt k, String datum) => _pause(k, datum) != null;

  /// Sonntag als Ruhetag gab es nur bis zum Wechsel am 23.10.2026.
  static bool istRuhetag(Takt k, String datum) =>
      tageZwischen(k.start, datum) >= 0 &&
      tageZwischen(datum, k.wechsel) >= 0 &&
      tagVon(datum).weekday == k.ruhetag;

  /// Verschiebende Pausentage im Bereich (von, bis].
  static int _verschiebendeTage(Takt k, String von, String bis) {
    var n = 0;
    for (final p in k.pausen) {
      if (p['zaehlt'] == true) continue;
      final a = (p['von'] ?? '') as String, b = (p['bis'] ?? '') as String;
      if (a.isEmpty || b.isEmpty) continue;
      final ab = von.compareTo(a) >= 0 ? isoVon(tagVon(von).add(const Duration(days: 1))) : a;
      final bisX = b.compareTo(bis) < 0 ? b : bis;
      final t = tageZwischen(ab, bisX);
      if (t >= 0) n += t + 1;
    }
    return n;
  }

  /// Heute gehört eine Lektion hin.
  static bool istLektionstag(Takt k, String datum) {
    if (tageZwischen(k.start, datum) < 0 || istPause(k, datum)) return false;
    if (tageZwischen(datum, k.wechsel) >= 0) {
      return tagVon(datum).weekday != k.ruhetag;
    }
    final t = tageZwischen(k.wechsel, datum) - _verschiebendeTage(k, k.wechsel, datum);
    return t % k.taktTage == 0;
  }

  /// Kein Lektionstag, aber nach dem Start (Tag dazwischen, Ruhetag oder Pause).
  static bool istUebungstag(Takt k, String datum) =>
      tageZwischen(k.start, datum) >= 0 && !istLektionstag(k, datum);

  /// Die Lektionsnummer an diesem Tag (Zahl der Lektionstage bis einschließlich
  /// heute), gedeckelt auf `gesamt`.
  static int lektionsNr(Takt k, String datum, int gesamt) {
    if (tageZwischen(k.start, datum) < 0) return 0;
    final ende = tagVon(datum);
    var n = 0;
    for (var x = tagVon(k.start); !x.isAfter(ende); x = x.add(const Duration(days: 1))) {
      if (istLektionstag(k, isoVon(x))) n++;
    }
    return n > gesamt ? gesamt : n;
  }

  static int blockVon(Takt k, int lektion) => lektion < 1
      ? 0
      : ((lektion - 1) ~/ k.proThema) % k.themenGesamt + 1;

  static int themenBlock(Takt k, String datum) =>
      blockVon(k, lektionsNr(k, datum, 1 << 30));

  static bool istWiederholung(Takt k, String datum) =>
      lektionsNr(k, datum, 1 << 30) > k.grammatikLektionen;

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
    this.ruhetag = false,
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

  /// 16.–23.10.2026: Sonntag war Ruhetag — keine Lektion geplant.
  final bool ruhetag;

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
        final k = d.takt;
        raus.add(Tag(
          datum: iso,
          lektion: letzte,
          uebung: true,
          fehlt: Zyklus.istLektionstag(k, iso),
          ruhetag: Zyklus.istRuhetag(k, iso),
        ));
      }
    }
    return raus.reversed.toList(); // neueste zuerst
  }
}
