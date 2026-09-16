import 'package:flutter/material.dart';

import '../daten/modelle.dart';
import '../daten/speicher.dart';
import '../logik/zyklus.dart';
import 'bloecke.dart';
import 'bloecke_lesen.dart';
import 'schau.dart';
import 'stil.dart';

/// Ein Tag — entweder eine Lektion oder ein Übungstag.
class TagSeite extends StatefulWidget {
  const TagSeite({super.key, required this.tag, required this.daten});
  final Tag tag;
  final Daten daten;

  @override
  State<TagSeite> createState() => _TagSeiteState();
}

class _TagSeiteState extends State<TagSeite> {
  int _feier = 0;

  /// Wie viele Vokabeln dieser Lektion sitzen schon?
  (int, int) _vokabelStand() {
    final v = widget.tag.lektion.block('vokabeln');
    if (v == null) return (0, 0);
    final w = [for (final x in zeilenVon(v['woerter'])) textVon(x['de'])];
    return (Speicher.ich.gewussteVon(w), w.length);
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.tag.lektion;
    final uebung = widget.tag.uebung;
    final datum = widget.tag.datum;
    final z = l.zyklus;
    final (kann, alle) = _vokabelStand();

    // Die Blockreihenfolge. An einem Übungstag fallen Verb, Wortschatz,
    // Grammatik und Aussprache weg — das ist Lernstoff und gehört dem
    // Lektionstag. Vokabeln und „Im Leben" bleiben, weil beides Wiederholung
    // braucht. Genau so macht es auch die Webseite.
    final bloecke = <Widget>[];
    void nimm(String name, Widget Function(Map<String, dynamic> d) bauen) {
      final d = l.block(name);
      if (d != null) bloecke.add(bauen(d));
    }

    if (!uebung) {
      nimm('verb', (d) => TextBlock(
          name: 'verb', etikett: 'Verb des Tages', d: d, datum: datum));
      nimm('wortschatz', (d) => TextBlock(
          name: 'wortschatz', etikett: 'Wortschatz', d: d, datum: datum));
    }
    nimm('vokabeln', (d) => VokabelBlock(d: d, datum: datum));
    if (!uebung) {
      nimm('grammatik', (d) => TextBlock(
          name: 'grammatik', etikett: 'Grammatik', d: d, datum: datum));
    }
    nimm('deklination', (d) => DeklinationBlock(d: d, datum: datum));
    nimm('lesen', (d) => LesenBlock(d: d, datum: datum, nurUebungen: uebung));
    nimm('training', (d) =>
        AufgabenBlock(name: 'training', d: d, datum: datum));
    nimm('leben', (d) => LebenBlock(d: d, datum: datum));
    nimm('telc', (d) => AufgabenBlock(name: 'telc', d: d, datum: datum));
    nimm('probe', (d) => AufgabenBlock(name: 'probe', d: d, datum: datum));
    if (!uebung) {
      nimm('aussprache', (d) => AusspracheBlock(d: d));
    }
    nimm('diktat', (d) => DiktatBlock(d: d, datum: datum));
    nimm('uebersetzung', (d) => UebersetzungBlock(d: d, datum: datum));

    return Konfetti(
      ausloesen: _feier,
      kind: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
        children: [
          Text(
            Zyklus.langesDatum(datum),
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            uebung
                ? 'Übungstag · nur Übungen zur Lektion vom '
                    '${Zyklus.kurzesDatum(l.datum)}'
                : 'Lektion ${z['lektion'] ?? ''} · '
                    '${z['fokus'] ?? ''}',
            style: TextStyle(fontSize: 13.5, color: Stil.weich(context)),
          ),
          const SizedBox(height: 12),
          _Kopfzeilen(z: z, uebung: uebung),
          if (uebung) ...[
            const SizedBox(height: 12),
            _UebungstagKasten(vonDatum: l.datum),
          ],
          if (alle > 0) ...[
            const SizedBox(height: 14),
            _VokabelBalken(
              kann: kann,
              alle: alle,
              beiVoll: () => setState(() => _feier++),
            ),
          ],
          const SizedBox(height: 4),
          for (var i = 0; i < bloecke.length; i++)
            Herein(nr: i, kind: bloecke[i]),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Schick mir deine Antworten — sie werden korrigiert,\n'
              'nicht nur gelobt.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: Stil.weich(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Kopfzeilen extends StatelessWidget {
  const _Kopfzeilen({required this.z, required this.uebung});
  final Map<String, dynamic> z;
  final bool uebung;

  @override
  Widget build(BuildContext context) {
    final etiketten = <Widget>[];
    void plus(String text, Color f) => etiketten.add(Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: Stil.blass(context, f),
            border: Border.all(color: f.withValues(alpha: .45)),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: f,
            ),
          ),
        ));

    if (uebung) {
      plus('Übungstag', Stil.blockFarbe(context, 'probe'));
    }
    if (z['etappe'] != null) {
      plus('Etappe ${z['etappe']}', Stil.blockFarbe(context, 'aussprache'));
    }
    if (z['themenTag'] != null) {
      final t = zahlVon(z['themenTag']) ?? 1;
      plus('Thema-Tag $t von 2 · ${t == 1 ? 'entdecken' : 'anwenden'}',
          Stil.blockFarbe(context, 'leben'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(spacing: 7, runSpacing: 7, children: etiketten),
        if (textVon(z['thema']).isNotEmpty) ...[
          const SizedBox(height: 10),
          _Zeile('Thema', textVon(z['thema']),
              nr: z['themaNr'] == null ? null : 'T${z['themaNr']} von 16'),
        ],
        if (textVon(z['grammatik']).isNotEmpty)
          _Zeile('Grammatik', textVon(z['grammatik']),
              nr: z['grammatikNr'] == null
                  ? null
                  : 'G${z['grammatikNr']} von 21'),
      ],
    );
  }
}

class _Zeile extends StatelessWidget {
  const _Zeile(this.was, this.wert, {this.nr});
  final String was;
  final String wert;
  final String? nr;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 7,
          children: [
            Text('$was:',
                style: TextStyle(fontSize: 14.5, color: Stil.weich(context))),
            Text(wert,
                style: const TextStyle(
                    fontSize: 14.5, fontWeight: FontWeight.w700)),
            if (nr != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Stil.papierZwei(context),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(nr!,
                    style: TextStyle(
                        fontSize: 11.5, color: Stil.weich(context))),
              ),
          ],
        ),
      );
}

