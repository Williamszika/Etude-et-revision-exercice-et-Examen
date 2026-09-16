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
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Speicher.starten();
  final daten = await Quelle.sofort();
  runApp(DeutschTaeglich(daten: daten));
}

class DeutschTaeglich extends StatelessWidget {
  const DeutschTaeglich({super.key, required this.daten});
  final Daten daten;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Deutsch täglich',
        debugShowCheckedModeBanner: false,
        theme: Stil.thema(Brightness.light),
        darkTheme: Stil.thema(Brightness.dark),
        // Das Telefon entscheidet. Sie arbeitet im Schichtdienst — nachts
        // will niemand eine weiße Seite ins Gesicht.
        themeMode: ThemeMode.system,
        home: StartSeite(daten: daten),
      );
}
