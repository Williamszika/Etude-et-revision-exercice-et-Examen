export const meta = {
  name: 'klausur-prep-run',
  description: 'Grand run : liest 109 Pflege-Dokumente vollständig, kategorisiert, erstellt gründliche Zusammenfassungen, Übungen, Fallbeispiele und Klausuren auf Deutsch (B2)',
  phases: [
    { title: 'Lesen', detail: 'Ein Agent pro Dokument: Volltext, Bilder, Schemata, OCR' },
    { title: 'Kategorisieren', detail: 'Themenkarte über alle Dokumente' },
    { title: 'Erstellen', detail: 'Pro Thema: Zusammenfassung, Übungen, Fallbeispiel, Klausur' },
    { title: 'Prüfen', detail: 'Fachliche Richtigkeit + Sprachniveau B2' },
    { title: 'Gesamtklausur', detail: 'Themenübergreifende Probeklausur + Lernplan' },
  ],
}

const pdfs = [
"PDFs/01-wahrnehmung-und-beobachtung.pdf","PDFs/02-unterstuetzung-beim-essen.pdf","PDFs/03-suprapubische-harndrainage.pdf","PDFs/04-tinetti-test.pdf","PDFs/05-wahrnehmungsstoerung-tafelbild.md","PDFs/06-sturzrisiko-godo-system.pdf","PDFs/07-dermatomykose.pdf","PDFs/08-inkontinenzassoziierte-dermatitis-iad.pdf","PDFs/09-intertrigo.pdf","PDFs/10-juckreiz.pdf","PDFs/11-stuhlbeobachtung.pdf","PDFs/12-stuhlinkontinenz.pdf","PDFs/13-stundennachweis-pflichteinsaetze.pdf","PDFs/14-sturzdokumentation-godo.pdf","PDFs/15-sturzprophylaxe.pdf","PDFs/16-quellstoffe.pdf","PDFs/17-rasur-und-bartpflege.pdf","PDFs/18-schleimhautreizende-mittel.pdf","PDFs/19-sppb-short-physical-performance-battery.pdf","PDFs/20-srw-syndrom-reaktionslose-wachheit-tafelbild.md","PDFs/21-anatomie-skelettmuskulatur.pdf","PDFs/22-anatomie-muskelgewebe.pdf","PDFs/23-prinzipien-der-koerperpflege.pdf","PDFs/24-puls-und-blutdruck.pdf","PDFs/25-quellen-puls-und-blutdruck.pdf","PDFs/26-orientierungsstoerung-tafelbild.md","PDFs/28-osmotische-mittel.pdf","PDFs/29-pflege-bei-fieber.pdf","PDFs/30-pflegeplanung-vorlage.pdf","PDFs/31-methoden-injektionsstellen.pdf","PDFs/32-mna-mini-nutritional-assessment.pdf","PDFs/33-mundgesundheit-und-medikamente.pdf","PDFs/34-nutritional-risk-screening.pdf","PDFs/35-obstipation.pdf","PDFs/36-juckreiz-b.pdf","PDFs/37-koerpertemperatur.pdf","PDFs/38-kontinenzprofile.pdf","PDFs/39-malnutrition-universal-screening-tool.pdf","PDFs/40-mangelernaehrung.pdf","PDFs/41-venolen-und-venen.pdf","PDFs/42-iad-b.pdf","PDFs/43-intertrigo-b.pdf","PDFs/44-intimpflege-ablauf.pdf","PDFs/45-intramuskulaere-injektion.pdf","PDFs/46-hautbeobachtung.pdf","PDFs/47-huhn-sturzrisiko-skala.pdf","PDFs/48-arterien.pdf","PDFs/49-kapillaren.pdf","PDFs/50-koerperkreislauf.pdf","PDFs/51-gleitmittel.pdf","PDFs/52-grundlagen-wasserhaushalt.pdf","PDFs/53-habam-balance-mobility.pdf","PDFs/54-handlungsschritte-katheterisierung.pdf","PDFs/55-harnblasenkatheter-arbeitsauftraege.md","PDFs/56-expertenstandard-mobilitaet.pdf","PDFs/57-festgenagelt-zegelin.pdf","PDFs/58-fragen-muskelgewebe.pdf","PDFs/59-fragen-skelettmuskulatur.pdf","PDFs/60-geistige-behinderung-tafelbild.md","PDFs/61-ebomo-bewegung.pdf","PDFs/62-erhebung-abedl.pdf","PDFs/63-erhebung-lebensaktivitaeten-lh.pdf","PDFs/64-ernaehrung-pemu.pdf","PDFs/65-expertenstandard.pdf","PDFs/66-diarrhoe.pdf","PDFs/67-bettlaegerigkeit-fuenf-phasen-praevention.pdf","PDFs/68-motorische-entwicklung-baby.pdf","PDFs/69-die-rasur.pdf","PDFs/70-ebomo-leitfaden.pdf","PDFs/71-blutdruck-messung-durchfuehrung.pdf","PDFs/72-checkliste-koerperpflege.pdf","PDFs/73-defaekationsvorgang.pdf","PDFs/74-dermatomykose-b.pdf","PDFs/75-denkstoerungen-tafelbild.md","PDFs/76-beckenquerschnitte-arbeitsblatt.pdf","PDFs/77-besonderheiten-neugeborene.pdf","PDFs/78-bewegungsanalyse.pdf","PDFs/79-laxanzien-bilder.pdf","PDFs/80-blutdruck-messung-komplett.pdf","PDFs/81-aspirationsprophylaxe.pdf","PDFs/82-assessment-demmi.pdf","PDFs/83-atembeobachtung-teil-1.pdf","PDFs/84-atembeobachtung-teil-2.pdf","PDFs/85-barthel-index.pdf","PDFs/86-arbeitsauftrag-suprapubische-harndrainage.pdf","PDFs/87-arbeitsauftrag-bart-rasurpflege.pdf","PDFs/88-arbeitsheft-grundlagenwissen.pdf","PDFs/89-arten-von-beobachtung.pdf","PDFs/90-ableitende-inkontinenzversorgung.pdf","PDFs/91-risikofaktoren-inkontinenz.pdf","PDFs/92-fallbeispiel-dehydratation-frau-sommer.pdf","PDFs/93-anatomie-mund-zaehne.pdf","PDFs/94-anatomie-physiologie-haut.pdf","PDFs/95-arbeitsauftrag-nsv.pdf","PDFs/96-aa-aspirationsprophylaxe.pdf","PDFs/97-aa-kriterien-beobachtung-bewegung.pdf","PDFs/98-aa-kriterien-gangbild-lebensphasen.pdf","PDFs/99-aa-prozess-bettlaegerigwerden.pdf","PDFs/100-harninkontinenzformen.pdf","PDFs/101-aa-munderkrankungen.pdf","PDFs/102-pflegeplanung.pdf","PDFs/103-intramuskulaere-injektion-b.pdf","PDFs/104-recht.pdf","PDFs/105-urin-und-miktionsbeobachtung.pdf","PDFs/106-anatomie-und-physiologie.pdf","PDFs/107-mund-und-zahnpflege.pdf","PDFs/108-subkutane-injektion.pdf","PDFs/109-kontinenzanamnese-skript.pdf","PDFs/110-thrombose.pdf"
]

