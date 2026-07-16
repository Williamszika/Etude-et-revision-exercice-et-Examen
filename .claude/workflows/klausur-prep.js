export const meta = {
  name: 'klausur-prep',
  description: 'Liest Pflege-PDFs vollständig (Text + Bilder + OCR), kategorisiert sie, erstellt Zusammenfassungen, Übungen, Fallbeispiele und Klausuren auf Deutsch (B2)',
  whenToUse: 'Quand l\'utilisateur a déposé des PDFs de cours (dossier PDFs/) et veut générer son matériel de révision. args = { pdfs: ["PDFs/x.pdf", ...] }',
  phases: [
    { title: 'Lesen', detail: 'Ein Agent pro PDF: Volltext, Bilder, Schemata, OCR von Fototexten' },
    { title: 'Kategorisieren', detail: 'Themenkarte über alle PDFs erstellen' },
    { title: 'Erstellen', detail: 'Pro Thema: Zusammenfassung, Übungen, Fallbeispiel, Klausur (B2)' },
    { title: 'Gesamtklausur', detail: 'Themenübergreifende Probeklausur (90 Min) mit Erwartungshorizont' },
    { title: 'Prüfen', detail: 'Fachliche Richtigkeit + Sprachniveau B2 kontrollieren und korrigieren' },
  ],
}

// ---- Eingaben prüfen -------------------------------------------------------
if (!args || !Array.isArray(args.pdfs) || args.pdfs.length === 0) {
  throw new Error('args.pdfs fehlt: Liste der PDF-Pfade übergeben, z.B. { "pdfs": ["PDFs/diabetes.pdf"] }')
}
const pdfs = args.pdfs
const KONVENTIONEN = 'ressources/klausur-konventionen.md'
const B2_REGEL = `Sprache: Deutsch, Niveau B2. Fachbegriffe (medizinische/pflegerische Termini) IMMER verwenden,
aber beim ersten Auftreten kurz in Klammern einfach erklären. Sätze klar und nicht zu verschachtelt.`

// ---- Schemas ---------------------------------------------------------------
const EXTRAKT_SCHEMA = {
  type: 'object',
  required: ['datei', 'titel', 'themen', 'wissensdatei'],
  properties: {
    datei: { type: 'string' },
    titel: { type: 'string', description: 'Titel/Thema des PDFs' },
    themen: { type: 'array', items: { type: 'string' }, description: 'Behandelte Pflegethemen' },
    kernbegriffe: { type: 'array', items: { type: 'string' } },
    anzahlSeiten: { type: 'number' },
    anzahlAbbildungen: { type: 'number' },
    wissensdatei: { type: 'string', description: 'Pfad der geschriebenen Wissen/-Datei' },
  },
}

const KATEGORIEN_SCHEMA = {
  type: 'object',
  required: ['kategorien'],
  properties: {
    kategorien: {
      type: 'array',
      items: {
        type: 'object',
        required: ['name', 'ordner', 'wissensdateien'],
        properties: {
          name: { type: 'string', description: 'z.B. "Diabetes mellitus", "Wundmanagement"' },
          ordner: { type: 'string', description: 'Ordnername ohne Sonderzeichen, z.B. "diabetes-mellitus"' },
          unterthemen: { type: 'array', items: { type: 'string' } },
          wissensdateien: { type: 'array', items: { type: 'string' } },
        },
      },
    },
  },
}

const DATEIEN_SCHEMA = {
  type: 'object',
  required: ['dateien'],
  properties: { dateien: { type: 'array', items: { type: 'string' } } },
}

const PRUEF_SCHEMA = {
  type: 'object',
  required: ['fachlichOk', 'sprachlichOk', 'korrekturen'],
  properties: {
    fachlichOk: { type: 'boolean' },
    sprachlichOk: { type: 'boolean' },
    korrekturen: { type: 'array', items: { type: 'string' }, description: 'Durchgeführte Korrekturen' },
  },
}

// ---- Phase 1: Lesen (ein Agent pro PDF, pipeline → keine Barriere) ---------
log(`${pdfs.length} PDF(s) werden gelesen…`)

