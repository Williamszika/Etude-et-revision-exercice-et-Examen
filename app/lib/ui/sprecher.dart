import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../daten/speicher.dart';
import 'stil.dart';

/// Die deutsche Stimme des Telefons.
///
/// Das ist der eigentliche Grund für eine App statt nur der Webseite: Das
/// Telefon hat eine **offline** deutsche Stimme eingebaut. Kein Netz nötig,
/// keine Guthaben, kein Konto — und das Diktat ist genau das Training, das sie
/// am nötigsten braucht („Je dois etre fort en dictee").
class Sprecher {
  Sprecher._();
  static final Sprecher ich = Sprecher._();

  final FlutterTts _tts = FlutterTts();
  bool _bereit = false;

  /// Läuft gerade etwas? Daran hängen die Knöpfe in der Oberfläche.
  final ValueNotifier<bool> laeuft = ValueNotifier(false);

  /// Warum nichts zu hören war — auf Französisch, direkt anzeigbar.
  /// `null` heißt: alles in Ordnung.
  final ValueNotifier<String?> problem = ValueNotifier(null);

  /// **Zwei Dinge, an denen es am 16.09.2026 auf ihrem iPhone scheiterte.**
  ///
  /// 1. **Die Tonsitzung.** Ohne `setSharedInstance` und die Kategorie
  ///    `playback` schweigt iOS, sobald der kleine Schalter an der Seite auf
  ///    lautlos steht — und bei ihr stand er so. `playback` ist genau die
  ///    Kategorie, die trotzdem spielt, wie bei einer Musik-App.
  /// 2. **Die deutsche Stimme.** Ist sie nicht geladen, tut `speak()` gar
  ///    nichts und meldet auch nichts. Das prüft `_stimmeFehlt()` bei jedem
  ///    Versuch, damit sie eine Erklärung sieht statt nur Stille.
  Future<void> _vorbereiten() async {
    if (_bereit) return;

    try {
      await _tts.setSharedInstance(true);
      // Nur Optionen, die AVAudioSession mit `playback` auch erlaubt.
      // `defaultToSpeaker` gehört zu `playAndRecord`; zusammen mit `playback`
      // lehnt iOS den ganzen Aufruf ab — und dann bliebe es wieder still.
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [IosTextToSpeechAudioCategoryOptions.duckOthers],
        IosTextToSpeechAudioMode.defaultMode,
      );
    } catch (_) {
      // Auf Android gibt es beides nicht. Kein Grund, hier abzubrechen.
    }

    await _tts.setLanguage('de-DE');
    await _tts.setVolume(1);
    await _tts.setPitch(1);
    await _tts.awaitSpeakCompletion(true);
    _tts.setCompletionHandler(() => laeuft.value = false);
    _tts.setCancelHandler(() => laeuft.value = false);
    _tts.setErrorHandler((e) {
      laeuft.value = false;
      problem.value = 'La voix a échoué : $e';
    });

    _bereit = true;
  }

  /// Ist die deutsche Stimme da? Wird bei **jedem** Versuch neu gefragt — sie
  /// kann sie ja zwischendurch herunterladen, und dann soll die App nicht auf
  /// einer alten Beschwerde sitzen bleiben.
  Future<String?> _stimmeFehlt() async {
    try {
      final da = await _tts.isLanguageAvailable('de-DE');
      if (da == true) return null;
    } catch (_) {
      return null; // Auskunft verweigert — dann eben versuchen.
    }
    return "La voix allemande n'est pas installée sur le téléphone.\n"
        'Réglages → Accessibilité → Contenu énoncé → Voix → Deutsch';
  }

  /// Einen Satz oder Text vorlesen. `tempo` 0.0 … 1.0.
  /// Gibt zurück, was schiefging — `null`, wenn gesprochen wurde.
  Future<String?> sprich(String text, {double? tempo}) async {
    final sauber = _ohneSterne(text).trim();
    if (sauber.isEmpty) return null;
    problem.value = null;
    await _vorbereiten();
    final fehlt = await _stimmeFehlt();
    // Auch wenn die Stimme fehlt: trotzdem sprechen lassen. Manche Geräte
    // melden „nein“ und reden dann doch. Gemeldet wird es hinterher.
    await _tts.stop();
    await _tts.setSpeechRate(tempo ?? Speicher.ich.tempo);
    laeuft.value = true;
    await _tts.speak(sauber);
    laeuft.value = false;
    return problem.value ?? fehlt;
  }

  Future<void> stopp() async {
    await _tts.stop();
    laeuft.value = false;
  }

  /// Fürs Diktat: Satz für Satz, mit Pause dazwischen, und zweimal durch.
  /// Genauso läuft es auf der Webseite, und genauso läuft eine echte Ansage.
  /// Gibt zurück, was schiefging — `null`, wenn gesprochen wurde.
  Future<String?> diktieren(
    List<String> saetze, {
    required double tempo,
    required bool Function() abgebrochen,
    void Function(int satz, int durchgang)? beiSatz,
    int durchgaenge = 2,
  }) async {
    problem.value = null;
    await _vorbereiten();
    final fehlt = await _stimmeFehlt();
    laeuft.value = true;
    for (var d = 1; d <= durchgaenge; d++) {
      for (var i = 0; i < saetze.length; i++) {
        if (abgebrochen()) {
          laeuft.value = false;
          return null;
        }
        beiSatz?.call(i, d);
        await _tts.setSpeechRate(tempo);
        await _tts.speak(_ohneSterne(saetze[i]));
        await Future<void>.delayed(const Duration(milliseconds: 900));
      }
      if (d < durchgaenge) {
        await Future<void>.delayed(const Duration(milliseconds: 1400));
      }
    }
    laeuft.value = false;
    return problem.value ?? fehlt;
  }

  static String _ohneSterne(String s) =>
      s.replaceAll('**', '').replaceAll('*', '');
}

/// Kleiner runder Vorlese-Knopf, wie er auf der Webseite neben jedem Satz steht.
class HoerKnopf extends StatelessWidget {
  const HoerKnopf(this.text, {super.key, this.farbe, this.groesse = 18});

  final String text;
  final Color? farbe;
  final double groesse;

  @override
  Widget build(BuildContext context) {
    final f = farbe ?? Stil.akzentFarbe(context);
    return IconButton(
      onPressed: () async {
        final klage = await Sprecher.ich.sprich(text);
        // Stille ohne Erklärung ist das Schlimmste — dann sucht sie den Fehler
        // bei sich statt bei den Einstellungen des Telefons.
        if (klage != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(klage), duration: const Duration(seconds: 6)),
          );
        }
      },
      icon: Icon(Icons.volume_up_rounded, size: groesse, color: f),
      tooltip: 'Vorlesen',
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
    );
  }
}
