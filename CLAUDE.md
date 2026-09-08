# Arbeitsanweisungen für dieses Repo

Nutzerin: französischsprachige Pflegeauszubildende, 2. Lehrjahr, generalistische
Ausbildung, NRW. Erklärungen auf Französisch, Fachinhalte und Beispiele auf Deutsch.

**Grundregel für alles in diesem Repo:** nichts erfinden. Keine Paragraphen, Normen,
Zahlen oder Quellen nennen, die nicht in ihren eigenen Unterlagen (PDFs im Repo) stehen.

---

## Deutsch täglich — ein Lerntag, zwei Übungstage, neues Thema alle drei Tage

Diese Anweisung gilt **immer** und hat Vorrang vor älteren Routine-Texten.

**Die Routine läuft weiter jeden Morgen um 5:30**, aber sie schreibt **nicht jeden Tag eine
neue Lektion.** Zwei Wünsche der Nutzerin liegen dahinter:

> *„Le deutsch Täglich sera chaque deux jour et non chaque jour. Cela me permettra de mieux
> étudier."* — und danach: *„le deutsch Täglich doit commencer aujourd'hui et les autres
> précédents à effacer."*

Deshalb wurde am **05.09.2026** neu angefangen. Alle früheren Lektionen sind aus `lektionen/`
entfernt (sie stehen weiterhin in der Git-Historie, falls sie doch zurück sollen).

**Ab dem 08.09.2026 gilt der Drei-Tage-Takt.** Sie hat ihn selbst so beschrieben:
*„Je me sens a l'aise lorsque tu m'enseigne un jour et deux jours d'exercices puis d'autres
chaque trois jours."* Also: **ein Lerntag, zwei Übungstage, dann ein neues Thema.**

| Fall | Was die 5:30-Routine tut |
|---|---|
| **`(heute − 05.09.2026) % 3 == 0`** | **Neue Lektion schreiben**, bauen, veröffentlichen, committen |
| **Es ist Samstag** (und kein Lektionstag) | **Nur den `probe`-Block** — schlanke Datei mit `zyklus` + `probe` |
| **alle übrigen Tage** | **Übungstag — keine neue Datei.** Nur `build.py`, veröffentlichen, fertig |

Ist ein Samstag zugleich Lektionstag, bekommt die volle Lektion zusätzlich den `probe`-Block.
An einem Übungstag: **keine** Datei in `lektionen/` anlegen, **nichts** überschreiben. Die Seite
baut den Übungstag selbst (siehe unten). Trotzdem bauen und veröffentlichen.

Lektionstage: **05.09. · 08.09. · 11.09. · 14.09. · 17.09. · 20.09. …**
Die Lektion vom **07.09.** ist noch im alten Zwei-Tage-Takt entstanden und bleibt stehen; ab dem
08.09. zählt nur noch die Dreierregel.

### Etappe 1 — erst B1, dann B2. Sie hat A2.

**Am 08.09.2026 hat sie ihr Niveau genannt und das Ziel geändert:**

> *„je connais mon niveau j'ai le A2. je veux que tu m'enseignes le B1 selon le plan de Deutsch
> täglich pendant 2 mois afin que je puisse comprendre toute la grammaire, le vocabulaire, les
> verbes et comment les employer, savoir écrire, lire et comprendre, savoir parler et écouter.
> Niveau B1. pendant 2 mois."*

Deshalb ist Deutsch täglich in **zwei Etappen** geteilt:

| Etappe | Ziel | Zeitraum | Lektionen |
|---|---|---|---|
| **1 — läuft** | **A2 → B1** | **08.09.2026 – 08.11.2026** | **21** |
| 2 — danach | B1 → B2, dann telc Deutsch B2 | ohne festes Datum | 16 pro Durchgang |

Planseite: `deutsch-taeglich/b1.html` →
`https://claude.ai/code/artifact/9ed33853-7d8f-4ee5-a756-b9ef186c99bc` (Favicon 🪜). Dort stehen
die 21 Lektionen mit Datum, die vollständige B1-Grammatikliste und die ehrliche Rechnung.

**Ihr Niveau A2 ist von ihr genannt, nicht gemessen.** Das steht so in `einstufungen.json` unter
`startniveau`. Messung 1 (der Einstufungstest) soll zeigen, ob A2 für alle fünf Fertigkeiten gilt.
Bis dahin: **A2 als Arbeitsannahme behandeln, nicht als Messwert ausgeben.**

**Was in der Etappe 1 anders ist — das gilt für jede Lektion bis zum 08.11.2026:**

- **Niveau B1, nicht B2.** Verben, Wortschatz, Texte, Aufgaben: alles auf **A2/B1**. Kein
  B2-Wortschatz als Tagesverb (*sich auszeichnen durch*, *verzichten auf* sind zu hoch), keine
  B2-Nominalisierungen als Pflichtstoff. B2-Wörter dürfen als Beispiel vorkommen, nie als Lernziel.
- **Der `lesen`-Text ist 150–200 Wörter lang** und in kurzen Sätzen geschrieben; die
  Wortschatztabelle nennt **A2** oder **B1** im Feld `niveau`.
- **Kein telc-B2-Prüfungstraining.** Der Block heißt weiter `telc` (die Vorlage rendert ihn so),
  trägt aber ein eigenes Etikett im Feld `badge`, z. B.
  `"Fertigkeit des Tages · Lesen · Niveau B1"`, und übt die **Fertigkeit** statt das Prüfungsformat.
  Keine telc-Punktzahlen, keine „1,5 Punkte pro Item", kein Subtest-Vokabular.
