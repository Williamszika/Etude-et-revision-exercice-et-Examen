export const meta = {
  name: 'klausur-finish',
  description: 'Erzeugt NUR das noch fehlende Lernmaterial (Themen 09-13 + Probeklausur + Lernplan) aus den bereits vorhandenen Wissen/-Dateien — ohne erneutes PDF-Lesen',
  phases: [
    { title: 'Erstellen', detail: 'Themen 09-13: fehlende Dateien generieren' },
    { title: 'Gesamt', detail: 'Probeklausur (90 Min) + Lernplan' },
  ],
}

const KONVENTIONEN = 'ressources/klausur-konventionen.md'
const B2_REGEL = `Sprache: Deutsch, Niveau B2. Fachbegriffe (medizinische/pflegerische Termini) IMMER
verwenden, aber beim ersten Auftreten kurz in Klammern einfach erklären. Klare, nicht zu verschachtelte
Sätze. Muttersprache der Schülerin ist Französisch — bei besonders schwierigen Schlüsselbegriffen darf
einmalig die französische Entsprechung in [fr: …] ergänzt werden.`
const NOTENSCHLUESSEL = `Notenschlüssel NRW: 1 = 100–90 %, 2 = 89–75 %, 3 = 74–60 %, 4 = 59–50 %,
5 = 49–35 %, 6 = 34–0 %. Bestehensgrenze 50 %.`

const DATEIEN_SCHEMA = { type: 'object', required: ['dateien'], properties: { dateien: { type: 'array', items: { type: 'string' } } } }

// Nur die noch fehlenden Kategorien; wissensdateien aus Wissen/00-themenkarte.md
const KATEGORIEN = [
  { ordner: '09-stuhl-laxanzien', name: 'Ausscheidung: Stuhl & Laxanzien',
    fehlt: ['uebungen', 'fallbeispiel', 'klausur'],
    wissen: ['011-stuhlbeobachtung.md','072-der-defaekationsvorgang.md','012-stuhlinkontinenz.md','034-obstipation.md','065-diarrhoen.md','016-quellstoff-wonder.md','027-osmotische-mittel.md','018-schleimhautreizende-mittel.md','050-gleitmittel.md','078-laxanzien-bilder.md'] },
  { ordner: '10-ernaehrung-fluessigkeit', name: 'Ernährung & Flüssigkeit (Screenings & Aspiration)',
    fehlt: ['uebungen', 'fallbeispiel', 'klausur'],
    wissen: ['002-unterstuetzung-beim-essen-und-trinken.md','039-mangelernaehrung.md','031-mini-nutritional-assessment-mna.md','033-nutritional-risk-screening-nrs-2002.md','038-malnutrition-universal-screening-tool-must.md','063-pflegerische-erfassung-mangelernaehrung-pemu.md','051-wasser-und-elektrolythaushalt.md','091-fallbeispiel-dehydratation-frau-sommer.md','080-aspirationsprophylaxe.md','095-aspirationsprophylaxe.md'] },
  { ordner: '11-injektionen', name: 'Injektionen & Arzneimittelapplikation',
    fehlt: ['zusammenfassung', 'uebungen', 'fallbeispiel', 'klausur'],
    wissen: ['107-subkutane-injektion.md','044-intramuskulaere-injektion.md','103-intramuskulaere-injektion.md','030-methoden-injektionsstellen-im-injektion.md','094-nadelstichverletzungen-nsv.md','108-subkutane-injektion.md','045-intramuskulaere-injektion.md'] },
  { ordner: '12-koerper-mund-zahnpflege', name: 'Körper-, Mund- & Zahnpflege',
    fehlt: ['zusammenfassung', 'uebungen', 'fallbeispiel', 'klausur'],
    wissen: ['023-prinzipien-der-koerperpflege.md','071-checkliste-koerperpflege.md','043-intimpflege.md','068-die-rasur.md','086-arbeitsauftrag-bart-und-rasurpflege.md','107-mund-und-zahnpflege.md','092-anatomie-mund-und-zaehne.md','100-munderkrankungen.md','032-so-wirken-medikamente-auf-die-mundhoehle.md'] },
  { ordner: '13-pflegeprozess-recht', name: 'Pflegeprozess, Assessments & Recht',
    fehlt: ['zusammenfassung', 'uebungen', 'fallbeispiel', 'klausur'],
    wissen: ['101-pflegeplanung.md','029-pflegeplanung-vorlage-pesr.md','061-erhebung-nach-den-aedl.md','062-erhebung-lebensaktivitaeten-epa-ac.md','084-barthel-index.md','103-recht.md','013-stundennachweis-pflichteinsaetze.md'] },
]

const ALLE_THEMEN = [
  'Beobachtung & Wahrnehmung','Bewusstseins- & Denkstörungen','Vitalzeichen (Puls, RR, Temperatur, Atmung)',
  'Haut & Hauterkrankungen','Bewegung, Sturz & Mobilität','Bewegungsapparat & Anatomie',
  'Herz-Kreislauf & Thrombose','Harn, Kontinenz & Katheter','Stuhl & Laxanzien','Ernährung & Flüssigkeit',
  'Injektionen (s.c./i.m.)','Körper-, Mund- & Zahnpflege','Pflegeprozess & Recht',
]