const KONVENTIONEN = 'ressources/klausur-konventionen.md'
const B2_REGEL = `Sprache: Deutsch, Niveau B2. Fachbegriffe (medizinische/pflegerische Termini) IMMER
verwenden, aber beim ersten Auftreten kurz in Klammern einfach erklären. Klare, nicht zu
verschachtelte Sätze. Die Schülerin hat Französisch als Muttersprache — bei besonders schwierigen
Schlüsselbegriffen darf einmalig die französische Entsprechung in [fr: …] ergänzt werden.`
const NOTENSCHLUESSEL = `Notenschlüssel Nordrhein-Westfalen (NRW): 1 = 100–90 %, 2 = 89–75 %,
3 = 74–60 %, 4 = 59–50 %, 5 = 49–35 %, 6 = 34–0 %. Bestehensgrenze 50 %.`

// ---- Schemas ---------------------------------------------------------------
const EXTRAKT_SCHEMA = {
  type: 'object', required: ['datei', 'titel', 'themen', 'wissensdatei'],
  properties: {
    datei: { type: 'string' }, titel: { type: 'string' },
    themen: { type: 'array', items: { type: 'string' } },
    kernbegriffe: { type: 'array', items: { type: 'string' } },
    dokumenttyp: { type: 'string', description: 'z.B. Informationstext, Assessment/Skala, Arbeitsauftrag, Präsentation, Fallbeispiel, Tafelbild, Formular' },
    wissensdatei: { type: 'string' },
  },
}
const KATEGORIEN_SCHEMA = {
  type: 'object', required: ['kategorien'],
  properties: { kategorien: { type: 'array', items: {
    type: 'object', required: ['name', 'ordner', 'wissensdateien'],
    properties: {
      name: { type: 'string' }, ordner: { type: 'string' },
      unterthemen: { type: 'array', items: { type: 'string' } },
      wissensdateien: { type: 'array', items: { type: 'string' } },
    },
  } } },
}
const DATEIEN_SCHEMA = { type: 'object', required: ['dateien'], properties: { dateien: { type: 'array', items: { type: 'string' } } } }
const PRUEF_SCHEMA = {
  type: 'object', required: ['fachlichOk', 'sprachlichOk', 'korrekturen'],
  properties: { fachlichOk: { type: 'boolean' }, sprachlichOk: { type: 'boolean' }, korrekturen: { type: 'array', items: { type: 'string' } } },
}

