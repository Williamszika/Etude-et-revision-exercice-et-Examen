import 'package:shared_preferences/shared_preferences.dart';

/// Was die App sich merkt: welche Vokabel sie kann, was sie in ein Feld
/// geschrieben hat, welches Tempo sie beim Diktat mag.
///
/// Wichtig — und genauso wie auf der Webseite: Die Antworten hängen am
/// **Datum des angezeigten Tages**, nicht an der Lektion. Ein Übungstag hat
/// damit eigene, leere Felder, auch wenn er die Übungen von vorgestern zeigt.
/// Genau darum hatte sie auf der Webseite gebeten.
///
/// **Nichts hier darf die App umbringen.** Am 16.09.2026 blieb die iPhone-App
/// beim ersten Start weiß: `main()` wartete auf `SharedPreferences`, und wenn
/// das auf dem Gerät schiefgeht, wird `runApp` nie erreicht — kein Bild, keine
/// Meldung. Deshalb hat der Speicher jetzt einen Notbetrieb im Arbeitsspeicher.
/// Dann sind die Haken nach dem Schließen weg, aber **die App läuft**. Lernen
/// ohne gespeicherte Haken ist besser als ein weißer Bildschirm.
class Speicher {
  Speicher._(this._p);

  /// Null, wenn das Gerät keine Einstellungen liefert. Dann greift `_ersatz`.
  final SharedPreferences? _p;

  /// Notbetrieb: hält dieselben Werte, aber nur bis zum Schließen der App.
  static final Map<String, Object> _ersatz = {};

  /// Ob der Speicher wirklich auf dem Gerät liegt. Die Oberfläche kann das
  /// anzeigen, statt so zu tun, als wäre alles in Ordnung.
  static bool get haeltDurch => _ich?._p != null;

  static Speicher? _ich;

  /// Greift auch dann, wenn `starten()` nie lief oder fehlgeschlagen ist —
  /// dann eben im Notbetrieb.
  static Speicher get ich => _ich ??= Speicher._(null);

  static Future<void> starten() async {
    try {
      _ich = Speicher._(await SharedPreferences.getInstance());
    } catch (_) {
      _ich = Speicher._(null);
    }
  }

  // --- die zwei Zugriffe, über die alles andere läuft ---------------------

  String? _lies(String k) {
    final p = _p;
    if (p != null) {
      try {
        return p.getString(k);
      } catch (_) {/* weiter unten */}
    }
    final v = _ersatz[k];
    return v is String ? v : null;
  }

  Future<void> _schreib(String k, String? wert) async {
    final p = _p;
    if (wert == null) {
      _ersatz.remove(k);
      if (p != null) {
        try {
          await p.remove(k);
        } catch (_) {}
      }
      return;
    }
    _ersatz[k] = wert;
    if (p != null) {
      try {
        await p.setString(k, wert);
      } catch (_) {}
    }
  }

  // --- Antworten in Textfeldern ------------------------------------------

  String antwort(String datum, String feld) => _lies('a·$datum·$feld') ?? '';

  Future<void> antwortSetzen(String datum, String feld, String wert) =>
      _schreib('a·$datum·$feld', wert.trim().isEmpty ? null : wert);

  // --- Vokabeln: ✓ gewusst ------------------------------------------------
  //
  // Der Haken hängt am Wort selbst, nicht am Tag — ein Wort, das sie kann,
  // kann sie auch in der Wiederholung. Das ist der Unterschied zu den
  // Antwortfeldern oben, und er ist Absicht.

  bool gewusst(String wort) => _lies('v·${_kurz(wort)}') == '1';

  Future<void> gewusstSetzen(String wort, bool wert) =>
      _schreib('v·${_kurz(wort)}', wert ? '1' : null);

  int gewussteVon(List<String> woerter) => woerter.where(gewusst).length;

  // --- Einstellungen ------------------------------------------------------

  double get tempo => double.tryParse(_lies('tempo') ?? '') ?? 0.45;
  Future<void> tempoSetzen(double v) => _schreib('tempo', '$v');

  /// Rohdaten der letzten erfolgreichen Abholung — damit die App auch im
  /// Funkloch etwas anzeigt. Auf der Station ist das der Normalfall.
  String? get zwischenspeicher => _lies('daten');
  Future<void> zwischenspeicherSetzen(String json) => _schreib('daten', json);

  String _kurz(String s) {
    final sauber = s.replaceAll(RegExp(r'[^a-zA-ZäöüÄÖÜß0-9]'), '');
    return sauber.length <= 40 ? sauber : sauber.substring(0, 40);
  }
}
