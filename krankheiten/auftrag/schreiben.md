# Auftrag: einen Artikel für „Krankheiten verstehen“ schreiben

Du schreibst **einen** Fachartikel über eine Krankheit für eine französischsprachige Pflegeauszubildende
(2. Lehrjahr, generalistische Ausbildung, NRW, Deutsch B1). Der Artikel kommt in ihr Buch „Krankheiten
verstehen“ (`krankheiten/`). Repo: `/home/user/Etude-et-revision-exercice-et-Examen`.

Dein Auftrag nennt: **Krankheit**, **id** (Dateiname/Präfix), **Kategorie** (für `<span class="nr">Artikel · …</span>`),
**Namen für die Fälle** in Kapitel 2 und Kapitel 16 und **Fundstellen in ihren Unterlagen** (falls vorhanden).

## 1. Die Vorlage: `krankheiten/artikel/copd.html` — Struktur genau übernehmen

Lies `krankheiten/artikel/copd.html` **ganz** (und zum Vergleich `niereninsuffizienz.html`). Dein Artikel hat
**dieselbe Struktur, dieselben Klassen und dasselbe Id-Schema** — nur mit deinem Präfix statt `copd`:

- `<article id="<id>">` · Kopf `.wrap.artkopf` (`.nr`, `h2`, `.unter`, `.meta` mit `16 Kapitel`, Lesezeit, `Stand <heutiges Datum>`,
  `<span class="lesestand">0 von 16 Kapiteln gelesen</span>`) · `nav.inhalt` mit 16 Links `#<id>-k1 … #<id>-k16`.
- **16 Kapitel**, je `<section class="kap" id="<id>-kN" data-kap="N">` mit `<h3><span class="k">Kapitel N</span>Titel</h3>`,
  `p.vorspann`, Inhalt, am Ende `.enbref` („🇫🇷 En bref“, 3–5 Sätze Französisch) und das `label.gelesen` wie in der Vorlage.
- Gliederung (an die Krankheit angepasst, Reihenfolge fest):
  1 Auf einen Blick · 2 Ein Fall (Geschichte mit Handlung, erfunden, **gelb** markiert) · 3 Geschichte der Krankheit ·
  4 Was man vom Organ/System wissen muss (Anatomie/Physiologie, einfach) · 5 Was im Körper passiert (Pathophysiologie, mit `.kette`) ·
  6 Wer bekommt es — und warum (Ursachen, Risikofaktoren) · 7 Die Symptome — **Symptomkarten** (`.symkarte`, 7–10 Stück, je
  „So sieht es aus · Was im Körper passiert · System/Bahn/Nerv · Was du tust“ mit `.sk-zeile`/`.sk-k` wie in der Vorlage) ·
  8 Erkennen (Diagnostik) · 9 Komplikationen / Notfall · 10 Die Medikamente — Kasten „Bei jedem Notfall zuerst“ + **Medikamentenkarten**
  (`.medkarte`, Wirkstoffgruppen bzw. Wirkstoffe, je **So wirkt es · Nebenwirkungen · Das erwartest du · Gefährlich — du findest ihn so ·
  Sofort tun**) · 11 Ohne Medikamente · 12 Die Pflege (mit Prophylaxen, Beobachtung, Beratung) · 13 Leben damit ·
  14 Prüfungsfragen (8–12 `details.frage` mit `.op` = Operator, Musterantwort in `.antw`) · 15 Wörterbuch DE–FR (`.glossar`) und
  Quellen (`.quellen`) · 16 Abschluss: Übungsfall + 7 Fallfragen mit Operatoren + „So schreibst du eine Pflegeplanung“ +
  **Prüfungsmodus** (Uhr 1 h 30, drei Pflegeprobleme mit Feldern `data-feld="<id>-p1-pesr"`, `-ziel`, `-mass`, `-begr` usw.,
  Ids `<id>-pf`, `<id>-pf2`, `<id>-pf3`, `<id>-f1t…`, Abgabe-Box, Kopier-Knopf, Musterlösung `details.muster`,
  `data-fertig="<id>"`) — **Markup exakt wie in copd.html Kap. 16**, nur Inhalt und Präfix tauschen.
- Umfang wie die Vorlage: ca. 7 000–10 000 Wörter.
- **Kein `<script>`, kein `<style>`** im Fragment — das Buch bringt alles mit.

## 2. Inhaltsregeln (nicht verhandelbar)

- **Sprache:** Deutsch B1 — kurze Sätze, Fachwörter in Klammern erklärt; je Kapitel ein französisches „En bref“.
- **Herkunftsmarken an jeder Aussage**, genau wie in der Vorlage:
  `<a class="q du" href="…">deine Unterlagen</a>` (grün — aus IHREN Dateien im Repo, Link auf die Datei auf GitHub:
  `https://github.com/Williamszika/Etude-et-revision-exercice-et-Examen/blob/claude/nursing-exam-prep-workflow-gvn5u0/<pfad>`),
  `<a class="q net" href="…">Quelle</a>` (blau — seriöse Internetquelle mit Link: AWMF-Leitlinien, RKI, gesund.bund.de, BfArM,
  Deutsche Gesellschaften, Apotheken Umschau, DocCheck Flexikon, MSD Manual, Ärzteblatt, Springer … **nie Wikipedia**),
  `<span class="q ich">Herleitung</span>` (gelb — deine eigene Folgerung, erfundene Fälle, Übungsergänzungen).
