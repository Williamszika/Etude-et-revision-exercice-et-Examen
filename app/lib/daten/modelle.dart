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
  });

  /// Tag, an dem `build.py` die Datei geschrieben hat.
  final String stand;

  /// Erster Lektionstag der Etappe — alles rechnet ab hier.
  final String start;
  final int lektionenGesamt;
  final int themenGesamt;
  final String etappeEnde;

  /// Neueste zuerst, genau wie im Web-Template.
  final List<Lektion> lektionen;

  static Daten ausJson(Map<String, dynamic> j) => Daten(
        stand: (j['stand'] ?? '') as String,
        start: (j['start'] ?? '2026-09-11') as String,
        lektionenGesamt: (j['lektionenGesamt'] ?? 72) as int,
        themenGesamt: (j['themenGesamt'] ?? 29) as int,
        etappeEnde: (j['etappeEnde'] ?? '2027-01-31') as String,
        lektionen: ((j['lektionen'] ?? const []) as List)
            .whereType<Map<String, dynamic>>()
            .map(Lektion.new)
            .toList(),
      );

  static final Daten leer = Daten(
    stand: '',
    start: '2026-09-11',
    lektionenGesamt: 72,
    themenGesamt: 29,
    etappeEnde: '2027-01-31',
    lektionen: const [],
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
