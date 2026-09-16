# Deutsch täglich — die App

Dieselben Lektionen wie auf der Webseite, nur als Android-App.

## Was sie zusätzlich kann

| | |
|---|---|
| **Offline** | Einmal geladen, läuft alles ohne Netz weiter — im Zug, im Keller der Station, im Nachtdienst. |
| **Die deutsche Stimme des Telefons** | Diktat, Vorlesen und Aussprache brauchen kein Guthaben, kein Konto und kein Netz. |
| **Sie merkt sich alles** | Welche Vokabel sitzt, was in welchem Feld steht, welches Tempo beim Diktat. |

## Woher die Lektionen kommen

Die App holt beim Start **`deutsch-taeglich/app-daten.json`** aus diesem Repo
(GitHub raw). Diese Datei schreibt `deutsch-taeglich/build.py` bei jedem Lauf neu.

**Daraus folgt: Eine neue Lektion braucht keine neue App-Version.** Die
5:30-Routine committet sie, und die App hat sie beim nächsten Öffnen. Neu gebaut
wird die App nur, wenn sich die App selbst ändert.

Fällt das Netz aus, zeigt sie die zuletzt geladene Fassung. Beim allerersten
Start ohne Netz greift `assets/lektionen.json`, die beim Bau mitgeliefert wird.

## Aufbau

```
lib/
  main.dart              Start
  daten/modelle.dart     Lektion und Daten — bewusst lose typisiert
  daten/quelle.dart      Netz, Zwischenspeicher, Asset — in dieser Reihenfolge
  daten/speicher.dart    was auf dem Gerät bleibt
  logik/zyklus.dart      die Rechnung: Lektionstag, Übungstag, Themenblock
  ui/stil.dart           Farben, beide Themen, **fett** aus dem JSON
  ui/schau.dart          Canvas: Ring, Themenband, Konfetti, Zähler
  ui/teile.dart          Bausteine: Karte, Etikett, Antwortfeld, Lösung
  ui/bloecke.dart        Verb, Vokabeln, Leben, Kette, Aufgaben, Übersetzung
  ui/bloecke_lesen.dart  Lesetext und Diktat
  ui/start_seite.dart    Fortschrittskopf und Tagesleiste
  ui/tag_seite.dart      ein Tag
test/zyklus_test.dart    die Rechnung — das, was still falsch sein könnte
```

## Selbst bauen

```bash
cd app
flutter pub get
flutter analyze && flutter test
flutter build apk --release
# -> build/app/outputs/flutter-apk/app-release.apk
```

## Die fertige APK bekommen, ohne Flutter

`.github/workflows/app-bauen.yml` baut sie bei jeder Änderung an `app/`.
Auf GitHub: **Actions → App bauen → letzter Lauf → Artifacts →
`deutsch-taeglich-apk`**.

Zum Installieren muss auf dem Telefon einmal
*Einstellungen → Apps → Unbekannte Apps installieren* für den Browser oder die
Dateien-App erlaubt werden. Die APK ist mit dem Debug-Schlüssel signiert —
das reicht zum Selbstinstallieren, aber nicht für den Play Store.

## iPhone

Das iOS-Gerüst liegt in `ios/`. **Gebaut wird auf ihrem Mac** — Apple lässt das
nirgends sonst zu, und signieren geht nur mit ihrem eigenen Apple-Konto.

Die Anleitung dafür steht in **[`IPHONE.md`](IPHONE.md)**, auf Französisch und
Schritt für Schritt: Flutter einrichten, Konto in Xcode eintragen, Telefon
anstecken, `flutter run --release`, Zertifikat freigeben.

Dass der Code für iOS **kompiliert**, prüft der Job `iphone` in
`.github/workflows/app-bauen.yml` bei jeder Änderung auf einem Mac bei GitHub.
Ist der grün und es klemmt trotzdem, liegt es an Xcode oder der Signatur.

Mit einem **kostenlosen** Apple-Konto läuft die App **7 Tage**, dann muss sie neu
aufgespielt werden (zwei Minuten). Mit dem bezahlten Konto ein Jahr. Ihre Haken
und Antworten bleiben in beiden Fällen — die liegen im Telefon, nicht in der App.

## Was noch fehlt
- **Die Probeprüfung** hat noch keine Zeitsperre wie auf der Webseite
  (dort ist sie bis Samstag 22:00 zu).
- **Die Original-Audiodateien** der telc-Hörverstehen-Seite sind nicht dabei;
  das Diktat läuft über die Stimme des Telefons.