- **`zyklus` bekommt drei neue Felder:** `etappe: "B1"`, `gesamt: 21`, `grammatik` und
  `grammatikNr` (das Grammatikthema der Lektion aus der Liste unten). `start` ist **2026-09-08**,
  `lektion` zählt **von 1 bis 21**. **Kein `durchgang`** in der Etappe 1.
- **Die Probeprüfung am Samstag** bleibt, aber auf **B1-Niveau** und ohne telc-Punktwerte.

### Die 21 Grammatikthemen der Etappe B1 — eins pro Lektion

`grammatikNr = lektion`, in dieser Reihenfolge. Das ist die vollständige B1-Grammatik; nichts
davon darf ausfallen, denn genau darauf beruht die Zusage „in zwei Monaten hast du das ganze
B1-Programm gesehen".

1. Verbstellung und Satzklammer (Position 2, W-Fragen, Ja/Nein-Fragen)
2. Nebensätze: weil, dass, wenn/als, obwohl, damit
3. Perfekt und Präteritum — regelmäßig, unregelmäßig, trennbar, sein/haben
4. Modalverben in allen Zeiten
5. Das Kasussystem: Nominativ, Akkusativ, Dativ — Artikel und Pronomen
6. Wechselpräpositionen und feste Präpositionen
7. Adjektivdeklination — nach bestimmtem, unbestimmtem und ohne Artikel
8. Komparativ, Superlativ, Vergleiche (als/wie, je … desto)
9. Possessiv-, Demonstrativ- und Indefinitpronomen
10. Reflexive Verben — Akkusativ und Dativ
11. Trennbare und untrennbare Verben, Infinitiv mit *zu*
12. Verben mit Präpositionen, da- und wo-Komposita
13. Relativsätze — Nominativ, Akkusativ, Dativ
14. Infinitiv mit zu, um … zu, ohne … zu
15. Passiv Präsens und Präteritum
16. Konjunktiv II — würde, könnte, hätte, wäre
17. Genitiv und Genitivpräpositionen (wegen, während, trotz)
18. Temporale Nebensätze und Plusquamperfekt (nachdem, bevor, während, seitdem)
19. Konnektoren auf Position 1 (deshalb, trotzdem, sonst, außerdem, dann)
20. Indirekte Fragen mit *ob* und W-Wort
21. Wiederholung — die zehn Fehler, die B1 kosten, an einem ganzen Text

Der **Wortschatz** jeder Lektion kommt weiter aus den 16 Themenbereichen:
`themaNr = ((lektion − 1) mod 16) + 1`.

**Die Fokus-Rotation bleibt**, nur unter B1-Namen: `REIHE[(lektion − 1) mod 5]` mit
Leseverstehen → Hörverstehen → Sprachbausteine → Schriftlicher Ausdruck → Mündlicher Ausdruck.
Im `telc`-Block heißen sie in der Etappe 1 schlicht **Lesen · Hören · Grammatik im Text ·
Schreiben · Sprechen**.

**Am Ende der Etappe (08.11.2026):** ehrlich sagen, ob B1 erreicht ist, in welchen Fertigkeiten
nicht, und ob Etappe 2 anfängt oder B1 verlängert wird. **Nicht behaupten, B1 sei erreicht, weil
21 Lektionen abgearbeitet sind** — das entscheidet Messung 2, nicht der Kalender.

**Der Zeit-Hinweis, der ihr gegeben wurde und der stehen bleiben muss:** Bei 60/30 Minuten sind
zwei Monate **rund 41 Stunden**; die übliche Schätzung für A2 → B1 liegt bei **150–200 Stunden**
(**allgemeine Schätzung, nicht aus ihren Unterlagen**). Ihr wurde gesagt: Der **Stoff** passt in
zwei Monate, das **Können** in allen vier Fertigkeiten möglicherweise nicht — und dass sie den
Rhythmus jederzeit auf täglich stellen kann. **Diese Unterscheidung nie verwischen.**

### Kein Prüfungstermin — das Niveau entscheidet

**Am 08.09.2026 hat sie den Februartermin gestrichen.** Sie ist **nicht angemeldet** und will es
erst, wenn sie so weit ist:

> *„et annuler l'objectif de l'examen, Je ne me suis pas encore inscris. C'est toi qui me diras
> si je peux m'inscrire pour passer l'examen ou non selon mon niveau."*

Daraus folgt für alles in diesem Abschnitt:

- **Kein Countdown mehr.** Das Feld `bisPruefung` wird in neuen Lektionen **weggelassen**; die
  Vorlage zeigt es nur noch, wenn es dasteht. Keine Seite darf „noch X Tage bis zur Prüfung"
  anzeigen.
- **Keine Endspurt-Phase**, keine Termin-Tabelle, kein „bis Februar".
- Statt Datum zählt der **Durchgang**: Durchgang 1 = die 16 Themen zum ersten Mal (16 Lektionen),
  Durchgang 2 = dieselben Themen härter, Durchgang 3 = ganze Prüfungsteile unter Zeit. Ein
  Durchgang dauert 16 Lektionen = 48 Tage, egal wann er anfängt.
- Das Feld `zyklus` bekommt dafür `durchgang` (1, 2, 3 …) statt `bisPruefung`.

### Die Anmeldung — wann ich sie freigebe

Sie hat mir diese Entscheidung ausdrücklich übertragen. Die Regel, damit sie überprüfbar bleibt
und nicht Gefühlssache ist:

**Anmelden erst, wenn der Einstufungstest in zwei aufeinanderfolgenden Messungen bei allen fünf
Fertigkeiten B2 zeigt** — Lesen, Hören, Sprachbausteine, Schreiben und Sprechen. Zwei Messungen,
weil eine einzelne gute Messung ein Zufall sein kann.

