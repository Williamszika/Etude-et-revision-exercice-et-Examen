export const meta = {
  name: 'medizin-check',
  description: 'Fachliche/medizinische Endkontrolle des gesamten Lernmaterials (13 Themen): korrigiert Fehler bei Normwerten, Expertenstandards, Injektionen, Hygiene, Medikamenten direkt in den Dateien + prüft die Quiz-Antworten',
  phases: [{ title: 'Prüfen', detail: 'Ein Prüf-Agent pro Thema (fachlich + Quiz)' }],
}

const THEMEN = [
  { ordner: '01-beobachtung-wahrnehmung', wissen: ['001-wahrnehmung-und-beobachtung.md','088-arten-von-beobachtung.md'] },
  { ordner: '02-bewusstseins-und-denkstoerungen', wissen: ['005-wahrnehmungsstoerung-tafelbild.md','026-orientierungsstoerung-tafelbild.md','074-denkstoerungen-tafelbild.md','020-srw-syndrom-der-reaktionslosen-wachheit-tafelbild.md','059-geistige-behinderung-tafelbild.md'] },
  { ordner: '03-vitalzeichen', wissen: ['024-blutdruck-und-puls.md','036-koerpertemperatur.md','028-pflege-bei-fieber.md','083-atembeobachtung-teil-1.md','084-atembeobachtung-teil-2.md'] },
  { ordner: '04-haut-und-hauterkrankungen', wissen: ['045-hautbeobachtung.md','094-anatomie-physiologie-haut.md','007-dermatomykose.md','008-inkontinenz-assoziierte-dermatitis-iad.md','009-intertrigo.md','010-juckreiz.md'] },
  { ordner: '05-bewegung-sturz-mobilitaet', wissen: ['015-sturzprophylaxe.md','004-tinetti-test.md','019-sppb-short-physical-performance-battery.md','056-festgenagelt-bettlaegerigkeit-zegelin.md','055-expertenstandard-erhaltung-und-foerderung-der-mobilitaet.md'] },
  { ordner: '06-bewegungsapparat-anatomie', wissen: ['021-anatomie-skelettmuskulatur.md','022-anatomie-muskelgewebe.md','076-beckenquerschnitte-arbeitsblatt.md'] },
  { ordner: '07-herz-kreislauf-thrombose', wissen: ['049-koerperkreislauf.md','047-arterien-und-arteriolen.md','048-kapillaren.md','040-venolen-und-venen.md','110-thrombose.md'] },
  { ordner: '08-harn-kontinenz-katheter', wissen: ['003-suprapubische-blasendrainage.md','053-handlungsschritte-katheterisierung.md','054-harnblasenkatheter-arbeitsauftraege.md','100-harninkontinenzformen.md','109-kontinenzanamnese-skript.md'] },
  { ordner: '09-stuhl-laxanzien', wissen: ['011-stuhlbeobachtung.md','034-obstipation.md','065-diarrhoen.md','027-osmotische-mittel.md','018-schleimhautreizende-mittel.md'] },
  { ordner: '10-ernaehrung-fluessigkeit', wissen: ['039-mangelernaehrung.md','031-mini-nutritional-assessment-mna.md','051-wasser-und-elektrolythaushalt.md','080-aspirationsprophylaxe.md'] },
  { ordner: '11-injektionen', wissen: ['107-subkutane-injektion.md','044-intramuskulaere-injektion.md','030-methoden-injektionsstellen-im-injektion.md','094-nadelstichverletzungen-nsv.md'] },
  { ordner: '12-koerper-mund-zahnpflege', wissen: ['023-prinzipien-der-koerperpflege.md','043-intimpflege.md','068-die-rasur.md','107-mund-und-zahnpflege.md','100-munderkrankungen.md'] },
  { ordner: '13-pflegeprozess-recht', wissen: ['101-pflegeplanung.md','061-erhebung-nach-den-aedl.md','084-barthel-index.md','103-recht.md'] },
]

