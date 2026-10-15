/// Modelle für Deutsch täglich.
///
/// Bewusst leichtgewichtig: Eine Lektion ist im Kern eine `Map`, und die
/// Klassen hier sind nur typisierte Sichten darauf. Der Grund ist praktisch —
/// die Lektionen werden jeden zweiten Morgen um 5:30 neu geschrieben, und das
/// Schema wächst mit. Eine starre Klasse würde bei jedem neuen Feld brechen;
/// so wird ein unbekannter Block einfach nicht gerendert, statt die App
/// abstürzen zu lassen.
library;

class Daten {
  Daten({
    required this.stand,
    required this.start,
    required this.lektionenGesamt,
    required this.themenGesamt,
    required this.etappeEnde,
    required this.lektionen,
    this.ruhetag = 7,
    this.proThema = 3,
    this.durchgaenge = 2,
    this.pausen = const [],
  });

  /// Tag, an dem `build.py` die Datei geschrieben hat.
  final String stand;

  /// Erster Lektionstag der Etappe — alles rechnet ab hier.
  final String start;
  final int lektionenGesamt;
  final int themenGesamt;
  final String etappeEnde;

  /// Seit dem Neustart am 16.10.2026: Lektion Montag bis Samstag, der
  /// Ruhetag ist ein Dart-Wochentag (7 = Sonntag).
  final int ruhetag;

  /// Lektionen pro Grammatikthema (1 entdecken · 2 üben · 3 anwenden).
  final int proThema;

  /// Wie oft das ganze Programm durchläuft — seit dem 15.10.2026 zweimal.
  final int durchgaenge;

  /// Pausen aus `pausen.json`: `{von, bis, zaehlt?}`.
  final List<Map<String, dynamic>> pausen;

  /// Neueste zuerst, genau wie im Web-Template.
  final List<Lektion> lektionen;

  static Daten ausJson(Map<String, dynamic> j) => Daten(
        stand: (j['stand'] ?? '') as String,
        start: (j['start'] ?? '2026-10-16') as String,
        lektionenGesamt: (j['lektionenGesamt'] ?? 186) as int,
        themenGesamt: (j['themenGesamt'] ?? 29) as int,
        etappeEnde: (j['etappeEnde'] ?? '2027-05-20') as String,
        ruhetag: (j['ruhetag'] ?? 7) as int,
        proThema: (j['proThema'] ?? 3) as int,
        durchgaenge: (j['durchgaenge'] ?? 2) as int,
        pausen: ((j['pausen'] is List) ? j['pausen'] as List : const [])
            .whereType<Map<String, dynamic>>()
            .toList(),
        lektionen: ((j['lektionen'] ?? const []) as List)
            .whereType<Map<String, dynamic>>()
            .map(Lektion.new)
            .toList(),
      );

  static final Daten leer = Daten(
    stand: '',
    start: '2026-10-16',
    lektionenGesamt: 186,
    themenGesamt: 29,
    etappeEnde: '2027-05-20',
    lektionen: const [],
  );

  /// Die Taktregeln, mit denen `Zyklus` rechnet.
  Takt get takt => Takt(
        start: start,
        ruhetag: ruhetag,
        proThema: proThema,
        themenGesamt: themenGesamt,
        durchgaenge: durchgaenge,
        pausen: pausen,
      );

  /// Die Lektion zu einem Datum, oder null.
  Lektion? amTag(String datum) {
    for (final l in lektionen) {
      if (l.datum == datum) return l;
    }
    return null;
  }

  /// Die letzte Lektion, die an oder vor diesem Datum liegt.
  /// Genau das braucht ein Übungstag: Er zeigt die Übungen der Lektion davor.
  Lektion? letzteVor(String datum) {
    for (final l in lektionen) {
      if (l.datum.compareTo(datum) <= 0) return l;
    }
    return null;
  }
}

class Lektion {
  Lektion(this.roh);
  final Map<String, dynamic> roh;

  String get datum => (roh['datum'] ?? '') as String;
  String get thema => (roh['thema'] ?? '') as String;

  Map<String, dynamic> get zyklus => _map(roh['zyklus']);

  /// Ein Block, oder null, wenn es ihn in dieser Lektion nicht gibt.
  Map<String, dynamic>? block(String name) {
    final v = roh[name];
    if (v is Map<String, dynamic> && v.isNotEmpty) return v;
    return null;
  }

  bool hat(String name) => block(name) != null;
}

// --- kleine Helfer, damit das JSON-Gestochere nicht überall steht ----------

Map<String, dynamic> _map(Object? v) =>
    v is Map<String, dynamic> ? v : <String, dynamic>{};

Map<String, dynamic> mapVon(Object? v) => _map(v);

String textVon(Object? v) => v is String ? v : '';

List<String> listeVon(Object? v) =>
    v is List ? v.whereType<String>().toList() : const [];

List<Map<String, dynamic>> zeilenVon(Object? v) =>
    v is List ? v.whereType<Map<String, dynamic>>().toList() : const [];

int? zahlVon(Object? v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

/// Die Regeln des Takts, so wie `deutsch-taeglich/heute.py` sie rechnet.
///
/// Seit dem Neustart am 16.10.2026: eine Lektion an jedem Tag außer dem
/// Ruhetag (Sonntag) und außer Pausentagen; drei Lektionen pro Thema; das
/// ganze Programm zweimal (ihre Wahl vom 15.10.2026), danach Wiederholung.
class Takt {
  const Takt({
    required this.start,
    this.ruhetag = 7,
    this.proThema = 3,
    this.themenGesamt = 29,
    this.durchgaenge = 2,
    this.pausen = const [],
  });

  final String start;
  final int ruhetag;
  final int proThema;
  final int themenGesamt;
  final int durchgaenge;
  final List<Map<String, dynamic>> pausen;

  /// Lektionen in einem Durchgang (29 × 3 = 87).
  int get proDurchgang => themenGesamt * proThema;

  /// Ab dieser Lektion ist alles Wiederholung (2 × 87 = 174 → ab 175).
  int get grammatikLektionen => proDurchgang * durchgaenge;
}
