export const meta = {
  name: 'quiz-extract',
  description: 'Extrahiert Multiple-Choice-Fragen aus dem vorhandenen Lernmaterial und schreibt pro Thema eine quiz.json für das interaktive Quiz',
  phases: [{ title: 'Quiz', detail: 'Pro Thema MC-Fragen als JSON extrahieren' }],
}

const THEMEN = [
  '01-beobachtung-wahrnehmung','02-bewusstseins-und-denkstoerungen','03-vitalzeichen',
  '04-haut-und-hauterkrankungen','05-bewegung-sturz-mobilitaet','06-bewegungsapparat-anatomie',
  '07-herz-kreislauf-thrombose','08-harn-kontinenz-katheter','09-stuhl-laxanzien',
  '10-ernaehrung-fluessigkeit','11-injektionen','12-koerper-mund-zahnpflege','13-pflegeprozess-recht',
]

const QUIZ_SCHEMA = {
  type: 'object', required: ['anzahl', 'datei'],
  properties: {
    anzahl: { type: 'number' },
    datei: { type: 'string', description: 'geschriebener Pfad der quiz.json' },
  },
}

const auftrag = (ordner, quizpfad, quellen) => `Erzeuge ein interaktives Multiple-Choice-Quiz.

Lies diese Dateien: ${quellen.join(', ')}.
Sammle daraus ALLE Multiple-Choice-/Auswahl-Fragen (auch die aus dem Klausur-Teil und
Zuordnungs-/Wahr-Falsch-Fragen, die sich in Einfachauswahl umformen lassen). Wenn es weniger als
10 gute MC-Fragen gibt, formuliere zusätzliche sinnvolle MC-Fragen aus den Zusammenfassungs-Inhalten
DIESES Themas, sodass insgesamt 10–14 Fragen entstehen.

Jede Frage: klar, fachlich korrekt (aktuelle Pflegestandards, richtige Normwerte), genau EINE
richtige Antwort, 4 Antwortoptionen (1 richtig, 3 plausible Distraktoren), plus eine kurze
Erklärung (1–2 Sätze, B2). Deutsch, Niveau B2.

Schreibe das Ergebnis als JSON-Array nach "${quizpfad}" (nutze das Write-Tool). Exaktes Format:
[
  { "q": "Fragetext?", "opts": ["Option A","Option B","Option C","Option D"], "correct": 0, "why": "kurze Erklärung" },
  ...
]
"correct" ist der 0-basierte Index der richtigen Option. NUR gültiges JSON in die Datei schreiben
(keine Kommentare, kein Markdown-Codeblock). Gib danach anzahl (Anzahl Fragen) und datei zurück.`

log(`Quiz-Extraktion für ${THEMEN.length} Themen + Probeklausur…`)

const themenQuiz = THEMEN.map(ordner => ({
  ordner,
  quellen: [`Lernmaterial/${ordner}/uebungen.md`, `Lernmaterial/${ordner}/klausur.md`, `Lernmaterial/${ordner}/zusammenfassung.md`],
  quizpfad: `Lernmaterial/${ordner}/quiz.json`,
}))

const results = (await pipeline(
  themenQuiz.concat([{ ordner: '00-probeklausur', quellen: ['Lernmaterial/00-probeklausur.md'], quizpfad: 'Lernmaterial/00-probeklausur-quiz.json' }]),
  (t) => agent(auftrag(t.ordner, t.quizpfad, t.quellen), { label: `quiz:${t.ordner}`, phase: 'Quiz', schema: QUIZ_SCHEMA })
    .then(r => ({ ordner: t.ordner, anzahl: r ? r.anzahl : 0, datei: r ? r.datei : null }))
)).filter(Boolean)

return { quizze: results, gesamt: results.reduce((s, r) => s + (r.anzahl || 0), 0) }
