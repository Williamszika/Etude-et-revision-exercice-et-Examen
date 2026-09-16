import 'package:flutter/material.dart';

import '../daten/modelle.dart';
import '../daten/speicher.dart';
import 'sprecher.dart';
import 'stil.dart';
import 'teile.dart';

/// Der Lesetext mit allem, was daran hängt.
///
/// `nurUebungen` ist der Übungstag-Schalter: Dann bleibt der Text **zugeklappt**
/// und die Erklärungen fallen weg — es stehen nur noch die Aufgaben da. Genau
/// das hatte sie verlangt: *„les exercices doivent être que les exercices."*
class LesenBlock extends StatelessWidget {
  const LesenBlock({
    super.key,
    required this.d,
    required this.datum,
    this.nurUebungen = false,
  });

  final Map<String, dynamic> d;
  final String datum;
  final bool nurUebungen;

  @override
  Widget build(BuildContext context) {
    final f = Stil.blockFarbe(context, 'lesen');
    final text = textVon(d['text']);
    final woerter = text.trim().isEmpty
        ? 0
        : text.trim().split(RegExp(r'\s+')).length;

    return BlockKarte(
      block: 'lesen',
      etikett: 'Lesen und verstehen · $woerter Wörter',
      titel: textVon(d['titel']),
      untertitel: textVon(d['quelle']),
      kinder: [
        if (!nurUebungen) FrZeile(textVon(d['fr'])),
        const SizedBox(height: 12),
        if (nurUebungen)
          _Klapp(
            titel: 'Text aufklappen — erst, wenn du nicht weiterkommst',
            farbe: f,
            kind: _Text(text: text, farbe: f),
          )
        else
          _Text(text: text, farbe: f),
        if (!nurUebungen) Chips(listeVon(d['hilfe'])),
        if (!nurUebungen && listeVon(d['redemittel']).isNotEmpty)
          Kasten(
            farbe: f,
            titel: 'Damit kannst du anfangen',
            kind: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final r in listeVon(d['redemittel']))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: MarkText(
                      '✎  $r',
                      stil: const TextStyle(fontSize: 15, height: 1.45),
                    ),
                  ),
              ],
            ),
          ),
        _Schritt(
          nr: 1,
          d: mapVon(d['nacherzaehlen']),
          farbe: f,
          datum: datum,
          feld: 'lesen-nach',
        ),
        _Schritt(
          nr: 2,
          d: mapVon(d['hauptaussage']),
          farbe: f,
          datum: datum,
          feld: 'lesen-haupt',
        ),
        if (zeilenVon(d['fragen']).isNotEmpty) ...[
          const SizedBox(height: 16),
          _Titel('Fragen zum Text', f),
          if (!nurUebungen) const _Operatoren(),
          for (var i = 0; i < zeilenVon(d['fragen']).length; i++)
            _Frage(
              q: zeilenVon(d['fragen'])[i],
              farbe: f,
              datum: datum,
              feld: 'lesen-frage-$i',
            ),
        ],
        _Wortschatz(d: mapVon(d['wortschatz']), farbe: f, datum: datum,
            nurUebungen: nurUebungen),
        _Grammatik(d: mapVon(d['grammatik']), farbe: f, datum: datum,
            nurUebungen: nurUebungen),
        _Konnektoren(d: mapVon(d['konnektoren']), farbe: f, datum: datum,
            nurUebungen: nurUebungen),
        if (mapVon(d['erklaeren']).isNotEmpty)
          _Schritt(
            nr: 3,
            d: mapVon(d['erklaeren']),
            farbe: f,
            datum: datum,
            feld: 'lesen-erklaeren',
          ),
        if (!nurUebungen && textVon(d['tipp']).isNotEmpty)
          Kasten(
            farbe: Stil.goldFarbe(context),
            titel: 'Tipp',
            kind: MarkText(textVon(d['tipp'])),
          ),
      ],
    );
  }
}

