# Arbeitsanweisungen für dieses Repo

Nutzerin: französischsprachige Pflegeauszubildende, 2. Lehrjahr, generalistische
Ausbildung, NRW. Erklärungen auf Französisch, Fachinhalte und Beispiele auf Deutsch.

**Grundregel für alles in diesem Repo:** nichts erfinden. Keine Paragraphen, Normen,
Zahlen oder Quellen nennen, die nicht in ihren eigenen Unterlagen (PDFs im Repo) stehen.

---

## Deutsch täglich — Routine 5:30 täglich, Probeprüfung Samstag 22:00

Diese Anweisung gilt **immer** und hat Vorrang vor älteren Routine-Texten.

### Das Ziel: telc Deutsch B2 im Februar 2027

Deutsch täglich ist **kein allgemeiner Sprachkurs mehr**, sondern die Vorbereitung auf die
Prüfung **telc Deutsch B2** im **Februar 2027**. Daraus folgt:

- Alle Themen liegen auf **B1/B2-Niveau**. Reine A2-Themen (einfache Fragen, Imperativ,
  Komparativ) gehören nicht mehr als eigenes Thema hierher — sie laufen in den Beispielen mit.
- **Jede** Lektion hat zusätzlich einen Block `telc` — Prüfungstraining im Prüfungsformat.
- Die Beispiele bleiben aus dem Pflegealltag (siehe unten). Das passt auch dann, wenn sie sich
  später für **telc Deutsch B2 Pflege** entscheidet.

### Das offizielle Prüfungsformat — Quelle im Repo

Das **Handbuch telc Deutsch B2** (telc gGmbH, 8. Auflage 2019) und der **Übungstest 1** samt
Audio liegen in `deutsch-taeglich/telc-quellen/`. **Alle Angaben zur Prüfung nur von dort
nehmen — nichts schätzen.** Referenzseite: `deutsch-taeglich/pruefung.html`
(`https://claude.ai/code/artifact/46864e04-1000-4201-8cf3-d76d6c889c1d`).

**300 Punkte gesamt** — Schriftliche Prüfung 225 (75 %), Mündliche Prüfung 75 (25 %).

| Subtest | Teile und Aufgabentypen | Zeit | Punkte | Anteil |
|---|---|---|---|---|
| 1 Leseverstehen | T1 Globalverstehen 5 Zuordnungen (5 P/Item) · T2 Detailverstehen 5 Multiple-Choice mit 3 Optionen (5 P) · T3 Selektives Verstehen 10 Zuordnungen (2,5 P) | 90 Min zusammen mit Subtest 2 | 75 | 25 % |
| 2 Sprachbausteine | T1 **Grammatik** 10 Multiple-Choice, 3 Optionen, Inputtext ist eine halbformelle/informelle **E-Mail oder ein Brief** (1,5 P) · T2 **Lexik** 10 Zuordnungen im Lückentext, Inputtext Zeitungsartikel (1,5 P) | — | 30 | 10 % |
| 3 Hörverstehen | T1 5 Richtig-Falsch (5 P) · T2 10 Richtig-Falsch (2,5 P) · T3 5 Richtig-Falsch (5 P) | ca. 20 Min | 75 | 25 % |
| 4 Schriftlicher Ausdruck | **eine halbformelle E-Mail** an Firma/Person/Büro als **Antwort auf eine Anzeige**, **vier Leitpunkte**, eine Aufgabe aus zwei zur Wahl, **mindestens 150 Wörter** | 30 Min | 45 | 15 % |
| 5 Mündlicher Ausdruck | T1 **Über Erfahrungen sprechen** (7 Themen zur Wahl, eines zu Hause vorbereitet, Monolog + Dialog) · T2 **Diskussion** über einen kontroversen Zeitungsartikel · T3 **Gemeinsam etwas planen** — je ca. 5 Min, je 25 P, Paarprüfung | 20 Min Vorbereitung, ca. 15 bzw. 25 Min | 75 | 25 % |

