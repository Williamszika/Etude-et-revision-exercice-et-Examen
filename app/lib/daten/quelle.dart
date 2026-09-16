import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import 'modelle.dart';
import 'speicher.dart';

/// Woher die Lektionen kommen.
///
/// Drei Stufen, in dieser Reihenfolge:
///   1. **Zwischenspeicher** — sofort da, auch ohne Netz. Wird zuerst gezeigt.
///   2. **Netz** (GitHub raw) — holt `app-daten.json` und ersetzt den Rest.
///   3. **Asset** — die Fassung, die beim App-Bau mitgeliefert wurde. Greift
///      nur beim allerersten Start ohne Netz.
///
/// Der Punkt an Stufe 2: Die 5:30-Routine committet jede neue Lektion ins
/// Repo. Die App holt sie sich von dort — **es muss also keine neue
/// App-Version gebaut werden**, damit eine neue Lektion ankommt.
class Quelle {
  static const zweig = 'claude/nursing-exam-prep-workflow-gvn5u0';
  static const url =
      'https://raw.githubusercontent.com/Williamszika/'
      'Etude-et-revision-exercice-et-Examen/$zweig/deutsch-taeglich/app-daten.json';

  /// Was sofort angezeigt werden kann, ohne auf das Netz zu warten.
  static Future<Daten> sofort() async {
    final gespeichert = Speicher.ich.zwischenspeicher;
    if (gespeichert != null) {
      final d = _lesen(gespeichert);
      if (d != null) return d;
    }
    try {
      final roh = await rootBundle.loadString('assets/lektionen.json');
      return _lesen(roh) ?? Daten.leer;
    } catch (_) {
      return Daten.leer;
    }
  }

  /// Holt die aktuelle Fassung. Gibt null zurück, wenn es nicht geklappt hat —
  /// dann bleibt einfach stehen, was schon da ist. Kein Fehlerdialog: Wenn sie
  /// im Zug oder im Keller der Station sitzt, will sie lernen, nicht lesen,
  /// dass das Netz weg ist.
  static Future<Daten?> holen() async {
    try {
      final antwort = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 12));
      if (antwort.statusCode != 200) return null;
      final roh = utf8.decode(antwort.bodyBytes);
      final d = _lesen(roh);
      if (d == null) return null;
      await Speicher.ich.zwischenspeicherSetzen(roh);
      return d;
    } catch (_) {
      return null;
    }
  }

  static Daten? _lesen(String roh) {
    try {
      final j = jsonDecode(roh);
      if (j is! Map<String, dynamic>) return null;
      final d = Daten.ausJson(j);
      return d.lektionen.isEmpty ? null : d;
    } catch (_) {
      return null;
    }
  }
}