**Gemessen wird alle acht Wochen** mit `deutsch-taeglich/einstufung.html`. Jede Messung wird in
`deutsch-taeglich/einstufungen.json` festgehalten (Datum, fünf Ergebnisse, eine Zeile Kommentar),
damit die Entwicklung sichtbar ist und die Prognose auf echten Zahlen beruht statt auf einer
Tabelle aus dem Internet.

**Bis dahin gilt: keine Zahl behaupten, die nicht gemessen ist.** Wenn sie fragt, wie lange es
noch dauert, wird gerechnet — mit ihren letzten beiden Messungen — und offen gesagt, wie unsicher
die Rechnung ist.

### Ihre vier Festlegungen vom 08.09.2026

Sie hat auf Nachfrage entschieden — **das gilt, bis sie es ändert:**

| Frage | Ihre Antwort | Was daraus folgt |
|---|---|---|
| Zeit pro Tag | **60 Min Lerntag / 30 Min Übungstag** (≈ 97 Stunden bis zur Prüfung) | Der volle Plan mit drei Durchgängen wird nicht gekürzt. |
| Aktuelles Niveau | **„Ich weiß nicht, wo ich stehe."** | Deshalb **Einstufungstest** am 08.09. — siehe unten. Vor dem Ergebnis keine Stufe behaupten. |
| Welche Prüfung | **telc Deutsch B2 (allgemein)**, nicht Pflege | Die 16 Themen aus Anhang T bleiben das Rückgrat. Pflegebeispiele bleiben Beispiele. |
| Sprechpartner | **keinen** | Mündlich läuft über **aufgenommene Monologe** und **Dialoge, in denen sie beide Rollen laut spricht**. Teil 2 und Teil 3 der echten Prüfung sind eine Paarprüfung — das wurde ihr ausdrücklich gesagt. |

### Der Einstufungstest — `deutsch-taeglich/einstufung.html`

→ `https://claude.ai/code/artifact/ea512258-b4a4-47d8-8959-12d7cd441bf9` (Favicon 📏)

Fünf Fertigkeiten **einzeln** gemessen, je auf drei Stufen (A2 / B1 / B2), eine Stufe gilt ab
**60 %** als geschafft (die Bestehensgrenze aus ihrem Handbuch). Selbst auswertbar: Lesen, Hören,
Sprachbausteine. Von Hand zu korrigieren: **drei Diktatblöcke**, eine **kurze E-Mail** (90 Wörter,
vier Leitpunkte) und ihre **Selbsteinschätzung zum Sprechen** (sie nimmt sich 60 Sekunden auf —
ich kann die Aufnahme nicht hören, das steht so auf der Seite).

**Format aus dem Handbuch, Aufgaben selbst geschrieben** — das steht auf der Seite ausdrücklich
drin. Es ist kein offizieller telc-Test und darf nie als solcher bezeichnet werden.

**Bis ihre Ergebnisse da sind:** keine Lektion so schreiben, als wäre ihr Niveau bekannt. Sobald
sie die drei Prozentzahlen, die Diktate, die E-Mail und die Sprech-Einschätzung schickt, wird
daraus der Startpunkt von Durchgang 1 festgelegt — und die Schwierigkeit der täglichen Diktate.

### Diktat — jeden Tag, auch an Übungstagen

Sie hat gesagt: *„Je dois etre fort en dictee."* Das Diktat ist zugleich das billigste Training
gegen ihre teuerste Schwäche: **Hörverstehen und Mündlicher Ausdruck sind zusammen 150 von 300
Punkten.** Deshalb steht das Diktat **in jeder Lektion und an jedem Übungstag** — an Übungstagen
rendert die Vorlage es ohnehin mit.

### Das Ziel: erst B1, dann B2, dann die Prüfung telc Deutsch B2

Deutsch täglich ist **kein allgemeiner Sprachkurs mehr**, sondern ein Weg in zwei Etappen:
zuerst **A2 → B1** (bis 08.11.2026, siehe oben), danach **B1 → B2** und erst ganz zum Schluss
die Prüfung **telc Deutsch B2**. **Ein Prüfungstermin steht nicht fest und wird nicht gesetzt.**
Daraus folgt:

- **In der Etappe 1 liegen alle Themen auf A2/B1-Niveau.** Die B2-Regeln weiter unten in dieser
  Datei (B2-Wortschatz, telc-Prüfungsformat, Punktwerte) gelten **erst ab Etappe 2**. Wo sich
  etwas widerspricht, gewinnt der Abschnitt „Etappe 1".
- **Jede** Lektion hat einen Block `telc` — in Etappe 1 als **Fertigkeit des Tages** (mit
  eigenem `badge`), ab Etappe 2 als Prüfungstraining im telc-Format.
- Die Beispiele dürfen aus dem Pflegealltag kommen (siehe unten), müssen es aber nicht — auf B1
  zählt der Alltag insgesamt: Telefonieren, Ämter, Wohnen, Einkaufen, Freizeit.

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

### Regel 0 — nichts überschreiben, und an Übungstagen gar nichts schreiben

Zwei Fälle, in denen **keine** neue Lektion entsteht:

- **`(heute − 05.09.2026) % 3 != 0` und heute ist kein Samstag** → Übungstag. Keine Datei
  anlegen.
- `deutsch-taeglich/lektionen/<HEUTIGES-DATUM>.json` **existiert schon** → diese Datei
  **nicht** anfassen.

In beiden Fällen: nur `python3 deutsch-taeglich/build.py` ausführen, veröffentlichen, fertig.

### Ablauf