const extrakte = (await pipeline(
  pdfs,
  (pdf, _item, i) => agent(
    `Lies das PDF "${pdf}" VOLLSTÄNDIG mit dem Read-Tool (PDFs: Parameter "pages", max. 20 Seiten
pro Aufruf — bei längeren PDFs mehrfach aufrufen, bis ALLE Seiten gelesen sind).

Aufgaben:
1. Extrahiere den gesamten Textinhalt.
2. Beschreibe JEDE Abbildung, jedes Schema, jede Tabelle und jedes Foto ausführlich
   (was ist zu sehen, welche Beschriftungen, welche pflegerische/medizinische Bedeutung).
3. Wenn Fotos von Texten enthalten sind (abfotografierte Tafelbilder, Arbeitsblätter,
   handschriftliche Notizen): transkribiere den Text vollständig (OCR).
4. Schreibe ALLES strukturiert in die Datei "Wissen/${String(i + 1).padStart(2, '0')}-<kurzer-slug>.md"
   (slug aus dem PDF-Titel ableiten, klein, mit Bindestrichen). Struktur:
   # <Titel>  /  ## Quelle: ${pdf}  /  ## Inhalt (nach Abschnitten des PDFs)  /
   ## Abbildungen  /  ## Transkribierte Fototexte  /  ## Kernbegriffe (Glossar).
5. Nichts zusammenfassen oder weglassen — das ist die Wissensbasis für spätere Agenten.

Gib als Ergebnis das strukturierte Objekt zurück (wissensdatei = tatsächlich geschriebener Pfad).`,
    { label: `lesen:${pdf.split('/').pop()}`, phase: 'Lesen', schema: EXTRAKT_SCHEMA }
  )
)).filter(Boolean)

if (extrakte.length === 0) throw new Error('Kein PDF konnte gelesen werden.')
log(`${extrakte.length}/${pdfs.length} PDFs gelesen. Kategorisierung startet…`)

// ---- Phase 2: Kategorisieren (Barriere nötig: braucht ALLE Extrakte) -------
phase('Kategorisieren')
const { kategorien } = await agent(
  `Hier sind die Extrakte aller gelesenen Kurs-PDFs einer Pflegeauszubildenden (2. Lehrjahr,
generalistische Ausbildung):

${JSON.stringify(extrakte, null, 2)}

Lies bei Bedarf die Wissen/-Dateien, um die Inhalte genauer zu verstehen.

1. Bilde sinnvolle Themen-Kategorien (z.B. nach Krankheitsbildern, Pflegetechniken,
   Anatomie/Physiologie, Recht/Organisation). Ähnliche PDFs zusammenfassen; ein PDF kann
   zu mehreren Kategorien gehören.
2. Schreibe eine Themenkarte nach "Wissen/00-themenkarte.md": Überblick aller Kategorien,
   Unterthemen, zugehörige Dateien, und wie die Themen zusammenhängen (Mermaid-Diagramm erlaubt).
3. Gib die Kategorienliste strukturiert zurück.`,
  { label: 'themenkarte', schema: KATEGORIEN_SCHEMA }
)
log(`${kategorien.length} Kategorien: ${kategorien.map(k => k.name).join(', ')}`)

// ---- Phase 3: Erstellen (pipeline pro Kategorie) ----------------------------
const MATERIAL_AUFTRAG = (k) => `Du erstellst Lernmaterial für eine Pflegeauszubildende (2. Lehrjahr,
generalistische Pflegeausbildung, Muttersprache Französisch). ${B2_REGEL}

Kategorie: "${k.name}" — Unterthemen: ${(k.unterthemen || []).join(', ')}
Wissensbasis (ZUERST vollständig lesen): ${k.wissensdateien.join(', ')}
Klausur-Konventionen (ZUERST lesen): ${KONVENTIONEN} — halte dich an Operatoren, AFB-Verteilung,
Fallbeispiel-Struktur und Notenschlüssel aus dieser Datei.

Erstelle im Ordner "Lernmaterial/${k.ordner}/" vier Dateien:

1. zusammenfassung.md — Strukturierte Zusammenfassung: Definitionen, Ursachen/Pathophysiologie,
   Symptome, Diagnostik, Therapie, PFLEGE (Beobachtung, Maßnahmen, Prophylaxen, Beratung),
   Merksätze/Eselsbrücken, Glossar der Fachbegriffe (Deutsch mit einfacher Erklärung).

2. uebungen.md — Mindestens 15 Übungen, gestaffelt:
   - AFB I (ca. 40%): Nennen Sie…, Zählen Sie auf…, Beschreiben Sie…
   - AFB II (ca. 40%): Erklären Sie…, Erläutern Sie…, Ordnen Sie zu…, Vergleichen Sie…
   - AFB III (ca. 20%): Begründen Sie…, Beurteilen Sie…, Nehmen Sie Stellung…
   Dazu: 5 Multiple-Choice-Fragen, 1 Zuordnungsaufgabe, 1 Lückentext, 1 Reihenfolge-Aufgabe.
   JEDE Übung mit Musterlösung (direkt darunter, mit "**Lösung:**" markiert) und Punktzahl.

3. fallbeispiel.md — Ein realistisches Fallbeispiel wie in einer echten Klausur:
   Situationsbeschreibung (Patient/in mit Name, Alter, Anamnese, aktuelle Situation auf Station
   oder im Pflegeheim), dann 6-8 Aufgaben mit Operatoren (AFB I-III gemischt), Punkte pro
   Aufgabe, danach vollständiger Erwartungshorizont.

4. klausur.md — Eine Themen-Klausur (45 Min, ca. 50 Punkte): Deckblatt (Thema, Zeit, Punkte,
   Notenschlüssel), 6-10 Aufgaben (Operatoren + 1 kleines Fallbeispiel + 3-4 MC-Fragen),
   danach getrennter Erwartungshorizont mit Punkteverteilung.

Alle Inhalte MÜSSEN aus der Wissensbasis stammen (den PDFs der Schülerin) — kein erfundenes
Off-Topic-Wissen, aber sinnvolle fachliche Vervollständigung ist erlaubt (dann mit "[Ergänzung]"
markieren). Gib die Liste der geschriebenen Dateien zurück.`