**Bestehen:** in **beiden** Prüfungsteilen getrennt 60 % — **135 von 225** schriftlich **und**
**45 von 75** mündlich. Noten: 270–300 sehr gut · 240–269,5 gut · 210–239,5 befriedigend ·
180–209,5 ausreichend · 0–179,5 nicht bestanden.

**Bewertungskriterien Schreiben:** 1. Berücksichtigung der Leitpunkte · 2. Kommunikative
Gestaltung · 3. Formale Richtigkeit.
**Bewertungskriterien Sprechen:** 1. Ausdrucksfähigkeit · 2. Aufgabenbewältigung ·
3. Formale Richtigkeit · 4. Aussprache und Intonation.

**Die 16 Prüfungsthemen (Anhang T):** Angaben zur eigenen Person · Der menschliche Körper,
Gesundheit und Körperpflege · Wohnen · Orte · Tägliches Leben · Essen und Trinken · Erziehung,
Ausbildung, Lernen · Arbeit und Beruf · Geschäfte, Handel, Konsum · Dienstleistungen · Natur und
Umwelt · Reise und Verkehr · Freizeit und Unterhaltung · Medien und moderne Informationstechniken ·
Gesellschaft, Staat, Regierung · Beziehungen zu anderen Menschen und Kulturen.

Pflegebeispiele sind **prüfungskonform** (Themen 2 und 8), aber die Lektionen müssen auch die
anderen vierzehn Themen streifen — besonders für die Diskussion in Teil 2 der Mündlichen Prüfung.

Artifact-URL (nie ändern): `https://claude.ai/code/artifact/e499dbe3-e198-410a-94d3-9393e6b27c84`
Favicon: 🇩🇪 — beim Republish **nicht** mitschicken.
Branch: `claude/nursing-exam-prep-workflow-gvn5u0`

### Regel 0 — nichts überschreiben

Wenn `deutsch-taeglich/lektionen/<HEUTIGES-DATUM>.json` **schon existiert**:
diese Datei **nicht** anfassen und keine neue Lektion schreiben.
Nur `python3 deutsch-taeglich/build.py` ausführen, veröffentlichen, fertig.

### Ablauf

1. `ls deutsch-taeglich/lektionen/`, die **neueste** Lektion lesen.
   Ihr Block `zyklus` sagt, wo wir stehen: `{woche, gesamt: 16, thema, themaNr, tag, fokus,
   start, bisPruefung}`.
2. Neuen Zustand aus dem **heutigen Datum** berechnen — nicht hochzählen, sondern rechnen:
   - `woche` = ganze Wochen seit dem 31.08.2026, plus 1
   - `tag` = heutiger Wochentag auf Deutsch, `fokus` = der Subtest dieses Tages (Tabelle unten)
   - `thema` und `themaNr` = das telc-Thema dieser Woche (Tabelle unten)
   - `bisPruefung` = Tage bis zum 01.02.2027
   - Ab Woche 17 (21.12.2026): **Endspurt**, `thema` = „Endspurt · Prüfungstraining",
     `themaNr` weglassen
3. `deutsch-taeglich/lektionen/<YYYY-MM-DD>.json` schreiben — Struktur **exakt** wie in
   der neuesten vorhandenen Lektion (gleiche Block- und Feldnamen, nur neuer Inhalt).
4. `python3 deutsch-taeglich/build.py`
5. Veröffentlichen: erst `Artifact` mit `action:"read"` auf die URL oben (sonst wird der
   Publish als veraltet abgelehnt), dann publish mit `file_path deutsch-taeglich/index.html`
   und derselben `url`.
6. `git add -A && git commit && git pull --rebase origin <branch> && git push -u origin <branch>`

### Der Wochenrhythmus — kein Grammatik-Zyklus mehr

**Die alten 13 Grammatikthemen sind abgeschafft.** Deutsch täglich folgt jetzt der Prüfung
selbst. Jede Woche gehört **einem der 16 telc-Themen aus Anhang T**, und jeder Wochentag
gehört **einem Subtest**:

| Tag | Fokus | Warum |
|-----|-------|-------|
| **Montag** | Leseverstehen | 25 % — ein Text im Prüfungsformat, Teil 1, 2 oder 3 im Wechsel |
| **Dienstag** | Hörverstehen | 25 % — Diktat als Hörtext, dazu **Richtig-Falsch-Aufgaben** |
| **Mittwoch** | Sprachbausteine | 10 % — Grammatik der Woche + Lexik, beides im Lückentext |
| **Donnerstag** | Schriftlicher Ausdruck | 15 % — halbformelle E-Mail, Redemittel und Leitpunkte |
| **Freitag** | Mündlicher Ausdruck | 25 % — Teil 1, 2 oder 3 im Wechsel |
| **Samstag 22:00** | **Probeprüfung** | eigene Routine, siehe unten |
| **Sonntag** | Auswertung und Wiederholung | Fehler der Woche, Wortschatz nachziehen, leichter Tag |

Der Block `zyklus` sieht ab Woche 1 so aus:

```json
"zyklus": {"woche": 1, "gesamt": 16, "thema": "Angaben zur eigenen Person",
           "themaNr": 1, "tag": "Montag", "fokus": "Leseverstehen",
           "start": "2026-08-31", "bisPruefung": 154}
```

`bisPruefung` = Tage bis zum 01.02.2027, jeden Tag neu ausrechnen.

### Die 16 Wochen — ein telc-Thema pro Woche

Start: **Montag, 31.08.2026.** Reihenfolge = Anhang T des Handbuchs.

| Woche | Zeitraum | Thema |
|---|---|---|
| 1 | 31.08.–06.09. | T1 Angaben zur eigenen Person |
| 2 | 07.09.–13.09. | T2 Der menschliche Körper, Gesundheit und Körperpflege |
| 3 | 14.09.–20.09. | T3 Wohnen |
| 4 | 21.09.–27.09. | T4 Orte |
| 5 | 28.09.–04.10. | T5 Tägliches Leben |
| 6 | 05.10.–11.10. | T6 Essen und Trinken |
| 7 | 12.10.–18.10. | T7 Erziehung, Ausbildung, Lernen |
| 8 | 19.10.–25.10. | T8 Arbeit und Beruf |
| 9 | 26.10.–01.11. | T9 Geschäfte, Handel, Konsum |
| 10 | 02.11.–08.11. | T10 Dienstleistungen |
| 11 | 09.11.–15.11. | T11 Natur und Umwelt |
| 12 | 16.11.–22.11. | T12 Reise und Verkehr |
| 13 | 23.11.–29.11. | T13 Freizeit und Unterhaltung |
| 14 | 30.11.–06.12. | T14 Medien und moderne Informationstechniken |
| 15 | 07.12.–13.12. | T15 Gesellschaft, Staat, Regierung |
| 16 | 14.12.–20.12. | T16 Beziehungen zu anderen Menschen und Kulturen |

Ab **21.12.2026** bis zur Prüfung: **Endspurt**, sechs Wochen. Keine neuen Themen mehr,
sondern ganze Prüfungsteile unter Zeit, Wiederholung der schwächsten Subtests laut den
Probeprüfungen, und jede Woche eine vollständige E-Mail in 30 Minuten mit Uhr.

**Wichtig:** Pflegebeispiele sind erlaubt und sogar prüfungskonform, aber sie dürfen die Woche
nicht kapern. In der Woche „Natur und Umwelt" geht es um Natur und Umwelt — nicht um die
Station. Sie braucht Wortschatz aus **allen sechzehn** Bereichen, besonders für die Diskussion
in Teil 2 der Mündlichen Prüfung.

### Grammatik — jetzt Mittwochsthema, nicht mehr Rückgrat

Die B2-Grammatik läuft weiter, aber als **Sprachbausteine-Thema des Mittwochs**, eines pro
Woche, in dieser Reihenfolge:

1. Verbstellung und Satzklammer · 2. Nebensätze (weil, obwohl, damit, dass, wenn/als) ·
3. Relativsätze, auch mit Präposition und was/wo · 4. Konnektoren (kausal, konzessiv,
konsekutiv, final, adversativ) · 5. Zweiteilige Konnektoren · 6. Passiv in allen Zeiten und
mit Modalverben · 7. Passiversatzformen (sein + zu, sich lassen, -bar, man) ·
8. Konjunktiv II · 9. Konjunktiv I und indirekte Rede · 10. Verben mit festen Präpositionen
und da-/wo-Komposita · 11. Nominalisierung und Verbalisierung · 12. Partizipien als Adjektive
und erweiterte Partizipialattribute · 13. Subjektive Modalverben und Vermutungen ·
14. n-Deklination und Adjektivdeklination · 15. Infinitivsätze mit zu, um…zu, ohne…zu,
statt…zu · 16. Temporale Konnektoren und Zeitenfolge (nachdem, bevor, während, seit, sobald).

Außerdem gilt an jedem Tag: Grammatikfehler in ihren freien Texten werden **korrigiert und
benannt**, egal welcher Wochentag ist. „Formale Richtigkeit" wird beim Schreiben und beim
Sprechen mitbewertet.

### Die Probeprüfung — Samstag 22:00

**Die 5:30-Routine schreibt sie mit.** Ist heute ein **Samstag**, bekommt die Lektion einen
zusätzlichen Block `probe` (Struktur wie `telc`, plus die Felder `punkte` für die erreichbare
Punktzahl und `dauer` für die Bearbeitungszeit). An allen anderen Tagen: keinen `probe`-Block
schreiben.

Die Seite **verschließt den Block bis Samstag 22:00 Uhr** und zeigt bis dahin nur einen Kasten
mit Countdown. Das ist Absicht: Die Probeprüfung soll unter echten Bedingungen entdeckt werden.
Es gibt einen Knopf zum vorzeitigen Öffnen, aber die Voreinstellung ist zu.

Aufbau einer Probeprüfung — **verkleinert, aber im echten Format und mit echten Punktwerten**:

| Teil | Aufgaben | Punkte |
|---|---|---|
| Leseverstehen | 2 Zuordnungen (5 P) + 2 Multiple-Choice mit 3 Optionen (5 P) | 20 |
| Sprachbausteine | 4 Multiple-Choice Grammatik + 4 Lexik-Zuordnungen (1,5 P) | 12 |
| Hörverstehen | Diktattext + 4 **Richtig-Falsch**-Aufgaben (5 P) | 20 |
| Schriftlicher Ausdruck | eine halbformelle E-Mail, **vier Leitpunkte**, mindestens 150 Wörter, **30 Minuten mit Uhr** | 45 |
| Mündlicher Ausdruck | eine Aufgabe aus Teil 1, 2 oder 3, laut vorsprechen | 25 |
| **gesamt** | | **122** |

Am Ende jeder Probeprüfung: die **60-%-Marke** nennen (73 von 122) und daran erinnern, dass
in der echten Prüfung **beide** Teile getrennt 60 % brauchen. Die Themen der Probeprüfung
kommen aus der Woche, die gerade zu Ende geht, plus Wiederholung aus früheren Wochen.

Alle vier Wochen (Woche 4, 8, 12, 16 und dann im Endspurt jede Woche) statt der kleinen
Probeprüfung einen **kompletten Subtest in Originallänge** aus dem Übungstest in
`deutsch-taeglich/telc-quellen/uebungstest/` — mit der echten Audiodatei fürs Hörverstehen.

### Die Blöcke `telc` und `probe`

Beide haben die Struktur des Blocks `training` (Feldnamen `titel`, `ziel`, `fr`, `aufgaben`
mit `typ`/`frage`/`loesung`/`hinweis`, `tipp`), plus:

- `teile` — welche Prüfungsteile trainiert werden, aus: `Leseverstehen`, `Sprachbausteine`,
  `Hörverstehen`, `Schriftlicher Ausdruck`, `Mündlicher Ausdruck`.
- `pruefungsziel` — ein bis zwei Sätze: was heute genau geübt wird und wofür es Punkte gibt.
- optional `text` — der Lese- oder Hörtext, wenn einer gebraucht wird.
- nur in `probe`: `punkte` (erreichbare Punktzahl) und `dauer`.

Der `telc`-Block trägt jetzt den **Schwerpunkt des Tages** — er ist nicht mehr ein Anhängsel
des Trainings, sondern der Hauptteil. Der `training`-Block bleibt für Grammatik- und
Wortschatzübungen, die auf den Tagesfokus vorbereiten.