class _Text extends StatelessWidget {
  const _Text({required this.text, required this.farbe});
  final String text;
  final Color farbe;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: Stil.kartenGrund(context),
          border: Border(
            left: BorderSide(color: farbe, width: 4),
            top: BorderSide(color: Stil.linienFarbe(context)),
            right: BorderSide(color: Stil.linienFarbe(context)),
            bottom: BorderSide(color: Stil.linienFarbe(context)),
          ),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final p in text.split(RegExp(r'\n\s*\n')))
              if (p.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: MarkText(
                    p.trim(),
                    stil: const TextStyle(fontSize: 17, height: 1.75),
                  ),
                ),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: () => Sprecher.ich.sprich(text, tempo: .45),
                  icon: const Icon(Icons.play_arrow_rounded, size: 19),
                  label: const Text('Vorlesen'),
                  style: FilledButton.styleFrom(
                    backgroundColor: farbe,
                    foregroundColor: Stil.kartenGrund(context),
                    minimumSize: const Size(0, 38),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => Sprecher.ich.sprich(text, tempo: .28),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: farbe,
                    side: BorderSide(color: farbe),
                    minimumSize: const Size(0, 38),
                  ),
                  child: const Text('Langsam'),
                ),
              ],
            ),
          ],
        ),
      );
}

class _Schritt extends StatelessWidget {
  const _Schritt({
    required this.nr,
    required this.d,
    required this.farbe,
    required this.datum,
    required this.feld,
  });

  final int nr;
  final Map<String, dynamic> d;
  final Color farbe;
  final String datum;
  final String feld;

  @override
  Widget build(BuildContext context) {
    if (d.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      decoration: BoxDecoration(
        color: Stil.papierZwei(context),
        border: Border.all(color: Stil.linienFarbe(context)),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Etikett('Schritt $nr', farbe: farbe),
          const SizedBox(height: 7),
          MarkText(
            textVon(d['frage']),
            stil: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          if (textVon(d['hinweis']).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: MarkText(
                textVon(d['hinweis']),
                stil: TextStyle(fontSize: 14, color: Stil.weich(context)),
              ),
            ),
          AntwortFeld(
            datum: datum,
            feld: feld,
            zeilen: 4,
            platzhalter: textVon(d['platzhalter']),
          ),
          Loesung(
            text: textVon(d['muster']),
            beschriftung: 'Musterantwort zeigen',
            farbe: farbe,
          ),
        ],
      ),
    );
  }
}

class _Frage extends StatelessWidget {
  const _Frage({
    required this.q,
    required this.farbe,
    required this.datum,
    required this.feld,
  });

  final Map<String, dynamic> q;
  final Color farbe;
  final String datum;
  final String feld;

  static const _farben = {
    'Nennen': Color(0xFF6B7280),
    'Beschreiben': Color(0xFF0F6F6B),
    'Erklären': Color(0xFF1F5F8B),
    'Erläutern': Color(0xFF0F6F6B),
    'Begründen': Color(0xFFBB4D3F),
  };

  @override
  Widget build(BuildContext context) {
    final op = textVon(q['operator']);
    final opf = _farben[op] ?? farbe;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.fromLTRB(13, 11, 13, 12),
      decoration: BoxDecoration(
        color: Stil.papierZwei(context),
        border: Border.all(color: Stil.linienFarbe(context)),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (op.isNotEmpty) Etikett(op, farbe: opf),
          const SizedBox(height: 7),
          MarkText(
            textVon(q['frage']),
            stil: const TextStyle(fontSize: 16, height: 1.5),
          ),
          AntwortFeld(datum: datum, feld: feld, zeilen: 3),
          Loesung(
            text: textVon(q['loesung']),
            hinweis: textVon(q['hinweis']),
            beschriftung: 'Musterantwort zeigen',
            farbe: farbe,
          ),
        ],
      ),
    );
  }
}

/// Der Kasten, der erklärt, was jeder Operator verlangt. Dieselben Wörter
/// stehen in ihren Pflege-Klausuren — deshalb steht er hier und nicht nur
/// irgendwo im Lernmaterial.
class _Operatoren extends StatelessWidget {
  const _Operatoren();

  static const _was = [
    ['Nennen', 'Nur aufzählen. Keine Begründung.'],
    ['Beschreiben', 'Sagen, wie etwas aussieht oder abläuft.'],
    ['Begründen', 'Ein Grund muss hin: weil, da, denn, deshalb.'],
    ['Erklären', 'Verständlich machen — plus ein eigenes Beispiel.'],
    ['Erläutern', 'Erklären und am Text belegen: „Das sieht man daran, dass …“'],
  ];

