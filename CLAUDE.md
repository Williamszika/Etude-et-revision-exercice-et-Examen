# Arbeitsanweisungen für dieses Repo

Nutzerin: französischsprachige Pflegeauszubildende, 2. Lehrjahr, generalistische
Ausbildung, NRW. Erklärungen auf Französisch, Fachinhalte und Beispiele auf Deutsch.

**Grundregel für alles in diesem Repo:** nichts erfinden. Keine Paragraphen, Normen,
Zahlen oder Quellen nennen, die nicht in ihren eigenen Unterlagen (PDFs im Repo) stehen.

---

## Deutsch täglich — tägliche Routine um 5:30

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
   Ihr Block `zyklus` sagt, wo wir stehen: `{thema, nr, gesamt: 13, tag, phase, start}`.
2. Neuen Zustand berechnen:
   - `tag < 5` → gleiches Thema, `tag + 1`
   - `tag = 5` → nächstes Thema (`nr + 1`), `tag = 1`, neues `start` = heute
   - nach Thema 13 → wieder Thema 1, aber mit anderen Beispielen und anderem Wortschatz
3. `deutsch-taeglich/lektionen/<YYYY-MM-DD>.json` schreiben — Struktur **exakt** wie in
   der neuesten vorhandenen Lektion (gleiche Block- und Feldnamen, nur neuer Inhalt).
4. `python3 deutsch-taeglich/build.py`
5. Veröffentlichen: erst `Artifact` mit `action:"read"` auf die URL oben (sonst wird der
   Publish als veraltet abgelehnt), dann publish mit `file_path deutsch-taeglich/index.html`
   und derselben `url`.
6. `git add -A && git commit && git pull --rebase origin <branch> && git push -u origin <branch>`

### Die 13 Themen, in dieser Reihenfolge — alle B1/B2

| Nr | Thema | Niveau |
|----|-------|--------|
| 1 | Satzbau: Verb auf Platz 2 und Satzklammer | B1 — Fundament |
| 2 | Nebensätze: weil, obwohl, damit, dass, wenn/als, seit | B1/B2 |
| 3 | Relativsätze — auch mit Präposition und mit was/wo | B2 |
| 4 | Konnektoren: kausal, konzessiv, konsekutiv, final, adversativ | B2 |
| 5 | Zweiteilige Konnektoren: zwar…aber, je…desto, weder…noch, nicht nur…sondern auch | B2 |
| 6 | Passiv in allen Zeiten und mit Modalverben | B2 |
| 7 | Passiversatzformen: sein + zu, sich lassen, -bar, man | B2 |
| 8 | Konjunktiv II: Höflichkeit, Wunsch, Irreales, Vergangenheit | B1/B2 |
| 9 | Konjunktiv I und indirekte Rede — Übergabe, Bericht, Zitat | B2 |
| 10 | Verben mit festen Präpositionen + da-/wo-Komposita | B2 |
| 11 | Nominalisierung und Verbalisierung — Nominalstil der Dokumentation | B2 |
| 12 | Partizipien als Adjektive und erweiterte Partizipialattribute | B2 |
| 13 | Subjektive Modalverben und Vermutungen: soll, will, muss, dürfte, könnte | B2 |

Start: **30.08.2026 = Thema 1, Tag 1.** 13 Themen × 5 Tage = 65 Tage → Runde 1 endet am
**02.11.2026**. Danach Runde 2 mit denselben Themen, aber schwereren Texten und mehr
Prüfungsformat, bis Anfang Januar 2027. Januar und Februar: reines Prüfungstraining.

### Der Block `telc` — in jeder Lektion

Struktur exakt wie der Block `training` (gleiche Feldnamen: `titel`, `ziel`, `fr`, `aufgaben`
mit `typ`/`frage`/`loesung`/`hinweis`, `tipp`), plus zwei eigene Felder:

- `teile` — Liste der trainierten Prüfungsteile, aus:
  `Leseverstehen`, `Sprachbausteine`, `Hörverstehen`, `Schriftlicher Ausdruck`,
  `Mündlicher Ausdruck`. Zwei bis drei pro Tag reichen.
- `pruefungsziel` — ein bis zwei Sätze: **warum** die Grammatik des Tages in der Prüfung zählt.
- optional `text` — ein kurzer Lesetext, wenn Leseverstehen trainiert wird.

Welche Teile an welchem Tag:

| Tag | Schwerpunkt im telc-Block |
|-----|---------------------------|
| 1 | **Sprachbausteine Teil 1** — die Regel des Tages als Multiple-Choice-Lückentext mit **drei Optionen**, Inputtext eine halbformelle E-Mail |
| 2 | **Sprachbausteine Teil 2** (Lexik-Zuordnung) + **Leseverstehen Teil 2** (Multiple-Choice, drei Optionen) |
| 3 | **Schriftlicher Ausdruck** — Sätze und Redemittel für die halbformelle E-Mail, ein Leitpunkt pro Aufgabe |
| 4 | **Leseverstehen Teil 1 oder 3** (Zuordnung) + **Schriftlicher Ausdruck**: eine vollständige E-Mail zu vier Leitpunkten, mindestens 150 Wörter, 30 Minuten mit Uhr |
| 5 | **Mündlicher Ausdruck** — Teil 1 über Erfahrungen sprechen, Teil 2 Diskussion über einen kontroversen Text, Teil 3 gemeinsam etwas planen |

**Wichtig, weil ich es einmal falsch hatte:**
- Der Schriftliche Ausdruck ist **kein formeller Brief an die Praxisanleiterin**, sondern eine
  **halbformelle E-Mail an eine Firma, Person oder ein Büro als Antwort auf eine Anzeige**,
  mit **vier Leitpunkten** und **mindestens 150 Wörtern**. Genau diese Textsorte üben.
- Die Mündliche Prüfung enthält **keine Präsentation**. Die drei Teile sind
  *Über Erfahrungen sprechen*, *Diskussion*, *Gemeinsam etwas planen* — immer als Gespräch
  zu zweit, nicht als Vortrag.
- Die Sprachbausteine sind nur **10 %**. Lesen, Hören und Sprechen sind je 25 %, zusammen 75 %.
  Deshalb dürfen sich die telc-Blöcke **nicht** auf Lückentexte beschränken.

**Hörverstehen** kann die Seite nicht abspielen. Ersatz: der bestehende **Diktat**-Block
(zweimal vorgelesen, Tempo einstellbar) zählt als Hörtraining — im telc-Block darauf verweisen
und regelmäßig auf die echte Audiodatei in `deutsch-taeglich/telc-quellen/uebungstest/`
hinweisen, statt Audio auf der Seite zu behaupten. Die Aufgabentypen im Hörverstehen sind
**alle Richtig-Falsch** — also auch im Training Richtig-Falsch-Aufgaben zum Diktattext stellen.

### Die 5 Tage eines Themas

Feld `phase` im Block `zyklus`, Feld `stufe` im Block `training`.

| Tag | phase | stufe | Anspruch |
|-----|-------|-------|----------|
| 1 | Verstehen und erste Übungen | 1 | ganz leicht — Regel erklären, sehr einfache Lücken, Wörter ordnen |
| 2 | Erkennen | 2 | leicht — Fehler finden und korrigieren, richtige Form auswählen |
| 3 | Anwenden | 3 | mittel — eigene Sätze bilden, umformen |
| 4 | Verbinden | 4 | schwer — längere Sätze, Thema mit früheren Themen kombinieren |
| 5 | Frei sprechen | 5 | am schwersten — ganze Übergabe / Gespräch / Bericht frei schreiben, ohne Vorlage |

**Jeder** Tag hat: Mini-Kurs mit Erklärung **und** Übungen mit Lückenfeldern **und**
Korrektur zu jeder einzelnen Aufgabe. Die Schwierigkeit steigt jeden Tag spürbar an.

### Pflichtinhalt jeder Lektion

Verb des Tages (mit Konjugation und Bedeutung) · Wortschatz-Block (Redemittel) ·
Grammatik-Block · **telc-Block** · Aussprache-Block · Diktat · 5 Übersetzungssätze FR→DE ·
3 Alltag-Missionen.

**Verben und Wortschatz auf B2-Niveau wählen.** Kein A2-Grundwortschatz mehr. Gut sind
Verben mit fester Präposition (*sich kümmern um*, *hinweisen auf*, *bestehen auf*,
*verzichten auf*, *achten auf*, *sich beziehen auf*), Verben des Berichtens
(*schildern*, *einschätzen*, *veranlassen*, *nachvollziehen*, *begründen*) und
Nominalisierungen, die in der Dokumentation vorkommen.

Alle Beispiele aus dem echten Pflegealltag: Übergabe, Visite, Dokumentation,
Angehörige, Vitalzeichen, Medikamente, Lagerung, Sturz, Schmerz, Aufnahme, Entlassung.
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