const auftrag = (k) => `Du erstellst hochwertiges Lernmaterial für eine Pflegeauszubildende (2. Lehrjahr,
generalistische Ausbildung, NRW, Muttersprache Französisch). Arbeite gründlich. ${B2_REGEL}

Kategorie: "${k.name}"
Wissensbasis: Lies ZUERST diese Dateien im Ordner Wissen/ vollständig: ${k.wissen.map(w => 'Wissen/' + w).join(', ')}.
Falls ein Dateiname nicht existiert, führe \`ls Wissen/\` aus und nimm die inhaltlich passende Datei.
Klausur-Konventionen (ZUERST lesen): ${KONVENTIONEN} — Operatoren, AFB-Verteilung ca. 30/40/30,
Fallbeispiel-Struktur. ${NOTENSCHLUESSEL}

Erstelle im Ordner "Lernmaterial/${k.ordner}/" NUR diese Dateien: ${k.fehlt.join(', ')}.
(Andere, evtl. schon vorhandene Dateien NICHT überschreiben.)

Vorgaben je Datei:
${k.fehlt.includes('zusammenfassung') ? `- zusammenfassung.md — gründliche, gut lernbare Zusammenfassung: Überblick, Definitionen,
  Anatomie/Physiologie soweit relevant, Ursachen/Entstehung, Symptome/Risikofaktoren, Beobachtung &
  Assessment (Instrumente, Kriterien, Normwerte), PFLEGE (Maßnahmen, Prophylaxen, Durchführung Schritt
  für Schritt, Beratung, Dokumentation), Merksätze, Glossar. Tabellen & Aufzählungen nutzen.\n` : ''}- uebungen.md — mind. 15 Übungen, gestaffelt nach AFB (I ~40 %, II ~40 %, III ~20 %) mit den Operatoren
  (Nennen/Beschreiben; Erklären/Erläutern/Vergleichen/Zuordnen; Begründen/Beurteilen). Dazu 5 Multiple-
  Choice, 1 Zuordnung, 1 Lückentext, 1 Reihenfolge-Aufgabe. Jede Übung mit "**Lösung:**" direkt darunter
  und Punktzahl.
- fallbeispiel.md — realistisches Klausur-Fallbeispiel: Situationsbeschreibung (Name, Alter, Anamnese,
  aktuelle Situation, Zitat), 6–8 Aufgaben mit Operatoren (AFB I→III), Punkte je Aufgabe, danach
  vollständiger Erwartungshorizont.
- klausur.md — Themen-Klausur (45 Min, ~50 P): Deckblatt (Thema, Zeit, Punkte, Notenschlüssel NRW),
  6–10 Aufgaben (Operatoren + kleines Fallbeispiel + 3–4 MC), danach getrennter Erwartungshorizont mit
  Punkteverteilung.

Alle Inhalte fachlich korrekt (aktuelle Expertenstandards, Normwerte, sichere Injektions-/Hygiene-Angaben)
und aus der Wissensbasis. Sinnvolle Ergänzungen mit "[Ergänzung]" markieren. Gib die geschriebenen Dateien zurück.`

log(`Erzeuge fehlendes Material für ${KATEGORIEN.length} Themen…`)
const ergebnisse = (await pipeline(
  KATEGORIEN,
  (k) => agent(auftrag(k), { label: `material:${k.ordner}`, phase: 'Erstellen', schema: DATEIEN_SCHEMA })
    .then(r => ({ ordner: k.ordner, dateien: r ? r.dateien : [] }))
)).filter(Boolean)

phase('Gesamt')
const gesamt = await agent(
  `Erstelle eine themenübergreifende PROBEKLAUSUR (90 Minuten, 100 Punkte) für eine Pflegeauszubildende
im 2. Lehrjahr (NRW) über alle 13 Themen: ${ALLE_THEMEN.join('; ')}.
Nutze als inhaltliche Grundlage die vorhandenen Zusammenfassungen in Lernmaterial/*/zusammenfassung.md
(lies ein paar davon quer). Lies zuerst ${KONVENTIONEN}. ${B2_REGEL} ${NOTENSCHLUESSEL}

Schreibe "Lernmaterial/00-probeklausur.md":
- Deckblatt (Fach, 90 Min, 100 P, Notenschlüssel NRW, Hilfsmittel)
- Teil A: 10 Multiple-Choice (20 P) quer über die Themen
- Teil B: Wissensfragen mit Operatoren AFB I–II (40 P)
- Teil C: ein großes Fallbeispiel, das mehrere Themen verbindet (z. B. eine ältere, bettlägerige,
  mangelernährte Person mit Sturz-, Haut-, Kontinenz- und Stuhlproblemen), 6 Aufgaben AFB II–III (40 P)
- danach vollständiger Erwartungshorizont mit Punkteverteilung.

Schreibe außerdem "Lernmaterial/00-lernplan.md": konkreter Lernplan (Reihenfolge der 13 Themen,
Nutzung von Zusammenfassung→Übungen→Fallbeispiel→Klausur, Wiederholungsintervalle/Spaced Repetition,
Umgang mit Operatoren, Tipps für die Zwischenprüfung). Gib die geschriebenen Dateien zurück.`,
  { label: 'probeklausur+lernplan', schema: DATEIEN_SCHEMA }
)

return { themen: ergebnisse, gesamt: gesamt ? gesamt.dateien : [] }