**Wichtig, weil ich es einmal falsch hatte:**
- Der Schriftliche Ausdruck ist **kein formeller Brief an die Praxisanleiterin**, sondern eine
  **halbformelle E-Mail an eine Firma, Person oder ein Büro als Antwort auf eine Anzeige**,
  mit **vier Leitpunkten** und **mindestens 150 Wörtern**.
- Die Mündliche Prüfung enthält **keine Präsentation**. Die drei Teile sind
  *Über Erfahrungen sprechen*, *Diskussion*, *Gemeinsam etwas planen* — Gespräch zu zweit.
- Die Aufgabentypen im Hörverstehen sind **alle Richtig-Falsch**.
- Multiple-Choice hat in dieser Prüfung immer **genau drei Optionen**.

**Hörverstehen — die Seite spielt jetzt selbst ab.** Steht im `telc`-Block `Hörverstehen` in
`teile`, rendert die Vorlage **über den Aufgaben** einen Hörtext-Player: zweimal vorgelesen,
Tempo wählbar, der Text bleibt verborgen, bis sie ihn aufklappt. Der Player nimmt `telc.text`,
und wenn es den nicht gibt, den **Diktattext**. Deshalb an Hörverstehen-Tagen:
Richtig-Falsch-Aufgaben zum Diktattext stellen und den Text **nicht** zusätzlich in `telc.text`
wiederholen — sonst steht er doppelt da.

Die **echte telc-Originalaufnahme** liegt auf einer eigenen Seite:
`deutsch-taeglich/hoerverstehen.html` →
`https://claude.ai/code/artifact/fb2c751b-a84b-42e6-b19a-1bfc6fc6d4b3` (Favicon 🎧).
Sie enthält das Audio des Übungstests 1, die zwanzig Originalaufgaben, die Auswertung nach den
echten Punktwerten (75) und die Transkription. Gebaut wird sie mit
`python3 deutsch-taeglich/build-hoerverstehen.py` aus `hoerverstehen-src.html` und
`telc-quellen/uebungstest/hoerverstehen-web.mp3`; die erzeugte Datei ist 7 MB groß und steht in
`.gitignore` — **vor jedem Publish dieser Seite erst neu bauen.**

**Und noch etwas, das schiefgegangen ist:** Am 31.08. und am 01.09. lag die Lektion nur auf der
veröffentlichten Seite, nicht im Repo. Ein Build hätte sie gelöscht. Deshalb **vor** dem Build
prüfen, ob die neueste Lektion im Artifact neuer ist als die neueste Datei in `lektionen/` —
und wenn ja, sie erst aus dem Artifact zurückholen. Und: **immer committen und pushen**, nicht
nur veröffentlichen.

### Der Block `lesen` — jeden Tag ein Text von 200 Wörtern

Sie hat ausdrücklich darum gebeten: **„Je n'arrive pas à m'exprimer clairement."** Deshalb hat
**jede** Lektion einen Block `lesen` — ein Text, den sie liest, und danach drei Dinge, die sie
selbst formuliert: **nacherzählen, zusammenfassen, erklären.**

| Feld | Inhalt |
|---|---|
| `titel` | Überschrift des Textes |
| `quelle` | optional, eine Zeile |
| `fr` | französische Anleitung, wie sie vorgehen soll |
| `text` | **ungefähr 200 Wörter**, B2, Absätze mit Leerzeile getrennt |
| `hilfe` | Vokabelchips `**Wort** — traduction` (10–12 Stück) |
| `redemittel` | Satzanfänge, mit denen sie beginnen kann |
| `nacherzaehlen` | `{frage, hinweis, platzhalter, muster}` — „Was ist passiert?" |
| `hauptaussage` | `{frage, hinweis, platzhalter, muster}` — „Wovon handelt der Text?" |
| `fragen` | 5–6 × `{frage, loesung, hinweis}` — Verständnisfragen |
| `erklaeren` | `{frage, hinweis, muster}` — den Text laut in 30 Sekunden erklären |
| `tipp` | Bezug zum Prüfungsteil des Tages |