const material = (await pipeline(
  kategorien,
  (k) => agent(MATERIAL_AUFTRAG(k), {
    label: `material:${k.ordner}`, phase: 'Erstellen', schema: DATEIEN_SCHEMA,
  }).then(r => ({ kategorie: k, dateien: r.dateien })),
  // Prüfen sofort pro Kategorie (keine Barriere): Fachlichkeit + B2
  (m) => m && agent(
    `Qualitätsprüfung für Pflege-Lernmaterial. Lies diese Dateien: ${m.dateien.join(', ')}
und vergleiche mit der Wissensbasis: ${m.kategorie.wissensdateien.join(', ')}.

Prüfe und KORRIGIERE direkt in den Dateien (Edit-Tool):
1. Fachliche Richtigkeit (Pflegestandards, Expertenstandards, aktuelle Leitlinien; keine
   gefährlichen oder veralteten Aussagen — z.B. bei Medikamenten, Hygiene, Notfallmaßnahmen).
2. Übereinstimmung mit der Wissensbasis (nichts Wichtiges aus den PDFs vergessen?).
3. Sprachniveau B2: zu komplexe Sätze vereinfachen, Fachbegriffe beibehalten aber erklären.
4. Jede Übung hat Musterlösung + Punkte; Klausur hat Erwartungshorizont + Notenschlüssel.

Gib das Prüfergebnis strukturiert zurück.`,
    { label: `pruefen:${m.kategorie.ordner}`, phase: 'Prüfen', schema: PRUEF_SCHEMA }
  ).then(p => ({ ...m, pruefung: p }))
)).filter(Boolean)

// ---- Phase 4: Gesamtklausur (Barriere: braucht alle Kategorien) -------------
phase('Gesamtklausur')
const gesamt = await agent(
  `Erstelle eine themenübergreifende PROBEKLAUSUR (90 Minuten, 100 Punkte) für eine
Pflegeauszubildende im 2. Lehrjahr, über ALLE diese Kategorien:
${material.map(m => `- ${m.kategorie.name} (Wissensbasis: ${m.kategorie.wissensdateien.join(', ')})`).join('\n')}

Lies zuerst ${KONVENTIONEN} und die Wissensdateien. ${B2_REGEL}

Schreibe nach "Lernmaterial/00-probeklausur.md":
- Deckblatt: Fach, Zeit 90 Min, 100 Punkte, Notenschlüssel, Hilfsmittel
- Teil A: 10 Multiple-Choice-Fragen (20 P) über alle Themen
- Teil B: Wissensfragen mit Operatoren, AFB I-II (40 P)
- Teil C: Ein großes Fallbeispiel, das MEHRERE Themen verbindet, mit 6 Aufgaben AFB II-III (40 P)
- Danach: vollständiger Erwartungshorizont mit Punkteverteilung pro Teilantwort.

Zusätzlich "Lernmaterial/00-lernplan.md": ein Lernplan-Vorschlag (welche Themen zuerst,
wie die Übungen/Klausuren zeitlich nutzen, Wiederholungsintervalle).

Gib die geschriebenen Dateien zurück.`,
  { label: 'probeklausur', schema: DATEIEN_SCHEMA }
)

// ---- Ergebnis ---------------------------------------------------------------
return {
  kategorien: material.map(m => ({
    name: m.kategorie.name,
    ordner: m.kategorie.ordner,
    dateien: m.dateien,
    fachlichOk: m.pruefung?.fachlichOk ?? null,
    korrekturen: m.pruefung?.korrekturen ?? [],
  })),
  probeklausur: gesamt.dateien,
  hinweis: 'Nach dem Workflow: interaktiven Artifact aus Lernmaterial/ bauen und veröffentlichen.',
}
