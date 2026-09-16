import 'package:flutter/material.dart';

import '../daten/modelle.dart';
import '../daten/speicher.dart';
import 'sprecher.dart';
import 'stil.dart';
import 'teile.dart';

/// Ein Block, der aus `titel / erklaerung / fr / tabelle / chips / beispiele /
/// tipp / test` besteht. Damit sind `verb`, `wortschatz` und `grammatik`
/// abgedeckt — sie haben im JSON dieselbe Form.
class TextBlock extends StatelessWidget {
  const TextBlock({
    super.key,
    required this.name,
    required this.etikett,
    required this.d,
    required this.datum,
  });

  final String name;
  final String etikett;
  final Map<String, dynamic> d;
  final String datum;

  @override
  Widget build(BuildContext context) {
    final f = Stil.blockFarbe(context, name);
    final tab = mapVon(d['tabelle']);
    final kopf = listeVon(tab['head']);
    final zeilen = (tab['rows'] is List)
        ? (tab['rows'] as List)
            .whereType<List>()
            .map((r) => r.map((x) => '$x').toList())
            .toList()
        : <List<String>>[];
    final test = mapVon(d['test']);
    final fehler = mapVon(d['fehler']);

    return BlockKarte(
      block: name,
      etikett: etikett,
      titel: textVon(d['titel']),
      untertitel: textVon(d['uebersetzung']),
      kinder: [
        if (textVon(d['titel']).isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: HoerKnopf(textVon(d['titel']), farbe: f, groesse: 20),
          ),
        Absatz(textVon(d['erklaerung'])),
        FrZeile(textVon(d['fr'])),
        Chips(listeVon(d['chips'])),
        Tabelle(kopf: kopf, zeilen: zeilen),
        for (final b in zeilenVon(d['beispiele']))
          SatzZeile(
            de: textVon(b['de']),
            fr: textVon(b['fr']),
            farbe: f,
          ),
        if (fehler.isNotEmpty)
          Kasten(
            farbe: Stil.blockFarbe(context, 'telc'),
            titel: 'Typischer Fehler',
            kind: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  textVon(fehler['falsch']),
                  style: TextStyle(
                    fontSize: 15.5,
                    decoration: TextDecoration.lineThrough,
                    color: Stil.blockFarbe(context, 'telc'),
                  ),
                ),
                const SizedBox(height: 3),
                MarkText(
                  textVon(fehler['richtig']),
                  stil: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: Stil.gutFarbe(context),
                  ),
                ),
                if (textVon(fehler['warum']).isNotEmpty) ...[
                  const SizedBox(height: 4),
                  MarkText(
                    textVon(fehler['warum']),
                    stil: TextStyle(fontSize: 14, color: Stil.weich(context)),
                  ),
                ],
              ],
            ),
          ),
        for (final s in listeVon(d['sprechen']))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: SatzZeile(de: s, fr: '', farbe: f),
          ),
        if (textVon(d['diskussion']).isNotEmpty)
          Kasten(
            farbe: f,
            titel: 'Laut sprechen',
            kind: MarkText(
              textVon(d['diskussion']),
              stil: const TextStyle(fontSize: 15.5, height: 1.5),
            ),
          ),
        if (textVon(d['tipp']).isNotEmpty)
          Kasten(
            farbe: Stil.goldFarbe(context),
            titel: 'Tipp',
            kind: MarkText(
              textVon(d['tipp']),
              stil: const TextStyle(fontSize: 15.5, height: 1.5),
            ),
          ),
        if (test.isNotEmpty) ...[
          const SizedBox(height: 14),
          _Aufgabe(
            nummer: null,
            typ: 'Selbsttest',
            frage: textVon(test['frage']),
            loesung: textVon(test['loesung']),
            hinweis: '',
            farbe: f,
            datum: datum,
            feld: '$name-test',
          ),
        ],
      ],
    );
  }
}

/// Vokabeln — der Block, den sie am häufigsten benutzt.
///
/// Vier Schalter wie auf der Webseite (alles zeigen, Deutsch verdecken,
/// Französisch verdecken), ✓ gewusst pro Wort mit Zähler, und pro Wort ein
/// Vorlese-Knopf.
class VokabelBlock extends StatefulWidget {
  const VokabelBlock({super.key, required this.d, required this.datum});
  final Map<String, dynamic> d;
  final String datum;