const CHECK_SCHEMA = {
  type: 'object', required: ['fachlichOk', 'korrekturen'],
  properties: {
    fachlichOk: { type: 'boolean', description: 'true, wenn keine fachlichen Fehler (mehr) vorhanden sind' },
    schweregrad: { type: 'string', description: 'keine | gering | mittel | schwer — höchste gefundene Fehlerklasse' },
    korrekturen: { type: 'array', items: { type: 'string' }, description: 'kurze Liste der durchgeführten Korrekturen' },
    quizKorrekturen: { type: 'number', description: 'Anzahl korrigierter Quiz-Antworten' },
  },
}

const auftrag = (t) => `Du bist erfahrene Pflegepädagogin und machst die fachliche ENDKONTROLLE des
Lernmaterials zum Thema-Ordner "Lernmaterial/${t.ordner}/".

Lies alle Dateien dieses Ordners: zusammenfassung.md, uebungen.md, fallbeispiel.md, klausur.md und
quiz.json. Vergleiche mit der Wissensbasis der Schülerin: ${t.wissen.map(w => 'Wissen/' + w).join(', ')}
(diese Extrakte stammen aus ihren echten Unterlagen).

Prüfe besonders streng auf medizinisch/pflegerisch FALSCHE oder GEFÄHRLICHE Aussagen und KORRIGIERE
sie direkt in den Dateien (Edit-Tool):
- Normwerte (z. B. Puls 60–100/min, RR ~120/80 mmHg, Temperatur-/Fiebergrenzen, Atemfrequenz 12–18/min, BMI-Grenzen)
- Expertenstandards & aktuelle Leitlinien (Sturz, Dekubitus, Ernährung, Kontinenz, Mobilität, Schmerz)
- Injektionen: richtige Stellen (v. a. ventrogluteal n. Hochstetter), Winkel, Kanülen, Aspiration, STIKO,
  Nadelstichverletzung/PEP — hier dürfen KEINE falschen oder gefährlichen Angaben stehen
- Hygiene/Asepsis (Händedesinfektion, steriles Arbeiten am Katheter)
- Medikamente/Laxanzien (Wirkprinzip, Kontraindikationen)
- Rechtliche Aussagen (Einwilligung, Delegation) grob korrekt

Prüfe die quiz.json GENAU: Ist bei jeder Frage der Index "correct" wirklich die richtige Antwort?
Ist die Erklärung ("why") korrekt? Falls nicht, korrigiere die Datei (weiterhin gültiges JSON,
Format [{q,opts,correct,why}]).

Achte auch auf Sprachniveau B2 (verständlich, Fachbegriffe erklärt). Ändere Inhalte nur, wenn sie
fachlich falsch, unklar oder gefährlich sind — korrekte Inhalte NICHT umschreiben.

Gib das Prüfergebnis strukturiert zurück (fachlichOk, schweregrad, korrekturen[], quizKorrekturen).`

log(`Fachliche Endkontrolle für ${THEMEN.length} Themen…`)
const berichte = (await pipeline(
  THEMEN,
  (t) => agent(auftrag(t), { label: `check:${t.ordner}`, phase: 'Prüfen', schema: CHECK_SCHEMA })
    .then(r => ({ ordner: t.ordner, ...(r || { fachlichOk: null, korrekturen: [] }) }))
)).filter(Boolean)

return {
  geprueft: berichte.length,
  mitKorrekturen: berichte.filter(b => (b.korrekturen || []).length > 0 || (b.quizKorrekturen || 0) > 0)
    .map(b => ({ ordner: b.ordner, schweregrad: b.schweregrad, anzahl: (b.korrekturen || []).length, quiz: b.quizKorrekturen || 0, korrekturen: b.korrekturen })),
  allesFachlichOk: berichte.every(b => b.fachlichOk !== false),
}