  @override
  Widget build(BuildContext context) => _Klapp(
        titel: 'Was verlangt welcher Operator?',
        farbe: Stil.blockFarbe(context, 'lesen'),
        kind: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final w in _was)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 104,
                      child: Text(
                        w[0],
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        w[1],
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
}

class _Wortschatz extends StatelessWidget {
  const _Wortschatz({
    required this.d,
    required this.farbe,
    required this.datum,
    required this.nurUebungen,
  });

  final Map<String, dynamic> d;
  final Color farbe;
  final String datum;
  final bool nurUebungen;

  @override
  Widget build(BuildContext context) {
    if (d.isEmpty) return const SizedBox.shrink();
    final aufgabe = mapVon(d['aufgabe']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _Titel('Wortschatz aus dem Text', farbe),
        if (!nurUebungen) ...[
          Absatz(textVon(d['einleitung']), oben: 6),
          for (final w in zeilenVon(d['woerter']))
            Container(
              margin: const EdgeInsets.only(top: 7),
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              decoration: BoxDecoration(
                color: Stil.papierZwei(context),
                border: Border.all(color: Stil.linienFarbe(context)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: MarkText(
                                textVon(w['wort']),
                                stil: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (textVon(w['niveau']).isNotEmpty) ...[
                              const SizedBox(width: 7),
                              Etikett(textVon(w['niveau']), farbe: farbe),
                            ],
                          ],
                        ),
                        Text(
                          textVon(w['fr']),
                          style: TextStyle(
                            fontSize: 14.5,
                            fontStyle: FontStyle.italic,
                            color: Stil.weich(context),
                          ),
                        ),
                        if (textVon(w['imText']).isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: MarkText(
                              textVon(w['imText']),
                              stil: const TextStyle(
                                fontSize: 14,
                                height: 1.45,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  HoerKnopf(textVon(w['wort']), farbe: farbe),
                ],
              ),
            ),
        ],
        if (aufgabe.isNotEmpty)
          Kasten(
            farbe: farbe,
            titel: 'Deine Aufgabe',
            kind: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkText(
                  textVon(aufgabe['frage']),
                  stil: const TextStyle(fontSize: 15.5, height: 1.5),
                ),
                if (textVon(aufgabe['hinweis']).isNotEmpty)
                  MarkText(
                    textVon(aufgabe['hinweis']),
                    stil: TextStyle(fontSize: 14, color: Stil.weich(context)),
                  ),
                AntwortFeld(
                  datum: datum,
                  feld: 'lesen-ws-aufgabe',
                  zeilen: 5,
                ),
                Loesung(text: textVon(aufgabe['muster']), farbe: farbe),
              ],
            ),
          ),
      ],
    );
  }
}

class _Grammatik extends StatelessWidget {
  const _Grammatik({
    required this.d,
    required this.farbe,
    required this.datum,
    required this.nurUebungen,
  });

  final Map<String, dynamic> d;
  final Color farbe;
  final String datum;
  final bool nurUebungen;