// ---- Phase 1: Lesen --------------------------------------------------------
log(`${pdfs.length} Dokumente werden vollständig gelesen…`)
const extrakte = (await pipeline(
  pdfs,
  (pdf, _item, i) => agent(
    `Lies das Dokument "${pdf}" VOLLSTÄNDIG mit dem Read-Tool. Bei PDFs den Parameter "pages"
nutzen (max. 20 Seiten pro Aufruf) und so lange weiterlesen, bis ALLE Seiten gelesen sind — auch
bei sehr langen Dokumenten (z. B. 170 Seiten). Bei .md-Dateien den ganzen Text lesen.

Aufgaben:
1. Extrahiere den gesamten Textinhalt.
2. Beschreibe JEDE Abbildung, jedes Schema, jede Tabelle, jedes Foto ausführlich (Inhalt,
   Beschriftungen, pflegerische/medizinische Bedeutung). Anatomie-Abbildungen: alle beschrifteten
   Strukturen auflisten.
3. Fototexte/Tafelbilder/handschriftliche Notizen vollständig transkribieren (OCR).
4. Schreibe ALLES strukturiert nach "Wissen/${String(i + 1).padStart(3, '0')}-<slug>.md"
   (slug aus dem Titel, klein, Bindestriche). Struktur: # Titel / ## Quelle: ${pdf} /
   ## Dokumenttyp / ## Inhalt (nach Abschnitten) / ## Abbildungen & Tabellen /
   ## Transkribierte Fototexte / ## Kernbegriffe (Glossar).
5. Nichts weglassen — das ist die Wissensbasis für die weiteren Agenten.

Gib das strukturierte Objekt zurück (wissensdatei = tatsächlich geschriebener Pfad).`,
    { label: `lesen:${pdf.split('/').pop()}`, phase: 'Lesen', schema: EXTRAKT_SCHEMA }
  )
)).filter(Boolean)

if (extrakte.length === 0) throw new Error('Kein Dokument konnte gelesen werden.')
log(`${extrakte.length}/${pdfs.length} Dokumente gelesen. Kategorisierung startet…`)

// ---- Phase 2: Kategorisieren (mit Wiederholung) ----------------------------
phase('Kategorisieren')
const KAT_PROMPT = `Hier sind die Extrakte von ${extrakte.length} Kurs-Dokumenten einer Pflege-
auszubildenden (2. Lehrjahr, generalistische Ausbildung, NRW):

${JSON.stringify(extrakte.map(e => ({ datei: e.datei, titel: e.titel, themen: e.themen, typ: e.dokumenttyp, wissensdatei: e.wissensdatei })), null, 2)}

Bilde 8–14 sinnvolle, klausurrelevante Themen-Kategorien (nach Krankheitsbildern / Pflege-
phänomenen / Techniken / Anatomie / Recht). Beispiele, die sich hier anbieten: „Beobachtung &
Wahrnehmung", „Bewusstseins- & Denkstörungen", „Vitalzeichen (Puls, Blutdruck, Temperatur, Atmung)",
„Haut & Hauterkrankungen", „Bewegung, Sturz & Mobilität (Assessments)", „Ausscheidung: Harn &
Kontinenz", „Ausscheidung: Stuhl", „Ernährung & Flüssigkeit (Screenings)", „Injektionen (s.c./i.m.)",
„Körper- & Mundpflege", „Anatomie & Physiologie", „Pflegeprozess/Assessments & Recht". Fasse
Dubletten (z. B. mehrere Dateien zu Intertrigo/IAD/Juckreiz) in EINER Kategorie zusammen. Ein
Dokument darf zu mehreren Kategorien gehören. Assessments/Skalen der passenden Fachkategorie zuordnen.

Schreibe eine Themenkarte nach "Wissen/00-themenkarte.md" (Überblick, Unterthemen, zugehörige
Dateien, Zusammenhänge; ein Mermaid-Diagramm ist erlaubt). Gib die Kategorienliste zurück.`

