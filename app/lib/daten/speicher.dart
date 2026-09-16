import 'package:shared_preferences/shared_preferences.dart';

/// Was die App sich merkt: welche Vokabel sie kann, was sie in ein Feld
/// geschrieben hat, welches Tempo sie beim Diktat mag.
///
/// Wichtig — und genauso wie auf der Webseite: Die Antworten hängen am
/// **Datum des angezeigten Tages**, nicht an der Lektion. Ein Übungstag hat
/// damit eigene, leere Felder, auch wenn er die Übungen von vorgestern zeigt.
/// Genau darum hatte sie auf der Webseite gebeten.
class Speicher {
  Speicher._(this._p);
  final SharedPreferences _p;

  static Speicher? _ich;
  static Speicher get ich {
    final s = _ich;
    if (s == null) {
      throw StateError('Speicher.starten() muss vor der ersten Nutzung laufen.');
    }
    return s;
  }

  static Future<void> starten() async {
    _ich = Speicher._(await SharedPreferences.getInstance());
  }

  // --- Antworten in Textfeldern ------------------------------------------

  String antwort(String datum, String feld) =>
      _p.getString('a·$datum·$feld') ?? '';

  Future<void> antwortSetzen(String datum, String feld, String wert) async {
    final k = 'a·$datum·$feld';
    if (wert.trim().isEmpty) {
      await _p.remove(k);
    } else {
      await _p.setString(k, wert);
    }
  }

  // --- Vokabeln: ✓ gewusst ------------------------------------------------
  //
  // Der Haken hängt am Wort selbst, nicht am Tag — ein Wort, das sie kann,
  // kann sie auch in der Wiederholung. Das ist der Unterschied zu den
  // Antwortfeldern oben, und er ist Absicht.

  bool gewusst(String wort) => _p.getBool('v·${_kurz(wort)}') ?? false;

  Future<void> gewusstSetzen(String wort, bool wert) async {
    final k = 'v·${_kurz(wort)}';
    if (wert) {
      await _p.setBool(k, true);
    } else {
      await _p.remove(k);
    }
  }

  int gewussteVon(List<String> woerter) =>
      woerter.where(gewusst).length;

  // --- Einstellungen ------------------------------------------------------

  double get tempo => _p.getDouble('tempo') ?? 0.45;
  Future<void> tempoSetzen(double v) => _p.setDouble('tempo', v);

  /// Rohdaten der letzten erfolgreichen Abholung — damit die App auch im
  /// Funkloch etwas anzeigt. Auf der Station ist das der Normalfall.
  String? get zwischenspeicher => _p.getString('daten');
  Future<void> zwischenspeicherSetzen(String json) =>
      _p.setString('daten', json);

  String _kurz(String s) {
    final sauber = s.replaceAll(RegExp(r'[^a-zA-ZäöüÄÖÜß0-9]'), '');
    return sauber.length <= 40 ? sauber : sauber.substring(0, 40);
  }
}