  @override
  State<VokabelBlock> createState() => _VokabelBlockState();
}

enum _Sicht { alles, ohneDe, ohneFr }

class _VokabelBlockState extends State<VokabelBlock> {
  _Sicht _sicht = _Sicht.alles;
  final Set<int> _aufgedeckt = {};

  @override
  Widget build(BuildContext context) {
    final f = Stil.blockFarbe(context, 'vokabeln');
    final woerter = zeilenVon(widget.d['woerter']);
    final schluessel = [for (final w in woerter) textVon(w['de'])];
    final koennen = Speicher.ich.gewussteVon(schluessel);
    final aufgabe = mapVon(widget.d['aufgabe']);

    return BlockKarte(
      block: 'vokabeln',
      etikett: 'Vokabeln des Tages',
      titel: textVon(widget.d['titel']),
      untertitel: textVon(widget.d['thema']),
      kinder: [
        FrZeile(textVon(widget.d['fr'])),
        const SizedBox(height: 12),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _Schalter(
              'Alles zeigen',
              an: _sicht == _Sicht.alles,
              farbe: f,
              beiKlick: () => setState(() {
                _sicht = _Sicht.alles;
                _aufgedeckt.clear();
              }),
            ),
            _Schalter(
              'Deutsch verdecken',
              an: _sicht == _Sicht.ohneDe,
              farbe: f,
              beiKlick: () => setState(() {
                _sicht = _Sicht.ohneDe;
                _aufgedeckt.clear();
              }),
            ),
            _Schalter(
              'Französisch verdecken',
              an: _sicht == _Sicht.ohneFr,
              farbe: f,
              beiKlick: () => setState(() {
                _sicht = _Sicht.ohneFr;
                _aufgedeckt.clear();
              }),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Stil.blass(context, f),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$koennen von ${woerter.length} gewusst',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: f,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < woerter.length; i++)
          _Vokabel(
            w: woerter[i],
            farbe: f,
            verdecktDe: _sicht == _Sicht.ohneDe && !_aufgedeckt.contains(i),
            verdecktFr: _sicht == _Sicht.ohneFr && !_aufgedeckt.contains(i),
            beiAufdecken: () => setState(() => _aufgedeckt.add(i)),
            beiHaken: () => setState(() {}),
          ),
        if (aufgabe.isNotEmpty) ...[
          const SizedBox(height: 14),
          Kasten(
            farbe: f,
            titel: 'Deine Aufgabe',
            kind: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkText(
                  textVon(aufgabe['frage']),
                  stil: const TextStyle(fontSize: 15.5, height: 1.5),
                ),
                if (textVon(aufgabe['hinweis']).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: MarkText(
                      textVon(aufgabe['hinweis']),
                      stil: TextStyle(
                        fontSize: 14,
                        color: Stil.weich(context),
                      ),
                    ),
                  ),
                AntwortFeld(
                  datum: widget.datum,
                  feld: 'vokabeln-aufgabe',
                  zeilen: 5,
                ),
                Loesung(text: textVon(aufgabe['muster'])),
              ],
            ),
          ),
        ],
        if (textVon(widget.d['tipp']).isNotEmpty)
          Kasten(
            farbe: Stil.goldFarbe(context),
            titel: 'Tipp',
            kind: MarkText(textVon(widget.d['tipp'])),
          ),
      ],
    );
  }
}

class _Vokabel extends StatelessWidget {
  const _Vokabel({
    required this.w,
    required this.farbe,
    required this.verdecktDe,
    required this.verdecktFr,
    required this.beiAufdecken,
    required this.beiHaken,
  });

  final Map<String, dynamic> w;
  final Color farbe;
  final bool verdecktDe;
  final bool verdecktFr;
  final VoidCallback beiAufdecken;
  final VoidCallback beiHaken;

