# Auftrag: einen Artikel für „Krankheiten verstehen“ unabhängig prüfen und korrigieren

Du prüfst **einen** frisch geschriebenen Artikel `krankheiten/artikel/<id>.html` im Repo
`/home/user/Etude-et-revision-exercice-et-Examen`. Lies zuerst `krankheiten/auftrag/schreiben.md` (die Regeln) und
zum Vergleich der Struktur `krankheiten/artikel/copd.html`. Dann lies den zu prüfenden Artikel **ganz**.

## Was du prüfst — und direkt in der Datei korrigierst

1. **Fachlich richtig?** Jede medizinische und pflegerische Aussage. Prüfe stichprobenartig mindestens 15 blaue Quellen
   (öffnen und nachsehen, ob die Aussage dort steht). Falsches korrigieren oder streichen; unbelegte Zahlen streichen oder belegen.
2. **Grüne Marken:** Steht das wirklich in der verlinkten Datei ihrer Unterlagen? Wenn nicht → blau mit echter Quelle oder streichen.
3. **Keine Wikipedia** (Commons für Bilder ist erlaubt), keine Dosierungen, keine Handelsnamen.
4. **Hilfeformen** nur die fünf; **Operatoren** nur die acht; AFB-III-Antworten mit der Kette Ursache → Wirkung → Gefahr → deshalb.
5. **Pflegeplanung** in Kap. 16: PE(S)R vollständig, Ziele SMART, Maßnahmen mit W-Fragen und Hilfeform, Begründung vorhanden.
6. **Keine offenen Fragen** an sie, keine „frag deine Dozentin“-Sätze.
7. **Struktur:** 16 Kapitel mit `id="<id>-kN" data-kap="N"`, `nav.inhalt`, `data-fertig`, `data-feld`-Ids, `<id>-pf/pf2/pf3`,
   `details.frage` mit `.op` in Kap. 14 — Markup wie copd.html. Jedes `<img>` mit width/height; Bilder echte Fotos/Befunde mit Lizenzzeile.
8. **Sprache:** B1, kurze Sätze; Rechtschreibung; französische En-bref-Kästen korrekt.
9. **Fälle:** nur die vorgegebenen Namen, gelb als erfunden markiert, nie „J.“.

## Abgabe

Korrigiere direkt in der Datei (Edit). Nichts anderes ändern, nicht committen. Antworte mit einer nummerierten Liste
**aller Korrekturen** (Kapitel · vorher → nachher · Grund) und am Ende einer Zeile „Freigabe: ja/nein“ mit Begründung.