**Die Textsorte richtet sich nach dem Tagesfokus:** Montag eine **Erzählung oder Reportage**
(Leseverstehen), Dienstag ein **Bericht** (passt zum Hörverstehen), Mittwoch ein Text mit viel
**Grammatik der Woche**, Donnerstag ein **Brief oder eine Anzeige** (Schriftlicher Ausdruck),
Freitag ein Text mit einer **Meinung oder einem Konflikt** (Diskussion, Mündlich Teil 2),
Sonntag ein **leichter Text** zur Wiederholung.

**Wichtig:** Der Text braucht eine **Handlung** — etwas, das passiert und das man nacherzählen
kann. Eine reine Sachbeschreibung taugt für „Was ist passiert?" nicht. Das Thema kommt aus dem
Wochenthema, das Vokabular aus der laufenden Woche.

Die Seite zählt die Wörter selbst und zeigt sie im Etikett an. Der Text kann vorgelesen werden
(Tempo wählbar). Ihre Antworten werden im Browser gespeichert; die Musterantworten sind
eingeklappt.

**Und in der Antwort an sie immer erwähnen:** Sie soll ihre Antworten schicken — sie werden
korrigiert (Inhalt, Satzbau, Wortwahl), nicht nur gelobt.

### Pflichtinhalt jeder Lektion

Verb des Tages (mit Konjugation und Bedeutung) · Wortschatz-Block (Redemittel **zum Thema der
Woche**) · Grammatik-Block · **`lesen`-Block mit 200-Wörter-Text** · **telc-Block mit dem
Tagesfokus** · Aussprache-Block · Diktat · 5 Übersetzungssätze FR→DE · 3 Alltag-Missionen.
Am Samstag zusätzlich der Block `probe`.

**Verben und Wortschatz auf B2-Niveau wählen** und **zum Wochenthema passend**. Kein
A2-Grundwortschatz. Gut sind Verben mit fester Präposition (*sich kümmern um*, *hinweisen auf*,
*bestehen auf*, *verzichten auf*, *achten auf*, *sich beziehen auf*), Verben des Berichtens
und Argumentierens (*schildern*, *einschätzen*, *veranlassen*, *nachvollziehen*, *begründen*,
*abwägen*, *einräumen*) und Nominalisierungen.

Typische Fehler französischsprachiger Lernender ausdrücklich zeigen und korrigieren.

### Archiv

Die 13 Lektionen vom 17.08.–29.08.2026 (altes Schema) liegen in
`deutsch-taeglich/archiv-alt/` mit einer README-Tabelle. Sie gehören **nicht**
zurück in `lektionen/`, außer die Nutzerin bittet ausdrücklich darum.

---

## Schulungen und Klausuren

- `schulungen/` — Übersichtsseite, gebaut aus `schulungen.json` + `_template.html`
- `klausuren/` — Klausur-Protokoll, gebaut aus `klausuren.json` + `build.py`
- `schulung-recht/uebungsfaelle.html` — neun Übungsfälle im Schema der Dozentin

Beim Recht gilt: **nur** die neun Tatbestände der Dozentin
(§§ 223, 203, 239, 212, 303, 323c, 221, 216, 267 StGB). Es gibt **kein** eigenes
Fahrlässigkeitsdelikt — Körperverletzung ist immer § 223, und Vorsatz oder
Fahrlässigkeit wird erst in **III. Schuld** entschieden.

Alle Artifact-Links bleiben stabil. Für eine bestehende Seite **nie** eine neue URL
anlegen — immer denselben `file_path` bzw. dieselbe `url` verwenden.

---

## Prüfungsplan telc B2 — eigene Seite

`deutsch-taeglich/pruefung.html` → `https://claude.ai/code/artifact/46864e04-1000-4201-8cf3-d76d6c889c1d`
Favicon 🎯. Enthält das offizielle Format mit allen Punkten, die Bestehensgrenze, die Notenskala,
die 16 Themen und den Plan bis Februar 2027. Bei jeder Änderung am Prüfungsformat **zuerst hier**
nachsehen und diese Seite mitpflegen.