  @override
  Widget build(BuildContext context) {
    final de = textVon(w['de']);
    final fr = textVon(w['fr']);
    final kann = Speicher.ich.gewusst(de);
    final gut = Stil.gutFarbe(context);

    return Container(
      margin: const EdgeInsets.only(top: 7),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: kann ? Stil.blass(context, gut) : Stil.papierZwei(context),
        border: Border.all(
          color: kann ? gut : Stil.linienFarbe(context),
        ),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Verdeckbar(
                      text: de,
                      verdeckt: verdecktDe,
                      beiKlick: beiAufdecken,
                      stil: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    if (textVon(w['wortart']).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Etikett(textVon(w['wortart']), farbe: farbe),
                      ),
                    const SizedBox(height: 4),
                    _Verdeckbar(
                      text: fr,
                      verdeckt: verdecktFr,
                      beiKlick: beiAufdecken,
                      stil: TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: Stil.weich(context),
                      ),
                    ),
                  ],
                ),
              ),
              HoerKnopf(de, farbe: farbe),
            ],
          ),
          if (textVon(w['beispiel']).isNotEmpty && !verdecktDe) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.only(left: 9),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Stil.blass(context, farbe), width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: MarkText(
                          textVon(w['beispiel']),
                          stil: const TextStyle(fontSize: 14.5, height: 1.45),
                        ),
                      ),
                      HoerKnopf(
                        textVon(w['beispiel']),
                        farbe: farbe,
                        groesse: 16,
                      ),
                    ],
                  ),
                  if (textVon(w['beispielFr']).isNotEmpty)
                    Text(
                      textVon(w['beispielFr']),
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Stil.weich(context),
                      ),
                    ),
                ],
              ),
            ),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () async {
                await Speicher.ich.gewusstSetzen(de, !kann);
                beiHaken();
              },
              icon: Icon(
                kann ? Icons.check_circle : Icons.circle_outlined,
                size: 17,
                color: kann ? gut : Stil.weich(context),
              ),
              label: Text(kann ? 'gewusst' : 'als gewusst markieren'),
              style: TextButton.styleFrom(
                foregroundColor: kann ? gut : Stil.weich(context),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(fontSize: 12.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Verdeckbar extends StatelessWidget {
  const _Verdeckbar({
    required this.text,
    required this.verdeckt,
    required this.beiKlick,
    required this.stil,
  });

  final String text;
  final bool verdeckt;
  final VoidCallback beiKlick;
  final TextStyle stil;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    if (!verdeckt) return MarkText(text, stil: stil);
    return GestureDetector(
      onTap: beiKlick,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: Stil.linienFarbe(context),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'tippen zum Aufdecken',
          style: stil.copyWith(
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            color: Stil.weich(context),
          ),
        ),
      ),
    );
  }
}

class _Schalter extends StatelessWidget {
  const _Schalter(
    this.text, {
    required this.an,
    required this.farbe,
    required this.beiKlick,
  });

  final String text;
  final bool an;
  final Color farbe;
  final VoidCallback beiKlick;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: beiKlick,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: an ? farbe : Stil.kartenGrund(context),
            border: Border.all(color: farbe),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: an ? Stil.kartenGrund(context) : farbe,
            ),
          ),
        ),
      );
}

/// Im Leben — was sie sagt und was sie hören wird.
class LebenBlock extends StatelessWidget {
  const LebenBlock({super.key, required this.d, required this.datum});
  final Map<String, dynamic> d;
  final String datum;