let katResult = null
for (let versuch = 1; versuch <= 3 && !katResult; versuch++) {
  katResult = await agent(KAT_PROMPT, { label: `themenkarte#${versuch}`, schema: KATEGORIEN_SCHEMA })
  if (!katResult) log(`Kategorisierung Versuch ${versuch} fehlgeschlagen…`)
}
if (!katResult || !Array.isArray(katResult.kategorien) || katResult.kategorien.length === 0) {
  throw new Error('Kategorisierung nach 3 Versuchen fehlgeschlagen (vermutlich Session-Limit). ' +
    'Später erneut resümieren: Wissen/-Extrakte sind gespeichert.')
}
const kategorien = katResult.kategorien
log(`${kategorien.length} Kategorien: ${kategorien.map(k => k.name).join(' · ')}`)

// ---- Phase 3+4: Erstellen + Prüfen (pipeline) ------------------------------
const MATERIAL_AUFTRAG = (k) => `Du erstellst hochwertiges Lernmaterial für eine Pflegeauszubildende
(2. Lehrjahr, generalistische Pflegeausbildung, NRW, Muttersprache Französisch). Nimm dir Zeit und
arbeite gründlich. ${B2_REGEL}

Kategorie: "${k.name}" — Unterthemen: ${(k.unterthemen || []).join(', ')}
Wissensbasis (ZUERST alle Dateien vollständig lesen): ${k.wissensdateien.join(', ')}
Klausur-Konventionen (ZUERST lesen): ${KONVENTIONEN} — halte dich an Operatoren, AFB-Verteilung
(ca. 30/40/30) und Fallbeispiel-Struktur. ${NOTENSCHLUESSEL}

Erstelle im Ordner "Lernmaterial/${k.ordner}/" vier Dateien:

1. zusammenfassung.md — eine SEHR GUTE, gründliche Zusammenfassung (das Herzstück). Aufbau:
   - Kurzer Überblick „Worum geht es?" (2–3 Sätze)
   - Definitionen; Anatomie/Physiologie-Grundlagen soweit relevant
   - Ursachen / Entstehung (Pathophysiologie einfach erklärt)
   - Symptome / Erscheinungsbild / Risikofaktoren
   - Beobachtung & Assessment (welche Skalen/Instrumente, welche Kriterien) — mit Normwerten,
     wo sinnvoll (z. B. Puls 60–100/min, RR ~120/80, Temperatur-Bereiche)
   - PFLEGE: konkrete Maßnahmen, Prophylaxen, Durchführung (Schritt für Schritt bei Techniken),
     Beratung, was zu dokumentieren ist
   - Merksätze / Eselsbrücken
   - Glossar der wichtigsten Fachbegriffe (Deutsch mit einfacher Erklärung)
   Nutze Tabellen, Aufzählungen und Zwischenüberschriften, damit es gut lernbar ist.

2. uebungen.md — mind. 15 Übungen, gestaffelt nach AFB (I ca. 40 %, II ca. 40 %, III ca. 20 %)
   mit den Operatoren (Nennen/Beschreiben; Erklären/Erläutern/Vergleichen/Zuordnen; Begründen/
   Beurteilen). Dazu: 5 Multiple-Choice, 1 Zuordnungsaufgabe, 1 Lückentext, 1 Reihenfolge-Aufgabe.
   Jede Übung mit **Lösung:** direkt darunter und Punktzahl.

3. fallbeispiel.md — ein realistisches Fallbeispiel wie in einer echten Klausur: Situations-
   beschreibung (Patient/in mit Name, Alter, Anamnese, aktuelle Situation, gern mit Zitat),
   6–8 Aufgaben mit Operatoren (AFB I→III, Progression), Punkte pro Aufgabe, danach vollständiger
   Erwartungshorizont.

4. klausur.md — Themen-Klausur (45 Min, ca. 50 Punkte): Deckblatt (Thema, Zeit, Punkte,
   Notenschlüssel NRW), 6–10 Aufgaben (Operatoren + 1 kleines Fallbeispiel + 3–4 MC), danach
   getrennter Erwartungshorizont mit Punkteverteilung.

Alle Inhalte MÜSSEN aus der Wissensbasis stammen; sinnvolle fachliche Ergänzungen mit „[Ergänzung]"
markieren. Gib die Liste der geschriebenen Dateien zurück.`