- **Ihre Unterlagen zuerst:** Suche mit `grep -ril "<Stichwort>" Wissen/ schulung-*/ Lernmaterial/` und lies die Fundstellen,
  die dein Auftrag nennt. Was dort steht, kommt grün hinein. Was dort **nicht** steht, holst du aus dem Internet (blau, mit Link,
  „abgerufen <Datum>“ in der Quellenliste). Nichts erfinden: keine Zahl, Norm, Grenze oder Studie ohne Quelle.
- **Medikamente:** Wirkstoffe/Wirkstoffgruppen, **keine Dosierungen, keine Handelsnamen**. 5-R-Regel aus der Vorlage übernehmen.
- **Hilfeformen nur diese fünf:** Beaufsichtigung, Anleitung, Unterstützung, teilweise Übernahme, vollständige Übernahme
  („Beratung“ ist keine Hilfeform).
- **Operatoren nur diese acht:** Nennen (AFB I), Beschreiben (I), Erklären (—), Erarbeiten (II), Erläutern (II), Ableiten (II),
  Begründen (III), Beurteilen (III). Antworten auf AFB III zeigen sichtbar die Kette **Ursache → Wirkung → Gefahr → deshalb tue ich …**.
- **Pflegeplanung** nach ihrem Blatt (PE(S)R, SMART-Ziel, W-Fragen bei Maßnahmen, Begründung) — Vorbild Kap. 16 der Vorlage.
- **Keine offenen Fragen** an sie („frag deine Dozentin“ o. Ä. ist verboten) — was nicht belegt ist, steht als „nicht belegt“ da.
- **Fälle:** nur die Namen aus deinem Auftrag, ausdrücklich als erfunden (gelb) markiert. Nie „J.“ verwenden. Keine echten Personen.
- **Pflegealltag:** Setting bevorzugt **Krankenhaus** (ihre Zwischenprüfung ist im Krankenhaus), sonst passend zur Krankheit.

## 3. Bilder — nur echte Fotos und echte Befunde

- 4–7 Bilder: **echte Fotos, Röntgen/CT/Mikroskopie, Präparate, historische Porträts** von **Wikimedia Commons** mit freier Lizenz
  (CC0, gemeinfrei, CC BY, CC BY-SA). **Keine KI-Bilder, keine Zeichnungen, keine Canva-Grafiken**. Eigene einfache SVG-Schemata
  zusätzlich sind erlaubt (Stil wie in der Vorlage, Farben über die Klassen dort).
- Herunterladen über die Commons-API (`https://commons.wikimedia.org/w/api.php?action=query&titles=File:…&prop=imageinfo&iiprop=url|extmetadata&iiurlwidth=900&format=json`),
  die Thumbnail-URL laden (User-Agent setzen; bei HTTP 429 warten und erneut versuchen), mit Python/Pillow auf **max. 900 px Breite,
  JPEG Qualität ~72** verkleinern, als `data:image/jpeg;base64,…` einbetten. Jedes `<img>` hat **`width` und `height`**
  (echte Pixelmaße) und `alt`. Darunter `.bildherkunft` mit Urheber, Lizenz, Link — wie in der Vorlage. In die Quellenliste aufnehmen.
- Keine Fotos, auf denen ein Mensch erkennbar und nicht historisch/öffentlich ist, außer die Lizenz und der Zweck sind eindeutig
  (z. B. Lehrfotos von Hautbefunden). Gesamtgröße der Datei unter 1,2 MB.

## 4. Abgabe

- Schreibe **nur** die Datei `krankheiten/artikel/<id>.html` (neu). **Nichts anderes ändern**, nicht committen, nicht veröffentlichen.
- Prüfe am Ende selbst:
  `python3 -c` mit einem kleinen Vergleich: alle 16 `id="<id>-kN"`, `data-fertig="<id>"`, die `data-feld`-Ids der drei Probleme,
  `<id>-pf`, `<id>-pf2`, `<id>-pf3` vorhanden; jedes `<img>` mit width/height; kein `wikipedia.org` außer in Commons-Links
  (`commons.wikimedia.org` ist erlaubt); keine Dosierungen (`mg`, `µg`, `IE` mit Zahl) und keine Handelsnamen mit ®.
- Antworte mit: Dateigröße, Wortzahl, Liste der Bilder (Titel, Lizenz), welche ihrer Dateien du benutzt hast, und was du
  bewusst weggelassen hast, weil es nicht belegt war.