  @override
  Widget build(BuildContext context) {
    final f = Stil.blockFarbe(context, 'leben');
    final rot = Stil.blockFarbe(context, 'telc');
    return BlockKarte(
      block: 'leben',
      etikett: 'Im Leben · ${textVon(d['wo'])}',
      titel: textVon(d['titel']),
      kinder: [
        Absatz(textVon(d['situation'])),
        if (textVon(d['warum']).isNotEmpty)
          Kasten(
            farbe: f,
            titel: 'Warum das zählt',
            kind: MarkText(
              textVon(d['warum']),
              stil: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ),
        FrZeile(textVon(d['fr'])),
        _Unterteil('Das sagst du', f),
        for (final s in zeilenVon(d['dusagst']))
          SatzZeile(de: textVon(s['de']), fr: textVon(s['fr']), farbe: f),
        _Unterteil('Das wirst du hören', Stil.weich(context)),
        for (final s in zeilenVon(d['duhoerst']))
          SatzZeile(de: textVon(s['de']), fr: textVon(s['fr']), farbe: f),
        if (listeVon(d['rettung']).isNotEmpty) ...[
          _Unterteil('🛟 Wenn du nicht mehr weiterweißt', f),
          for (final s in listeVon(d['rettung']))
            SatzZeile(de: s, fr: '', farbe: f),
        ],
        for (final fa in zeilenVon(d['fallen']))
          Kasten(
            farbe: rot,
            kind: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  textVon(fa['falsch']),
                  style: TextStyle(
                    fontSize: 15.5,
                    decoration: TextDecoration.lineThrough,
                    color: rot,
                  ),
                ),
                const SizedBox(height: 3),
                MarkText(
                  textVon(fa['richtig']),
                  stil: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: Stil.gutFarbe(context),
                  ),
                ),
                if (textVon(fa['warum']).isNotEmpty) ...[
                  const SizedBox(height: 4),
                  MarkText(
                    textVon(fa['warum']),
                    stil: TextStyle(fontSize: 14, color: Stil.weich(context)),
                  ),
                ],
              ],
            ),
          ),
        if (textVon(d['heute']).isNotEmpty) ...[
          const SizedBox(height: 14),
          Kasten(
            farbe: f,
            titel: 'Heute wirklich machen',
            kind: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkText(
                  textVon(d['heute']),
                  stil: const TextStyle(fontSize: 15.5, height: 1.5),
                ),
                const SizedBox(height: 4),
                Text(
                  'Was ich gesagt habe / was ich nicht verstanden habe:',
                  style: TextStyle(fontSize: 13.5, color: Stil.weich(context)),
                ),
                AntwortFeld(
                  datum: datum,
                  feld: 'leben-heute',
                  zeilen: 4,
                  platzhalter: 'Auch das, was du nicht verstanden hast — '
                      'das ist die wertvollere Information.',
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Unterteil extends StatelessWidget {
  const _Unterteil(this.text, this.farbe);
  final String text;
  final Color farbe;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 2),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: .9,
            color: farbe,
          ),
        ),
      );
}

/// Die Kette — Deklination Glied für Glied.
class DeklinationBlock extends StatelessWidget {
  const DeklinationBlock({super.key, required this.d, required this.datum});
  final Map<String, dynamic> d;
  final String datum;

  static const _glieder = [
    ['1 · Wer bestimmt?', 'bestimmer'],
    ['2 · Welcher Fall?', 'fall'],
    ['3 · Welches Genus?', 'genus'],
    ['4 · Welcher Artikel?', 'artikel'],
    ['5 · Welche Endung?', 'adjektiv'],
  ];

  @override
  Widget build(BuildContext context) {
    final f = Stil.blockFarbe(context, 'deklination');
    final saetze = zeilenVon(d['saetze']);
    final stufe = zahlVon(d['stufe']);

    return BlockKarte(
      block: 'deklination',
      etikett: stufe == null ? 'Die Kette' : 'Die Kette · Stufe $stufe',
      titel: textVon(d['titel']),
      kinder: [
        FrZeile(textVon(d['fr'])),
        for (var i = 0; i < saetze.length; i++) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
            decoration: BoxDecoration(
              color: Stil.papierZwei(context),
              border: Border.all(color: Stil.linienFarbe(context)),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Etikett('Satz ${i + 1}', farbe: f),
                  ],
                ),
                const SizedBox(height: 7),
                MarkText(
                  textVon(saetze[i]['luecke']),
                  stil: const TextStyle(fontSize: 16.5, height: 1.5),
                ),
                AntwortFeld(
                  datum: datum,
                  feld: 'dekl-$i',
                  zeilen: 1,
                  platzhalter: 'Ganzer Satz …',
                ),
                _KettenKlapp(satz: saetze[i], farbe: f),
              ],
            ),
          ),
        ],
        if (textVon(d['tipp']).isNotEmpty)
          Kasten(
            farbe: Stil.goldFarbe(context),
            titel: 'Tipp',
            kind: MarkText(textVon(d['tipp'])),
          ),
      ],
    );
  }
}

class _KettenKlapp extends StatefulWidget {
  const _KettenKlapp({required this.satz, required this.farbe});
  final Map<String, dynamic> satz;
  final Color farbe;

  @override
  State<_KettenKlapp> createState() => _KettenKlappState();
}