const material = (await pipeline(
  kategorien,
  (k) => agent(MATERIAL_AUFTRAG(k), { label: `material:${k.ordner}`, phase: 'Erstellen', schema: DATEIEN_SCHEMA })
    .then(r => ({ kategorie: k, dateien: r.dateien })),
  (m) => m && agent(
    `Qualitätsprüfung für Pflege-Lernmaterial (2. Lehrjahr). Lies: ${m.dateien.join(', ')}
und vergleiche mit der Wissensbasis: ${m.kategorie.wissensdateien.join(', ')}.

Prüfe und KORRIGIERE direkt (Edit-Tool):
1. Fachliche Richtigkeit (aktuelle Expertenstandards/Leitlinien; keine gefährlichen oder
   veralteten Aussagen bei Medikamenten, Hygiene, Injektionen, Notfall). Normwerte prüfen.
2. Vollständigkeit ggü. der Wissensbasis (nichts Wichtiges aus den Dokumenten vergessen).
3. Sprachniveau B2: zu komplizierte Sätze vereinfachen, Fachbegriffe erklären.
4. Jede Übung hat Lösung + Punkte; Klausur hat Erwartungshorizont + Notenschlüssel NRW.

Gib das Prüfergebnis zurück.`,
    { label: `pruefen:${m.kategorie.ordner}`, phase: 'Prüfen', schema: PRUEF_SCHEMA }
  ).then(p => ({ ...m, pruefung: p }))
)).filter(Boolean)

// ---- Phase 5: Gesamtklausur + Lernplan -------------------------------------
phase('Gesamtklausur')
const gesamt = await agent(
  `Erstelle eine themenübergreifende PROBEKLAUSUR (90 Minuten, 100 Punkte) für eine Pflege-
auszubildende im 2. Lehrjahr (NRW) über ALLE Kategorien:
${material.map(m => `- ${m.kategorie.name} (Wissen: ${m.kategorie.wissensdateien.slice(0,4).join(', ')}${m.kategorie.wissensdateien.length>4?' …':''})`).join('\n')}

Lies zuerst ${KONVENTIONEN}. ${B2_REGEL} ${NOTENSCHLUESSEL}

Schreibe "Lernmaterial/00-probeklausur.md":
- Deckblatt (Fach, 90 Min, 100 P, Notenschlüssel NRW, Hilfsmittel)
- Teil A: 10 Multiple-Choice (20 P) quer über die Themen
- Teil B: Wissensfragen mit Operatoren AFB I–II (40 P)
- Teil C: ein großes Fallbeispiel, das MEHRERE Themen verbindet (z. B. eine ältere,
  bettlägerige Person mit Sturz-, Haut-, Kontinenz- und Ernährungsproblemen), 6 Aufgaben
  AFB II–III (40 P)
- danach vollständiger Erwartungshorizont mit Punkteverteilung.

Schreibe außerdem "Lernmaterial/00-lernplan.md": ein konkreter Lernplan (Reihenfolge der Themen,
wie die Zusammenfassungen/Übungen/Klausuren zeitlich zu nutzen sind, Wiederholungsintervalle,
Tipps zum Umgang mit Operatoren). Gib die geschriebenen Dateien zurück.`,
  { label: 'probeklausur+lernplan', schema: DATEIEN_SCHEMA }
)

return {
  gelesen: `${extrakte.length}/${pdfs.length}`,
  kategorien: material.map(m => ({
    name: m.kategorie.name, ordner: m.kategorie.ordner, dateien: m.dateien,
    fachlichOk: m.pruefung?.fachlichOk ?? null, korrekturen: (m.pruefung?.korrekturen || []).length,
  })),
  probeklausur: gesamt.dateien,
}
