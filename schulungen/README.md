# Meine Schulungen — nur noch die Datenquelle

> **Die veroeffentlichte Schulungsseite gibt es nicht mehr.** Sie wurde am **16.09.2026** auf
> ausdruecklichen Wunsch geloescht (*"Du musst 📚 Schulungen mit allen Quellen loeschen."*).
> Das Artifact `70ca4043-…` ist weg und wird **nicht neu angelegt**.
>
> **Dieser Ordner bleibt trotzdem**, weil `schulungen.json` die **Datenquelle** der
> Zusammenfassungsseite ist:
>
> **📖 Meine Kurse, zusammengefasst — https://claude.ai/artifact/7nrNDXtzTUdMquigJJzvZj**
>
> Eine neue Schulung wird also weiterhin **hier** in `schulungen.json` eingetragen; gebaut und
> veroeffentlicht wird danach `zusammenfassungen/` mit `python3 zusammenfassungen/build.py`.
> `schulungen/build.py` und `schulungen/index.html` werden **nicht mehr veroeffentlicht**.
>
> Die Original-PDFs liegen unveraendert im Repo (`schulung-*/quellen/`, `PDFs*/`).

---

## Dateien

| Datei | Wofür |
|---|---|
| `schulungen.json` | Die Liste aller Schulungen — hier wird gepflegt |
| `_template.html` | Das Design der Seite (mit `__DATA__` als Platzhalter) |
| `build.py` | Baut aus JSON + Template die fertige `index.html` |
| `index.html` | Die fertige Seite, die veröffentlicht wird |

## Eine neue Schulung hinzufügen

1. Die Schulung wie gewohnt bauen, z. B. in `schulung-XYZ/`
   (`index.html` = interaktive Schulung, `zusammenfassung.html` = große Zusammenfassung,
   `quellen/` = die Original-PDFs der Dozent*innen).
2. Beide Seiten als Artifact veröffentlichen und die URLs notieren.
3. In `schulungen.json` **ganz oben** in die Liste `schulungen` einen neuen Eintrag setzen:

```json
{
  "id": "kurzname",
  "titel": "Thema der Schulung",
  "untertitel": "Der volle Name der UE",
  "fach": "CE 05",
  "ue": "UE 3",
  "hinweis": "Stichworte, die in der Suche gefunden werden sollen",
  "dozent": "Name der Dozentin / des Dozenten",
  "datum": "2026-09-02",
  "icon": "🫁",
  "ordner": "schulung-kurzname",
  "links": {
    "schulung": "https://claude.ai/code/artifact/…",
    "zusammenfassung": "https://claude.ai/code/artifact/…"
  },
  "highlights": [
    "Was man auf der Seite üben kann",
    "Noch etwas"
  ],
  "quellen": [
    { "name": "Skript des Dozenten", "datei": "dateiname.pdf" }
  ]
}
```

4. Neu bauen und veröffentlichen:

```bash
python3 schulungen/build.py
# danach schulungen/index.html erneut als Artifact veröffentlichen
# (gleicher Dateipfad -> gleiche URL)
```

## Felder

- **`links.zusammenfassung`** ist optional — fehlt sie, wird nur die Schulung verlinkt.
- **`quellen`** = PDFs im Unterordner `quellen/` der Schulung.
- **`dateien`** = optional, weitere Dateien direkt im Schulungs-Ordner (z. B. `.md`).
- **`datum`** steuert die Sortierung und die Monats-Überschriften. Format `JJJJ-MM-TT`.
- **`fach`** erzeugt automatisch einen Filter-Chip oben auf der Seite.

## Weitere Lernmittel

Der Block `weitere` unten in der JSON ist für Dinge, die keine Schulung sind
(Lern-Hub, Deutsch täglich). Gleiche Logik, nur weniger Felder.