class _KettenKlappState extends State<_KettenKlapp> {
  bool _offen = false;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => setState(() => _offen = !_offen),
            icon: Icon(_offen ? Icons.remove : Icons.add, size: 17),
            label: Text(_offen ? 'Kette verbergen' : 'Die Kette Glied für Glied'),
            style: TextButton.styleFrom(
              foregroundColor: widget.farbe,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 34),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          if (_offen) ...[
            for (final g in DeklinationBlock._glieder)
              if (textVon(widget.satz[g[1]]).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 128,
                        child: Text(
                          g[0],
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: widget.farbe,
                          ),
                        ),
                      ),
                      Expanded(
                        child: MarkText(
                          textVon(widget.satz[g[1]]),
                          stil: const TextStyle(fontSize: 14.5, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
              decoration: BoxDecoration(
                color: Stil.blass(context, Stil.gutFarbe(context)),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarkText(
                    textVon(widget.satz['loesung']),
                    stil: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: Stil.gutFarbe(context),
                    ),
                  ),
                  if (textVon(widget.satz['hinweis']).isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: MarkText(
                        textVon(widget.satz['hinweis']),
                        stil: TextStyle(
                          fontSize: 13.5,
                          color: Stil.weich(context),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      );
}

/// Ein Block mit `aufgaben` — deckt `training`, `telc` und `probe` ab.
class AufgabenBlock extends StatelessWidget {
  const AufgabenBlock({
    super.key,
    required this.name,
    required this.d,
    required this.datum,
  });

  final String name;
  final Map<String, dynamic> d;
  final String datum;

  @override
  Widget build(BuildContext context) {
    final f = Stil.blockFarbe(context, name);
    final aufgaben = zeilenVon(d['aufgaben']);
    final dialog = mapVon(d['dialog']);
    final etikett = textVon(d['badge']).isNotEmpty
        ? textVon(d['badge'])
        : (name == 'telc'
            ? 'Fertigkeit des Tages'
            : name == 'probe'
                ? 'Probeprüfung'
                : 'Training');

    return BlockKarte(
      block: name,
      etikett: etikett,
      titel: textVon(d['titel']),
      kinder: [
        if (listeVon(d['teile']).isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final t in listeVon(d['teile']))
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                    decoration: BoxDecoration(
                      color: f,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Stil.kartenGrund(context),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (textVon(d['pruefungsziel']).isNotEmpty)
          Kasten(
            farbe: f,
            titel: 'Worum es heute geht',
            kind: MarkText(
              textVon(d['pruefungsziel']),
              stil: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ),
        Absatz(textVon(d['ziel'])),
        FrZeile(textVon(d['fr'])),
        if (textVon(d['text']).isNotEmpty) ...[
          const SizedBox(height: 12),
          _Lesekasten(text: textVon(d['text']), farbe: f),
        ],
        for (var i = 0; i < aufgaben.length; i++)
          _Aufgabe(
            nummer: i + 1,
            typ: textVon(aufgaben[i]['typ']),
            frage: textVon(aufgaben[i]['frage']),
            loesung: textVon(aufgaben[i]['loesung']),
            hinweis: textVon(aufgaben[i]['hinweis']),
            farbe: f,
            datum: datum,
            feld: '$name-$i',
          ),
        if (dialog.isNotEmpty) ...[
          const SizedBox(height: 16),
          _Unterteil('Dialog · ${textVon(dialog['situation'])}', f),
          for (final z in zeilenVon(dialog['zeilen']))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 74,
                    child: Text(
                      textVon(z['wer']),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: f,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MarkText(
                          textVon(z['satz']),
                          stil: const TextStyle(fontSize: 15.5, height: 1.45),
                        ),
                        if (textVon(z['hinweis']).isNotEmpty)
                          MarkText(
                            textVon(z['hinweis']),
                            stil: TextStyle(
                              fontSize: 13,
                              color: Stil.weich(context),
                            ),
                          ),
                      ],
                    ),
                  ),
                  HoerKnopf(textVon(z['satz']), farbe: f, groesse: 16),
                ],
              ),
            ),
        ],
        if (listeVon(d['alltag']).isNotEmpty) ...[
          const SizedBox(height: 14),
          Kasten(
            farbe: Stil.goldFarbe(context),
            titel: 'Heute im Alltag',
            kind: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final a in listeVon(d['alltag']))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: MarkText(
                      '☐  $a',
                      stil: const TextStyle(fontSize: 15, height: 1.45),
                    ),
                  ),
              ],
            ),
          ),
        ],
        if (textVon(d['tipp']).isNotEmpty)
          Kasten(
            farbe: Stil.goldFarbe(context),
            titel: 'Tipp',
            kind: MarkText(textVon(d['tipp'])),
          ),
      ],
    );
  }
}

