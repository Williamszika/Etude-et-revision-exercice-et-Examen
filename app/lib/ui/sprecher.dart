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

  Future<void> _vorbereiten() async {
    if (_bereit) return;
    await _tts.setLanguage('de-DE');
    await _tts.setVolume(1);
    await _tts.setPitch(1);
    await _tts.awaitSpeakCompletion(true);
    _tts.setCompletionHandler(() => laeuft.value = false);
    _tts.setCancelHandler(() => laeuft.value = false);
    _tts.setErrorHandler((_) => laeuft.value = false);
    _bereit = true;
  }

  /// Einen Satz oder Text vorlesen. `tempo` 0.0 … 1.0.
  Future<void> sprich(String text, {double? tempo}) async {
    final sauber = _ohneSterne(text).trim();
    if (sauber.isEmpty) return;
    await _vorbereiten();
    await _tts.stop();
    await _tts.setSpeechRate(tempo ?? Speicher.ich.tempo);
    laeuft.value = true;
    await _tts.speak(sauber);
    laeuft.value = false;
  }

  Future<void> stopp() async {
    await _tts.stop();
    laeuft.value = false;
  }

  /// Fürs Diktat: Satz für Satz, mit Pause dazwischen, und zweimal durch.
  /// Genauso läuft es auf der Webseite, und genauso läuft eine echte Ansage.
  Future<void> diktieren(
    List<String> saetze, {
    required double tempo,
    required bool Function() abgebrochen,
    void Function(int satz, int durchgang)? beiSatz,
    int durchgaenge = 2,
  }) async {
    await _vorbereiten();
    laeuft.value = true;
    for (var d = 1; d <= durchgaenge; d++) {
      for (var i = 0; i < saetze.length; i++) {
        if (abgebrochen()) {
          laeuft.value = false;
          return;
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
      onPressed: () => Sprecher.ich.sprich(text),
      icon: Icon(Icons.volume_up_rounded, size: groesse, color: f),
      tooltip: 'Vorlesen',
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
    );
  }
}