class _UebungstagKasten extends StatelessWidget {
  const _UebungstagKasten({required this.vonDatum});
  final String vonDatum;

  @override
  Widget build(BuildContext context) {
    final f = Stil.blockFarbe(context, 'probe');
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
      decoration: BoxDecoration(
        color: Stil.kartenGrund(context),
        border: Border.all(color: f, width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Heute gibt es keine neue Lektion',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: f,
            ),
          ),
          const SizedBox(height: 6),
          MarkText(
            'Was hier steht, sind **nur die Aufgaben** zur Lektion vom '
            '${Zyklus.kurzesDatum(vonDatum)} — ohne den Lernstoff. '
            'Die nächste Lektion kommt morgen.',
            stil: const TextStyle(fontSize: 15.5, height: 1.5),
          ),
          const SizedBox(height: 8),
          MarkText(
            '🇫🇷 Aujourd’hui : rien de nouveau, **que des exercices** — '
            'plus le vocabulaire d’hier à réviser. Refais-les sans rouvrir '
            'la leçon : c’est en cherchant que ça rentre. Tes réponses '
            'd’aujourd’hui sont enregistrées à part.',
            stil: TextStyle(
              fontSize: 14.5,
              height: 1.5,
              color: Stil.weich(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Der Vokabelbalken oben — er füllt sich, und wenn er voll ist, fliegt Konfetti.
class _VokabelBalken extends StatefulWidget {
  const _VokabelBalken({
    required this.kann,
    required this.alle,
    required this.beiVoll,
  });

  final int kann;
  final int alle;
  final VoidCallback beiVoll;

  @override
  State<_VokabelBalken> createState() => _VokabelBalkenState();
}

class _VokabelBalkenState extends State<_VokabelBalken> {
  bool _gefeiert = false;

  @override
  void didUpdateWidget(_VokabelBalken alt) {
    super.didUpdateWidget(alt);
    final voll = widget.alle > 0 && widget.kann >= widget.alle;
    if (voll && !_gefeiert) {
      _gefeiert = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.beiVoll());
    } else if (!voll) {
      _gefeiert = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = Stil.blockFarbe(context, 'vokabeln');
    final anteil = widget.alle == 0 ? 0.0 : widget.kann / widget.alle;
    final voll = widget.kann >= widget.alle && widget.alle > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              voll
                  ? 'Alle Vokabeln sitzen 🎉'
                  : 'Vokabeln: ${widget.kann} von ${widget.alle}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: voll ? Stil.gutFarbe(context) : f,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: anteil),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            builder: (context, w, _) => LinearProgressIndicator(
              value: w,
              minHeight: 7,
              backgroundColor: Stil.linienFarbe(context),
              valueColor: AlwaysStoppedAnimation(
                voll ? Stil.gutFarbe(context) : f,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