class _Aufgabe extends StatelessWidget {
  const _Aufgabe({
    required this.nummer,
    required this.typ,
    required this.frage,
    required this.loesung,
    required this.hinweis,
    required this.farbe,
    required this.datum,
    required this.feld,
  });

  final int? nummer;
  final String typ;
  final String frage;
  final String loesung;
  final String hinweis;
  final Color farbe;
  final String datum;
  final String feld;

  @override
  Widget build(BuildContext context) => Container(
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
            Row(
              children: [
                if (nummer != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: farbe,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$nummer',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Stil.kartenGrund(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (typ.isNotEmpty)
                  Expanded(
                    child: Text(
                      typ.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .7,
                        color: Stil.weich(context),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 7),
            MarkText(frage, stil: const TextStyle(fontSize: 16, height: 1.5)),
            AntwortFeld(datum: datum, feld: feld, zeilen: 2),
            Loesung(text: loesung, hinweis: hinweis, farbe: farbe),
          ],
        ),
      );
}

class _Lesekasten extends StatelessWidget {
  const _Lesekasten({required this.text, required this.farbe});
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
                  padding: const EdgeInsets.only(bottom: 10),
                  child: MarkText(
                    p.trim(),
                    stil: const TextStyle(fontSize: 17, height: 1.72),
                  ),
                ),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: () => Sprecher.ich.sprich(text),
                icon: const Icon(Icons.play_arrow_rounded, size: 19),
                label: const Text('Vorlesen'),
                style: FilledButton.styleFrom(
                  backgroundColor: farbe,
                  foregroundColor: Stil.kartenGrund(context),
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ],
        ),
      );
}

/// Aussprache — ein Satz, laut und langsam.
class AusspracheBlock extends StatelessWidget {
  const AusspracheBlock({super.key, required this.d});
  final Map<String, dynamic> d;

  @override
  Widget build(BuildContext context) {
    final f = Stil.blockFarbe(context, 'aussprache');
    final satz = textVon(d['satz']);
    return BlockKarte(
      block: 'aussprache',
      etikett: 'Aussprache',
      titel: satz,
      kinder: [
        if (textVon(d['lautschrift']).isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              textVon(d['lautschrift']),
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'monospace',
                color: Stil.weich(context),
              ),
            ),
          ),
        if (textVon(d['fokus']).isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Etikett(textVon(d['fokus']), farbe: f),
          ),
        FrZeile(textVon(d['fr'])),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () => Sprecher.ich.sprich(satz, tempo: .45),
              icon: const Icon(Icons.volume_up_rounded, size: 19),
              label: const Text('Normal'),
              style: FilledButton.styleFrom(
                backgroundColor: f,
                foregroundColor: Stil.kartenGrund(context),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => Sprecher.ich.sprich(satz, tempo: .28),
              icon: const Icon(Icons.slow_motion_video_rounded, size: 19),
              label: const Text('Langsam'),
              style: OutlinedButton.styleFrom(
                foregroundColor: f,
                side: BorderSide(color: f),
              ),
            ),
          ],
        ),
        for (final t in listeVon(d['tipps']))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: MarkText(
              '› $t',
              stil: const TextStyle(fontSize: 15, height: 1.45),
            ),
          ),
      ],
    );
  }
}

/// Übersetzung FR → DE.
class UebersetzungBlock extends StatelessWidget {
  const UebersetzungBlock({super.key, required this.d, required this.datum});
  final Map<String, dynamic> d;
  final String datum;

  @override
  Widget build(BuildContext context) {
    final f = Stil.blockFarbe(context, 'uebersetzung');
    final saetze = zeilenVon(d['saetze']);
    return BlockKarte(
      block: 'uebersetzung',
      etikett: 'Übersetzen · Französisch → Deutsch',
      titel: textVon(d['titel']),
      kinder: [
        FrZeile(textVon(d['fr'])),
        for (var i = 0; i < saetze.length; i++)
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
                  '🇫🇷 ${textVon(saetze[i]['fr'])}',
                  stil: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
                AntwortFeld(
                  datum: datum,
                  feld: 'uebersetzung-$i',
                  zeilen: 1,
                  platzhalter: 'Auf Deutsch …',
                ),
                Loesung(
                  text: textVon(saetze[i]['de']),
                  hinweis: textVon(saetze[i]['hinweis']),
                  farbe: f,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