  @override
  Widget build(BuildContext context) {
    final punkte = zeilenVon(d['punkte']);
    if (punkte.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _Titel('Grammatik, die wirklich im Text steht', farbe),
        if (!nurUebungen) Absatz(textVon(d['einleitung']), oben: 6),
        for (var i = 0; i < punkte.length; i++)
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.fromLTRB(13, 11, 13, 12),
            decoration: BoxDecoration(
              color: Stil.papierZwei(context),
              border: Border.all(color: Stil.linienFarbe(context)),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkText(
                  textVon(punkte[i]['name']),
                  stil: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: farbe,
                  ),
                ),
                if (!nurUebungen) ...[
                  Absatz(textVon(punkte[i]['regel']), oben: 5, groesse: 15),
                  if (textVon(punkte[i]['imText']).isNotEmpty)
                    Kasten(
                      farbe: farbe,
                      titel: 'Im Text',
                      kind: MarkText(
                        textVon(punkte[i]['imText']),
                        stil: const TextStyle(fontSize: 15, height: 1.5),
                      ),
                    ),
                ],
                Absatz(textVon(punkte[i]['aufgabe']), oben: 9, groesse: 15.5),
                AntwortFeld(datum: datum, feld: 'lesen-gram-$i', zeilen: 2),
                Loesung(
                  text: textVon(punkte[i]['loesung']),
                  hinweis: textVon(punkte[i]['hinweis']),
                  farbe: farbe,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Konnektoren extends StatelessWidget {
  const _Konnektoren({
    required this.d,
    required this.farbe,
    required this.datum,
    required this.nurUebungen,
  });

  final Map<String, dynamic> d;
  final Color farbe;
  final String datum;
  final bool nurUebungen;

  @override
  Widget build(BuildContext context) {
    final aufgaben = zeilenVon(d['aufgaben']);
    if (aufgaben.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _Titel('Konnektoren umbauen', farbe),
        if (!nurUebungen) Absatz(textVon(d['einleitung']), oben: 6),
        for (var i = 0; i < aufgaben.length; i++)
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.fromLTRB(13, 11, 13, 12),
            decoration: BoxDecoration(
              color: Stil.papierZwei(context),
              border: Border.all(color: Stil.linienFarbe(context)),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (textVon(aufgaben[i]['typ']).isNotEmpty)
                  Etikett(textVon(aufgaben[i]['typ']), farbe: farbe),
                if (textVon(aufgaben[i]['satz']).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(11, 8, 11, 9),
                      decoration: BoxDecoration(
                        color: Stil.kartenGrund(context),
                        border: Border(
                          left: BorderSide(color: farbe, width: 3),
                        ),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: MarkText(
                        textVon(aufgaben[i]['satz']),
                        stil: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                  ),
                Absatz(textVon(aufgaben[i]['frage']), oben: 8, groesse: 15.5),
                AntwortFeld(datum: datum, feld: 'lesen-kon-$i', zeilen: 2),
                Loesung(
                  text: textVon(aufgaben[i]['loesung']),
                  hinweis: textVon(aufgaben[i]['hinweis']),
                  farbe: farbe,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Titel extends StatelessWidget {
  const _Titel(this.text, this.farbe);
  final String text;
  final Color farbe;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: farbe,
          ),
        ),
      );
}

class _Klapp extends StatefulWidget {
  const _Klapp({
    required this.titel,
    required this.kind,
    required this.farbe,
  });

  final String titel;
  final Widget kind;
  final Color farbe;

  @override
  State<_Klapp> createState() => _KlappState();
}

class _KlappState extends State<_Klapp> {
  bool _offen = false;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _offen = !_offen),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              decoration: BoxDecoration(
                color: Stil.kartenGrund(context),
                border: Border.all(color: Stil.linienFarbe(context)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(_offen ? Icons.remove : Icons.add,
                      size: 18, color: widget.farbe),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.titel,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: widget.farbe,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_offen)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: widget.kind,
            ),
        ],
      );
}

/// Diktat — Satz für Satz, zweimal, Tempo wählbar. Danach Wort für Wort
/// vergleichen: Was fehlt, was ist zu viel.
class DiktatBlock extends StatefulWidget {
  const DiktatBlock({super.key, required this.d, required this.datum});
  final Map<String, dynamic> d;
  final String datum;

  @override
  State<DiktatBlock> createState() => _DiktatBlockState();
}

class _DiktatBlockState extends State<DiktatBlock> {
  late final TextEditingController _c;
  bool _abbrechen = false;
  bool _laeuft = false;
  String _stand = '';
  List<_Wortpaar>? _vergleich;
  double _tempo = .45;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(
      text: Speicher.ich.antwort(widget.datum, 'diktat'),
    );
    _tempo = Speicher.ich.tempo;
  }

  @override
  void dispose() {
    _abbrechen = true;
    Speicher.ich.antwortSetzen(widget.datum, 'diktat', _c.text);
    _c.dispose();
    super.dispose();
  }

  List<String> get _saetze {
    final t = textVon(widget.d['text']);
    return t
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<void> _start() async {
    setState(() {
      _abbrechen = false;
      _laeuft = true;
      _vergleich = null;
    });
    final klage = await Sprecher.ich.diktieren(
      _saetze,
      tempo: _tempo,
      abgebrochen: () => _abbrechen,
      beiSatz: (i, d) {
        if (mounted) {
          setState(() => _stand =
              'Durchgang $d von 2 · Satz ${i + 1} von ${_saetze.length}');
        }
      },
    );
    // Ein stummes Diktat sieht aus wie ein kaputtes Diktat. Sagen, woran es lag.
    if (klage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(klage), duration: const Duration(seconds: 6)),
      );
    }
    if (mounted) {
      setState(() {
        _laeuft = false;
        _stand = _abbrechen ? '' : 'Fertig — jetzt vergleichen.';
      });
    }
  }

  Future<void> _stopp() async {
    _abbrechen = true;
    await Sprecher.ich.stopp();
    if (mounted) {
      setState(() {
        _laeuft = false;
        _stand = '';
      });
    }
  }

  void _pruefen() {
    setState(() => _vergleich =
        _vergleichen(textVon(widget.d['text']), _c.text));
  }

  @override
  Widget build(BuildContext context) {
    final f = Stil.blockFarbe(context, 'diktat');
    final treffer = _vergleich?.where((p) => p.art == _Art.gleich).length ?? 0;
    final soll = _vergleich?.where((p) => p.art != _Art.zuviel).length ?? 0;
    final prozent = soll == 0 ? 0 : (treffer * 100 / soll).round();

    return BlockKarte(
      block: 'diktat',
      etikett: 'Diktat',
      titel: textVon(widget.d['titel']),
      kinder: [
        FrZeile(textVon(widget.d['fr'])),
        Chips(listeVon(widget.d['hilfe'])),
        const SizedBox(height: 14),
        Row(
          children: [
            Text('Tempo',
                style: TextStyle(fontSize: 13.5, color: Stil.weich(context))),
            Expanded(
              child: Slider(
                value: _tempo,
                min: .2,
                max: .7,
                divisions: 5,
                activeColor: f,
                label: _tempo <= .28
                    ? 'sehr langsam'
                    : _tempo <= .4
                        ? 'langsam'
                        : _tempo <= .5
                            ? 'normal'
                            : 'zügig',
                onChanged: _laeuft
                    ? null
                    : (v) {
                        setState(() => _tempo = v);
                        Speicher.ich.tempoSetzen(v);
                      },
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: _laeuft ? null : _start,
              icon: const Icon(Icons.headphones_rounded, size: 19),
              label: const Text('Diktat starten'),
              style: FilledButton.styleFrom(
                backgroundColor: f,
                foregroundColor: Stil.kartenGrund(context),
                minimumSize: const Size(0, 42),
              ),
            ),
            if (_laeuft)
              OutlinedButton.icon(
                onPressed: _stopp,
                icon: const Icon(Icons.stop_rounded, size: 19),
                label: const Text('Anhalten'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: f,
                  side: BorderSide(color: f),
                  minimumSize: const Size(0, 42),
                ),
              ),
          ],
        ),
        if (_stand.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 9),
            child: Text(
              _stand,
              style: TextStyle(fontSize: 13.5, color: f),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: TextField(
            controller: _c,
            minLines: 6,
            maxLines: 20,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(fontSize: 16.5, height: 1.65),
            decoration: const InputDecoration(
              hintText: 'Schreib mit, was du hörst …',
              contentPadding: EdgeInsets.fromLTRB(13, 12, 13, 12),
            ),
            onChanged: (v) =>
                Speicher.ich.antwortSetzen(widget.datum, 'diktat', v),
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: _c.text.trim().isEmpty ? null : _pruefen,
          icon: const Icon(Icons.fact_check_outlined, size: 19),
          label: const Text('Vergleichen'),
          style: FilledButton.styleFrom(
            backgroundColor: Stil.gutFarbe(context),
            foregroundColor: Stil.kartenGrund(context),
            minimumSize: const Size(0, 42),
          ),
        ),
        if (_vergleich != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            decoration: BoxDecoration(
              color: Stil.blass(context, f),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$prozent % richtig',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: f,
                  ),
                ),
                Text(
                  '$treffer von $soll Wörtern getroffen',
                  style:
                      TextStyle(fontSize: 13.5, color: Stil.weich(context)),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 5,
                  runSpacing: 6,
                  children: [
                    for (final p in _vergleich!) _WortChip(p: p),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _Legende('fehlt', Stil.gutFarbe(context)),
                    const SizedBox(width: 14),
                    _Legende(
                        'zu viel', Stil.blockFarbe(context, 'telc')),
                  ],
                ),
              ],
            ),
          ),
        ],
        if (textVon(widget.d['erklaerung']).isNotEmpty)
          Kasten(
            farbe: f,
            titel: 'Worauf es ankommt',
            kind: MarkText(
              textVon(widget.d['erklaerung']),
              stil: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ),
        if (listeVon(widget.d['fallen']).isNotEmpty)
          Kasten(
            farbe: Stil.goldFarbe(context),
            titel: 'Die Fallen in diesem Text',
            kind: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final x in listeVon(widget.d['fallen']))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: MarkText(
                      '› $x',
                      stil: const TextStyle(fontSize: 15, height: 1.45),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

enum _Art { gleich, fehlt, zuviel }

class _Wortpaar {
  _Wortpaar(this.wort, this.art);
  final String wort;
  final _Art art;
}

/// Ein einfacher Wortvergleich (längste gemeinsame Teilfolge). Er ist bewusst
/// nachsichtig bei Groß-/Kleinschreibung und Satzzeichen — es geht ums Hören,
/// nicht ums Komma.
List<_Wortpaar> _vergleichen(String soll, String ist) {
  String norm(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-zäöüß0-9]'), '');

  final a = soll
      .replaceAll('**', '')
      .split(RegExp(r'\s+'))
      .where((w) => w.trim().isNotEmpty)
      .toList();
  final b = ist
      .split(RegExp(r'\s+'))
      .where((w) => w.trim().isNotEmpty)
      .toList();

  final n = a.length, m = b.length;
  final tab = List.generate(n + 1, (_) => List<int>.filled(m + 1, 0));
  for (var i = n - 1; i >= 0; i--) {
    for (var j = m - 1; j >= 0; j--) {
      tab[i][j] = norm(a[i]) == norm(b[j]) && norm(a[i]).isNotEmpty
          ? tab[i + 1][j + 1] + 1
          : (tab[i + 1][j] >= tab[i][j + 1] ? tab[i + 1][j] : tab[i][j + 1]);
    }
  }

  final raus = <_Wortpaar>[];
  var i = 0, j = 0;
  while (i < n && j < m) {
    if (norm(a[i]) == norm(b[j]) && norm(a[i]).isNotEmpty) {
      raus.add(_Wortpaar(a[i], _Art.gleich));
      i++;
      j++;
    } else if (tab[i + 1][j] >= tab[i][j + 1]) {
      raus.add(_Wortpaar(a[i], _Art.fehlt));
      i++;
    } else {
      raus.add(_Wortpaar(b[j], _Art.zuviel));
      j++;
    }
  }
  while (i < n) {
    raus.add(_Wortpaar(a[i], _Art.fehlt));
    i++;
  }
  while (j < m) {
    raus.add(_Wortpaar(b[j], _Art.zuviel));
    j++;
  }
  return raus;
}

class _WortChip extends StatelessWidget {
  const _WortChip({required this.p});
  final _Wortpaar p;

  @override
  Widget build(BuildContext context) {
    if (p.art == _Art.gleich) {
      return Text(p.wort, style: const TextStyle(fontSize: 16, height: 1.5));
    }
    final fehlt = p.art == _Art.fehlt;
    final f = fehlt
        ? Stil.gutFarbe(context)
        : Stil.blockFarbe(context, 'telc');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: Stil.blass(context, f),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        p.wort,
        style: TextStyle(
          fontSize: 16,
          height: 1.5,
          fontWeight: FontWeight.w600,
          color: f,
          decoration: fehlt ? null : TextDecoration.lineThrough,
        ),
      ),
    );
  }
}

class _Legende extends StatelessWidget {
  const _Legende(this.text, this.farbe);
  final String text;
  final Color farbe;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Stil.blass(context, farbe),
              border: Border.all(color: farbe),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 5),
          Text(text,
              style: TextStyle(fontSize: 12.5, color: Stil.weich(context))),
        ],
      );
}