0. **Zuerst retten, dann arbeiten.** Das ist der Fehler, der bisher am häufigsten passiert ist
   (31.08., 01.09., 02.–04.09., 05.09., 07.09.): Die Routine veröffentlicht eine Lektion, aber
   sie committet sie nie — beim nächsten Build ist sie weg. Also **vor allem anderen**:
   `Artifact action:"read"` auf die Deutsch-täglich-URL, `const LEKTIONEN` aus der gespeicherten
   Datei ziehen und **jede** Lektion, deren Datum nicht in `lektionen/` liegt, dort als JSON
   anlegen. Erst danach weitermachen.
1. `ls deutsch-taeglich/lektionen/`, die **neueste** Lektion lesen.
   Ihr Block `zyklus` sagt, wo wir stehen: `{woche, gesamt: 16, thema, themaNr, tag, fokus,
   start, lektion, durchgang}`.
2. **Rechnen, nicht raten** — `d = (heute − 2026-09-05).days`:
   - `d % 3 == 0` → **Lektionstag**, weiter mit Schritt 3
   - sonst und heute Samstag → **nur Probeprüfung**, schlanke Datei (siehe unten)
   - sonst → **Übungstag**, direkt zu Schritt 4
3. Neuen Zustand aus dem **heutigen Datum** berechnen — `e = (heute − 2026-09-08).days`:
   - **Etappe 1 (bis einschließlich 08.11.2026):**
     `lektion` = `e / 3 + 1` · `etappe` = `"B1"` · `gesamt` = `21`
     `grammatikNr` = `lektion` · `grammatik` = Thema Nr. `grammatikNr` aus der B1-Liste oben
     `themaNr` = `((lektion − 1) mod 16) + 1` · `thema` = das Thema dazu
     `start` = `"2026-09-08"` · **kein `durchgang`**
   - **Etappe 2 (danach):** `lektion` weiterzählen, `etappe` = `"B2"`, `gesamt` = `16`,
     `durchgang` = `((lektion − 1) // 16) + 1`, `start` = der Starttag der Etappe 2.
   - immer: `woche` = `e // 7 + 1` (nur Anzeige) · `tag` = heutiger Wochentag auf Deutsch ·
     `fokus` = `REIHE[(lektion − 1) mod 5]`
   - **Kein `bisPruefung`.** Es gibt keinen Termin.
   Dann `deutsch-taeglich/lektionen/<YYYY-MM-DD>.json` schreiben — Struktur **exakt** wie in
   der neuesten vorhandenen **Lektion vom gleichen Typ** (volle Lektion bzw. reine
   Probeprüfung), gleiche Block- und Feldnamen, nur neuer Inhalt.
4. `python3 deutsch-taeglich/build.py`
5. Veröffentlichen: erst `Artifact` mit `action:"read"` auf die URL oben (sonst wird der
   Publish als veraltet abgelehnt), dann publish mit `file_path deutsch-taeglich/index.html`
   und derselben `url`.
6. `git add -A && git commit && git pull --rebase origin <branch> && git push -u origin <branch>`
   — **dieser Schritt gehört dazu, er ist nicht optional.** Eine Lektion, die nur veröffentlicht und
   nicht committet ist, gilt als verloren. Der Lauf ist erst fertig, wenn `git status` sauber ist.

### Der Wochenrhythmus — kein Grammatik-Zyklus mehr

**Die alten 13 Grammatikthemen sind abgeschafft.** Deutsch täglich folgt jetzt der Prüfung
selbst. **Jede Lektion gehört einem der 16 telc-Themen aus Anhang T** — `themaNr = lektion − 1`,
gedeckelt auf 16 — und **jeder dritte Kalendertag** ist ein Lektionstag. Das Thema hängt also an
der **Lektionsnummer**, nicht mehr an der Kalenderwoche.

**Die Fokus-Rotation.** Der Fokus hängt **nicht am Wochentag**, sondern an der **Nummer der
Lektion**, und läuft im Kreis:

`Leseverstehen → Hörverstehen → Sprachbausteine → Schriftlicher Ausdruck → Mündlicher Ausdruck`

```
lektion = (heute - 2026-09-08).days / 3 + 1     # Etappe 1
fokus   = REIHE[(lektion - 1) mod 5]
```

Etappe B1: Lektion 1 (08.09.) Lesen · 2 (11.09.) Hören · 3 (14.09.) Grammatik im Text ·
4 (17.09.) Schreiben · 5 (20.09.) Sprechen · 6 (23.09.) wieder Lesen. Jede Fertigkeit kommt
gleich oft dran, keine fällt hinten runter.

Die zwei Lektionen vom **05.09.** und **07.09.** stammen aus der Zeit davor (B2-Zuschnitt, alte
Nummerierung). Sie bleiben in `lektionen/` stehen, damit sie zurückblättern kann, und werden
**nicht** umgeschrieben. Die Zählung der Etappe 1 fängt am 08.09. bei 1 an.

Der Block `zyklus` sieht ab Lektion 1 so aus:

```json
"zyklus": {"woche": 1, "gesamt": 21, "etappe": "B1",
           "thema": "Angaben zur eigenen Person", "themaNr": 1,
           "grammatik": "Verbstellung und Satzklammer", "grammatikNr": 1,
           "tag": "Dienstag", "fokus": "Leseverstehen",
           "start": "2026-09-08", "lektion": 1}
```

**Kein `bisPruefung`-Feld mehr.** Wo es in alten Lektionen noch steht, bleibt es stehen;
neu geschrieben wird es nicht.

### Die Übungstage — ein eigener Tag, und nur Übungen

Sie hat sich beschwert, als der Übungstag noch ein Kasten **über** der Lektion vom Vortag war:
*„On ne peut pas migrer entre la leçon de hier et les exercices d'aujourd'hui. Et les exercices
doivent être que les exercices et non de leçon."* Beides ist behoben — **ohne dass eine Datei
für den Übungstag entsteht.** Die Vorlage baut ihn selbst.

