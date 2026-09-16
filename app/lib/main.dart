import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'daten/modelle.dart';
import 'daten/quelle.dart';
import 'daten/speicher.dart';
import 'ui/start_seite.dart';
import 'ui/stil.dart';

/// Deutsch täglich — die App.
///
/// Sie zeigt dieselben Lektionen wie die Webseite, holt sie aus demselben
/// Repo und rechnet mit derselben Formel. Was sie zusätzlich kann:
///
///  * **Offline.** Einmal geladen, läuft alles ohne Netz weiter — im Zug,
///    im Keller der Station, im Nachtdienst.
///  * **Die deutsche Stimme des Telefons.** Diktat, Vorlesen und Aussprache
///    brauchen kein Guthaben und kein Konto.
///  * **Sie merkt sich alles auf dem Gerät**: welche Vokabel sitzt, was in
///    welchem Feld steht, welches Tempo sie beim Diktat mag.
///
/// **Regel für diesen Start: `runApp` wird IMMER erreicht.**
/// Am 16.09.2026 blieb die iPhone-App beim ersten Versuch weiß. Der Grund war
/// hier: `main()` hat auf zwei Dinge gewartet, und wenn eines davon auf dem
/// Gerät wirft, kommt `runApp` nie dran — kein Bild, keine Meldung, nichts,
/// woran man sieht, was los ist. Deshalb steht jetzt jeder Startschritt in
/// seinem eigenen try/catch, und was schiefging, landet sichtbar auf dem
/// Bildschirm statt im Nichts.
void main() async {
  final klagen = <String>[];

  try {
    WidgetsFlutterBinding.ensureInitialized();
  } catch (e) {
    klagen.add('Start: $e');
  }

  try {
    await Speicher.starten();
  } catch (e) {
    klagen.add('Speicher: $e');
  }

  var daten = Daten.leer;
  try {
    daten = await Quelle.sofort();
  } catch (e) {
    klagen.add('Lektionen: $e');
  }

  // Ein Fehler beim Zeichnen soll die rote Meldung zeigen, nicht eine leere
  // Fläche — sonst steht sie wieder vor Weiß und weiß nichts damit anzufangen.
  ErrorWidget.builder = (details) => _Panne(
        text: kReleaseMode
            ? 'Beim Aufbauen dieser Stelle ist etwas schiefgegangen.'
            : details.exceptionAsString(),
      );

  runApp(DeutschTaeglich(daten: daten, klagen: klagen));
}

class DeutschTaeglich extends StatelessWidget {
  const DeutschTaeglich({
    super.key,
    required this.daten,
    this.klagen = const [],
  });

  final Daten daten;

  /// Was beim Start nicht geklappt hat. Leer heißt: alles gut.
  final List<String> klagen;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Deutsch täglich',
        debugShowCheckedModeBanner: false,
        theme: Stil.thema(Brightness.light),
        darkTheme: Stil.thema(Brightness.dark),
        // Das Telefon entscheidet. Sie arbeitet im Schichtdienst — nachts
        // will niemand eine weiße Seite ins Gesicht.
        themeMode: ThemeMode.system,
        home: klagen.isEmpty
            ? StartSeite(daten: daten)
            : _Panne(text: klagen.join('\n\n')),
      );
}

/// Was statt eines weißen Bildschirms erscheint, wenn der Start scheitert.
/// Auf Französisch, weil sie das im Zweifel schneller liest — und mit dem
/// technischen Text darunter, damit sie ihn abfotografieren kann.
class _Panne extends StatelessWidget {
  const _Panne({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          color: Stil.papier,
          padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 14),
                const Text(
                  'Deutsch täglich konnte nicht starten',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: Stil.tinte,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Fais une photo de ce texte et envoie-la moi — '
                  'il dit exactement ce qui a échoué.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Stil.tinteWeich,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Stil.karte,
                    border: Border.all(color: Stil.linie),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: SelectableText(
                    text,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      fontFamily: 'monospace',
                      color: Stil.tinte,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
