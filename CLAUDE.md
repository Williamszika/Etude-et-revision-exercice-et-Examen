# Arbeitsanweisungen für dieses Repo

Nutzerin: französischsprachige Pflegeauszubildende, 2. Lehrjahr, generalistische
Ausbildung, NRW. Erklärungen auf Französisch, Fachinhalte und Beispiele auf Deutsch.

**Grundregel für alles in diesem Repo:** nichts erfinden. Keine Paragraphen, Normen,
Zahlen oder Quellen nennen, die nicht in ihren eigenen Unterlagen (PDFs im Repo) stehen.

---

## Deutsch täglich — tägliche Routine um 5:30

Diese Anweisung gilt **immer** und hat Vorrang vor älteren Routine-Texten.

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

### Die 13 Themen, in dieser Reihenfolge

| Nr | Thema |
|----|-------|
| 1 | Verb auf Platz 2 |
| 2 | Verb ans Ende im Nebensatz |
| 3 | Fragen bilden |
| 4 | Imperativ und höfliche Bitte |
| 5 | Konjunktiv II |
| 6 | Relativsätze |
| 7 | Passiv mit Modalverben |
| 8 | Indirekte Rede |
| 9 | Partizipien als Adjektive |
| 10 | Nominalisierung |
| 11 | Kausale und konzessive Konnektoren |
| 12 | Futur I |
| 13 | Komparativ und Superlativ |

Start: **30.08.2026 = Thema 1, Tag 1.**

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
Grammatik-Block · Aussprache-Block · Diktat · 5 Übersetzungssätze FR→DE ·
3 Alltag-Missionen.

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