**Ein Übungstag ist ein eigener Tag.** `baueTage()` im Template geht vom ältesten Lektionsdatum
bis heute und legt für jeden Tag ohne Lektionsdatei einen Eintrag `{typ:'uebung', datum, l}` an,
wobei `l` die **letzte vorangegangene Lektion** ist. Daraus folgt:

- In der Datumsleiste steht der Übungstag als **eigener Knopf** (gestrichelt, mit ✎).
  Zwischen Lektion und Übungstag wird ganz normal hin- und hergeblättert.
- `AKT_DATUM` ist das Datum **des Übungstags**, nicht das der Lektion. Ihre Antworten von heute
  liegen also unter eigenen `localStorage`-Schlüsseln — sie fängt wirklich mit leeren Feldern an.

**Und es sind nur Übungen.** `renderUebungstagSeite(l, datum)` zeigt ausschließlich:
`deklination` · `lesen` **mit `{nurUebungen:true}`** · `training` · `telc` · `diktat` ·
`uebersetzung`. **Nicht** dabei: `verb`, `wortschatz`, `grammatik`, `aussprache` — das ist
Lernstoff und gehört dem Lektionstag.

Das Flag `nurUebungen` in `renderLesen` lässt nur die Aufgaben stehen: der Text steht
**zugeklappt** in einem `<details>` („erst aufklappen, wenn du nicht weiterkommst"), und
Vokabelchips, Redemittel, die **Wortschatztabelle**, die Einleitungen, die Grammatik-`regel`,
`imText` und der `tipp` fallen weg. Die *Aufgaben* aus `wortschatz`, `grammatik` und
`konnektoren` bleiben.

**Wenn sie an einem Übungstag etwas schickt**, wird es korrigiert wie immer — Deklinationsfehler
dem **Kettenglied**, alles andere der **Baustelle** zuordnen.

### Die 16 Wochen — ein telc-Thema pro Woche

Start: **Samstag, 05.09.2026.** Reihenfolge = Anhang T des Handbuchs. Eine „Woche" sind hier
sieben Tage ab dem Starttag, nicht Montag bis Sonntag.

| Woche | Zeitraum | Thema |
|---|---|---|
| 1 | 05.09.–11.09. | T1 Angaben zur eigenen Person |
| 2 | 12.09.–18.09. | T2 Der menschliche Körper, Gesundheit und Körperpflege |
| 3 | 19.09.–25.09. | T3 Wohnen |
| 4 | 26.09.–02.10. | T4 Orte |
| 5 | 03.10.–09.10. | T5 Tägliches Leben |
| 6 | 10.10.–16.10. | T6 Essen und Trinken |
| 7 | 17.10.–23.10. | T7 Erziehung, Ausbildung, Lernen |
| 8 | 24.10.–30.10. | T8 Arbeit und Beruf |
| 9 | 31.10.–06.11. | T9 Geschäfte, Handel, Konsum |
| 10 | 07.11.–13.11. | T10 Dienstleistungen |
| 11 | 14.11.–20.11. | T11 Natur und Umwelt |
| 12 | 21.11.–27.11. | T12 Reise und Verkehr |
| 13 | 28.11.–04.12. | T13 Freizeit und Unterhaltung |
| 14 | 05.12.–11.12. | T14 Medien und moderne Informationstechniken |
| 15 | 12.12.–18.12. | T15 Gesellschaft, Staat, Regierung |
| 16 | 19.12.–25.12. | T16 Beziehungen zu anderen Menschen und Kulturen |

**Die Datumsspalte ist nur noch eine Erinnerung an Durchgang 1.** Seit dem 08.09. hängt das Thema
an der **Lektionsnummer**, nicht am Datum: `themaNr = lektion − 1`. Nach Lektion 17 fängt
Durchgang 2 mit T1 wieder an, härter — und Durchgang 3 besteht aus ganzen Prüfungsteilen unter
Zeit, jedes Mal eine vollständige E-Mail in 30 Minuten mit Uhr.

**Wichtig:** Pflegebeispiele sind erlaubt und sogar prüfungskonform, aber sie dürfen die Woche
nicht kapern. In der Woche „Natur und Umwelt" geht es um Natur und Umwelt — nicht um die
Station. Sie braucht Wortschatz aus **allen sechzehn** Bereichen, besonders für die Diskussion
in Teil 2 der Mündlichen Prüfung.

### Grammatik — Thema der Woche, nicht mehr Rückgrat

Die B2-Grammatik läuft weiter, aber als **Grammatik der Woche** — eine pro Woche, in jeder
Lektion der Woche im `grammatik`-Block, und im Schwerpunkt an dem Lektionstag, dessen Fokus
**Sprachbausteine** ist. Reihenfolge:

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
benannt**, egal welcher Wochentag ist — auch an Übungstagen. „Formale Richtigkeit" wird beim
Schreiben und beim Sprechen mitbewertet.

### Die Probeprüfung — Samstag 22:00

**Die 5:30-Routine schreibt sie am Samstagmorgen mit.** Ist der Samstag **kein** Lektionstag,
ist die Samstagsdatei **keine volle Lektion**: sie enthält nur `datum`, `thema`, `zyklus` (mit
`tag: "Samstag"`, `fokus: "Probeprüfung"`) und den Block `probe` — Struktur wie `telc`, plus die
Felder `punkte` für die erreichbare Punktzahl und `dauer` für die Bearbeitungszeit. **Kein**
`verb`, `lesen`, `deklination`, `diktat` und so weiter. Fällt ein Samstag **auf** einen
Lektionstag, bekommt die volle Lektion den `probe`-Block zusätzlich.
An allen anderen Tagen: keinen `probe`-Block schreiben.

**Die erste Probeprüfung ist der 12.09.2026.** Am Starttag 05.09. gab es bewusst keine — es war
noch nichts da, was man hätte prüfen können.

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

Alle vier Probeprüfungen einmal (also jede vierte) statt der kleinen
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

### Der Block `lesen` — in jeder Lektion ein Text von 200 Wörtern

Sie hat ausdrücklich darum gebeten: **„Je n'arrive pas à m'exprimer clairement."** Deshalb hat
**jede** Lektion einen Block `lesen` — ein Text, den sie liest, und danach drei Dinge, die sie
selbst formuliert: **nacherzählen, zusammenfassen, erklären.**

| Feld | Inhalt |
|---|---|
| `titel` | Überschrift des Textes |
| `quelle` | optional, eine Zeile |
| `fr` | französische Anleitung, wie sie vorgehen soll |
| `text` | **150–200 Wörter** — in Etappe 1 auf **B1**, ab Etappe 2 auf B2; Absätze mit Leerzeile getrennt |
| `hilfe` | Vokabelchips `**Wort** — traduction` (10–12 Stück) |
| `redemittel` | Satzanfänge, mit denen sie beginnen kann |
| `nacherzaehlen` | `{frage, hinweis, platzhalter, muster}` — „Was ist passiert?" |
| `hauptaussage` | `{frage, hinweis, platzhalter, muster}` — „Wovon handelt der Text?" |
| `fragen` | 5–6 × `{operator, frage, loesung, hinweis}` — siehe Operatoren unten |
| `wortschatz` | `{einleitung, woerter:[{wort, niveau, fr, imText}], aufgabe:{frage, hinweis, muster}}` |
| `grammatik` | `{einleitung, punkte:[{name, regel, imText, aufgabe, loesung, hinweis}]}` — 4 Punkte |
| `konnektoren` | `{einleitung, aufgaben:[{typ, satz, frage, loesung, hinweis}]}` — 5–6 Aufgaben |
| `erklaeren` | `{frage, hinweis, muster}` — den Text laut in 30 Sekunden erklären |
| `tipp` | Bezug zum Prüfungsteil des Tages |

**Die Fragen benutzen die Operatoren, die auch in ihren Pflege-Klausuren stehen.** Feld
`operator`, erlaubte Werte: **Nennen**, **Beschreiben**, **Erklären**, **Erläutern**,
**Begründen**. Die Vorlage färbt sie ein und zeigt darüber einen ausklappbaren Kasten, der
erklärt, was jedes Wort verlangt. Pro Text möglichst **alle vier Stufen** vorkommen lassen,
in dieser Reihenfolge: erst *Nennen*, dann *Begründen*, *Erklären*, *Erläutern*.

Und die Musterlösung muss **vormachen**, was der Operator verlangt:
- **Begründen** → im Musterantwort-Text steht sichtbar **weil / da / denn / deshalb**.
- **Erläutern** → die Musterantwort **belegt am Text**: *„Das sieht man daran, dass …“* oder
  ein wörtliches Zitat.
- **Erklären** → verständliche Erklärung **plus eigenes Beispiel**.
- **Nennen** → wirklich nur aufzählen, keine Begründung.

**Der Block `wortschatz` — sie hat gesagt, sie will hier Grammatik und Wortschatz B1/B2 lernen,
nicht nur verstehen.** Also 12–14 Wörter aus dem Text als Tabelle: `wort` mit Artikel und
Stammformen bei unregelmäßigen Verben, `niveau` mit **B1** oder **B2** (die Vorlage färbt es),
`fr` die französische Bedeutung, `imText` **der Satz aus dem Text**, in dem das Wort steht — ein
Wort allein bleibt nicht hängen. Dazu eine `aufgabe`: fünf **eigene** Sätze bilden, über sie
selbst und nicht über die Figur des Textes, bevorzugt mit den B2-Wörtern.

**Der Block `grammatik`** nennt **vier Strukturen, die wirklich in diesem Text stehen** —
nicht irgendeine Grammatik. Je Punkt: `name`, `regel` (kurz, in eigenen Worten), `imText` (die
Stelle), `aufgabe` (umformen oder ergänzen) und `loesung`. Gut geeignet sind die Klassiker, an
denen Französischsprachige scheitern: Nebensatz auf Position 1, Plusquamperfekt,
Infinitiv mit *zu* bei trennbaren Verben, Adjektivendungen, Kasus nach Präposition,
Passiv, Konjunktiv II.

**Der Block `konnektoren`** nimmt die Konnektoren, die **wirklich im Text vorkommen**, und lässt
sie umformen: *aber → obwohl*, *statt … zu → nicht … sondern*, dazu immer einmal die Dreierregel
**weil / denn / deshalb** am selben Inhalt, damit der Unterschied in der **Verbstellung** sichtbar
wird. Das ist gleichzeitig das Training für **Sprachbausteine Teil 1**. In der Lösung immer den
**ganzen Satz** schreiben, nie nur das Konnektor-Wort.

**Die Textsorte richtet sich nach dem Fokus der Lektion**, nicht mehr nach dem Wochentag:
Leseverstehen → **Erzählung oder Reportage** · Hörverstehen → **Bericht** · Sprachbausteine →
Text mit viel **Grammatik der Woche** · Schriftlicher Ausdruck → **Brief oder Anzeige** ·
Mündlicher Ausdruck → Text mit einer **Meinung oder einem Konflikt** (Diskussion, Mündlich
Teil 2).

**Wichtig:** Der Text braucht eine **Handlung** — etwas, das passiert und das man nacherzählen
kann. Eine reine Sachbeschreibung taugt für „Was ist passiert?" nicht. Das Thema kommt aus dem
Wochenthema, das Vokabular aus der laufenden Woche.

Die Seite zählt die Wörter selbst und zeigt sie im Etikett an. Der Text kann vorgelesen werden
(Tempo wählbar). Ihre Antworten werden im Browser gespeichert; die Musterantworten sind
eingeklappt.

**Und in der Antwort an sie immer erwähnen:** Sie soll ihre Antworten schicken — sie werden
korrigiert (Inhalt, Satzbau, Wortwahl), nicht nur gelobt.

### Ihre sieben Baustellen — die Fehler, die wirklich vorkommen

Eigene Seite: `deutsch-taeglich/fehler.html` →
`https://claude.ai/code/artifact/3e941e25-cfd8-4cdc-99f6-3671b2f03365` (Favicon 🧭), verlinkt
im Fuß von Deutsch täglich. Aus der Auswertung aller bisherigen Korrekturen, nach Priorität:

| Nr. | Baustelle | Typische Fehler |
|---|---|---|
| **1** | **Kasus** (rot) | *in Ambulante Pflege* · *bei deine Freundin* · *mit meine Chefin* |
| **2** | **Genus** (rot) | *meinen Geld* · *die Verlust* · *den nächsten Wochenende* |
| 3 | Verbstellung (orange) | *weil morgen, ich Dienst habe* · fehlendes Komma vor dem Nebensatz |
| 4 | Falsche Freunde (orange) | *planieren* · *einen Termin nehmen* · *evident* · *adaptieren* |
| 5 | Komposita (gelb) | *Pflege dienst* · *Praxis Besuch* · *Dienst Plan* |
| 6 | Siezen (gelb) | *ich schicke ihr* statt *Ihnen* · *mit ihnen* statt *mit Ihnen* |
| 7 | Feste Präpositionen (gelb) | *warten auf* + Akk., *fragen nach* + Dativ … |

**Daraus folgt für jede Tageslektion:** Der Block `grammatik` im `lesen`-Teil und die
Korrekturaufgaben im `training` sollen **bevorzugt Baustelle 1 und 2 treffen** — Kasus und
Genus sind zusammen über die Hälfte ihrer Fehler, und ohne richtiges Genus ist kein richtiger
Kasus möglich. Die anderen fünf laufen im Wechsel mit.

**Und wenn sie freie Texte schickt:** Fehler nicht nur korrigieren, sondern **der Baustelle
zuordnen** — „Das ist Baustelle 1: *bei* verlangt immer Dativ." So sieht sie, dass es dieselbe
Regel ist und nicht jedes Mal ein neuer Zufall.

**Drei Beispiele der ursprünglichen Fehlerliste waren falsch** und stehen korrigiert auf der
Seite: *Pflegeung* (es heißt *die Pflege*), *Altum* (gemeint war *das Altertum*) und *System*
als Beleg für die Endung *-tum* (es endet auf *-em*). Solche Beispiele nie ungeprüft übernehmen.

### Der Block `deklination` — die Kette, in jeder Lektion an drei Sätzen

Sie hat gesagt: **„pas d'ajouter comme cela, mais m'apprendre à étudier cela … afin que je ne
fasse plus les mêmes erreurs."** Eine Nachschlageseite reicht nicht — es braucht **regelmäßige
Wiederholung eines festen Verfahrens**. Deshalb hat jede Lektion einen Block `deklination`, und
an den Übungstagen dazwischen werden dieselben drei Sätze noch einmal laut durchgegangen.

Das Verfahren heißt **die Kette**, fünf Fragen in fester Reihenfolge. Eigene Seite:
`deutsch-taeglich/deklination.html` →
`https://claude.ai/code/artifact/aa4ffaa4-f1c0-4b44-85df-86b5bcd70ed1` (Favicon ⛓️).

1. **Wer bestimmt?** Präposition oder Verb — Präposition gewinnt immer.
2. **Welcher Fall?** Liste, bzw. bei Wechselpräpositionen die Frage Wo? / Wohin?
3. **Welches Genus?** der/die/das — bei Komposita entscheidet das letzte Wort.
4. **Welcher Artikel?** Erst jetzt in die Tabelle, Zeile und Spalte stehen schon fest.
5. **Welche Endung?** Zeigt der Artikel den Fall? Ja → **-e/-en**. Nein → Adjektiv springt ein.

**Aufbau des Blocks:** `{titel, stufe, fr, saetze:[{luecke, bestimmer, fall, genus, artikel,
adjektiv, loesung, hinweis}], tipp}` — **genau drei Sätze**, nicht mehr. Die Vorlage zeigt die
Lückenaufgabe, ein Schreibfeld und darunter eingeklappt **die ganze Kette Glied für Glied**,
nicht nur die Lösung. Der Sinn ist, dass sie sieht, **an welchem Glied** es gehakt hat.

**Auswahl der Sätze:** mindestens einer mit **Wechselpräposition** (Wo?/Wohin?), einer mit
einer festen Dativpräposition (*mit, bei, nach, von, zu*), und regelmäßig einer mit **zwei
Objekten** (*Ich gebe der Schwester den Plan* — Dativ vor Akkusativ). Inhalt aus dem
Wochenthema, Wortschatz aus dem Pflegealltag.

**Die sieben Übungsstufen** auf der Seite trainieren je **eine** Entscheidung: 1 Bestimmer
finden · 2 Fall nennen · 3 Genus nennen · 4 Artikel setzen · 5 Adjektivendung · 6 ganzen Satz
bauen · 7 eigene Sätze. Das Feld `stufe` im Block sagt, wo sie gerade steht — die Sätze des
Tages sollen zu dieser Stufe passen und nicht darüber hinausgehen.

**Und wenn sie freie Texte schickt:** jeden Deklinationsfehler dem **Kettenglied** zuordnen —
„Das war Glied 3: es heißt *das* Wochenende." So sieht sie das Muster statt einer Fehlerliste.

### Pflichtinhalt jeder Lektion (an jedem Lektionstag)

Verb des Tages (mit Konjugation und Bedeutung) · Wortschatz-Block (Redemittel **zum Thema der
Woche**) · Grammatik-Block · **`deklination`-Block mit drei Kettensätzen** ·
**`lesen`-Block mit 200-Wörter-Text** · **telc-Block mit dem Fokus der Lektion** ·
Aussprache-Block · Diktat · 5 Übersetzungssätze FR→DE · 3 Alltag-Missionen.

**An einem Samstag, der kein Lektionstag ist:** nur `zyklus` + `probe` — sonst nichts.
**An allen übrigen Tagen gar keine Datei.**

**In der Etappe 1: Verben und Wortschatz auf A2/B1-Niveau wählen**, passend zum Thema der
Lektion. Gut sind häufige trennbare Verben (*anrufen, aufstehen, einkaufen, mitbringen,
vorbereiten, abholen*), reflexive Verben des Alltags (*sich freuen über, sich ärgern über, sich
kümmern um, sich bewerben um*) und die häufigsten Verben mit fester Präposition (*warten auf,
denken an, sich interessieren für, bitten um, sprechen über*). **Kein B2-Wortschatz als
Lernziel.**

**Ab Etappe 2: Verben und Wortschatz auf B2-Niveau.** Dann sind gut: *sich auszeichnen durch*,
*verzichten auf*, *hinweisen auf*, *bestehen auf*, *sich beziehen auf*, Verben des Berichtens und
Argumentierens (*schildern, einschätzen, veranlassen, nachvollziehen, abwägen, einräumen*) und
Nominalisierungen.

Typische Fehler französischsprachiger Lernender ausdrücklich zeigen und korrigieren.

### Archiv

Die 13 Lektionen vom 17.08.–29.08.2026 (altes Schema) liegen in
`deutsch-taeglich/archiv-alt/` mit einer README-Tabelle. Sie gehören **nicht**
zurück in `lektionen/`, außer die Nutzerin bittet ausdrücklich darum.

Die fünf Lektionen vom **30.08.–04.09.2026** hat die Nutzerin am 05.09. ausdrücklich löschen
lassen (*„les autres précédents à effacer"*). Sie liegen **nicht** mehr im Arbeitsbaum, sind
aber über die Git-Historie erreichbar:
`git show 4e8d6dc:deutsch-taeglich/lektionen/2026-09-04.json`. Nur zurückholen, wenn sie
ausdrücklich darum bittet.

---

## Pflegeplanung — eigene Seite, fünf Lerntage

`schulung-pflegeplanung/planung.html` → `https://claude.ai/code/artifact/d1d757ad-782d-4350-bcce-1337702a922f`
Favicon 📋. Auf ihren Wunsch vom 07.09.: *„Je veux que on creer un autre lien uniquement pour les
Pflegeplannung … et que on sexerce a ecrire les Pflegeplannung."*

Aufbau: **eine Spalte pro Tag**, jeweils mit den **Fragen, die man sich stellt**, einem
ausgearbeiteten Beispiel und Übungen mit Schreibfeld und eingeklappter Lösung.
Tag 1 Problem finden (ABEDL, aktuell/potentiell) · Tag 2 P E (S) R · Tag 3 Ziel (SMART,
Nah-/Fernziel) · Tag 4 Maßnahmen (W-Fragen, fünf Hilfeformen) · Tag 5 Begründung.
Krankheitsthemen aus ihren eigenen Unterlagen: Thrombose · Sturz · Haut · Thromboseprophylaxe ·
Linksherzinsuffizienz. Danach Tag 6–10 je eine ganze Planung, **ab Tag 11 Prüfungsaufgaben**.

**Quellen — nur diese:** `schulung-zwischenpruefung/quellen/pflegeplanung-pesr.pdf` (das Blatt der
Dozentin mit ABEDL, PE(S)R, SMART, W-Fragen, Hilfeformen), `PDFs/102-pflegeplanung.pdf`
(Foliensatz CE02 UE2, 6-Schritt-Modell nach Fiechter und Meier, Beispiel Thrombose), die beiden
leeren Vorlagen, `Wissen/109-thrombose.md`, `Wissen/015-sturzprophylaxe.md`,
`Wissen/064-expertenstandard-sturzprophylaxe.md`.

**Wichtig — die Spalte 4 ist auf ihrem Blatt leer.** Das Blatt nennt die Überschrift „Begründung
der Pflegemaßnahmen", gibt aber keine Anleitung dazu. Die vier Begründungsquellen auf der Seite
(Expertenstandard · Prophylaxe · Diagnose · medikamentöse Therapie) sind **abgeleitet** aus dem
gelb markierten Kasten „Bitte zusätzlich berücksichtigen!". Das steht auf der Seite ausdrücklich
so drin, mit der Bitte, es bei der Dozentin zu prüfen. **Nicht als gesichert darstellen.**

Für die Prüfungsaufgaben ab Tag 11 fehlen noch die **Vorlage der Fallvorstellung für die
stationäre und ambulante Langzeitpflege** und das **Beurteilungsprotokoll Teil 1 —
Planungsbeurteilung**. Ohne sie keine Bewertungspunkte erfinden.

---

## Schulungen und Klausuren

- `schulungen/` — Übersichtsseite, gebaut aus `schulungen.json` + `_template.html`
- `schulung-pflegeplanung/` — Pflegeplanung in fünf Tagen (siehe oben)
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
die 16 Themen und die Anmeldekriterien. Bei jeder Änderung am Prüfungsformat **zuerst hier**
nachsehen und diese Seite mitpflegen.
