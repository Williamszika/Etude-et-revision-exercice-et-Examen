import 'package:flutter/material.dart';

import '../daten/modelle.dart';
import '../daten/quelle.dart';
import '../logik/zyklus.dart';
import 'schau.dart';
import 'stil.dart';
import 'tag_seite.dart';

/// Die Startseite: oben der Fortschritt, darunter die Tagesleiste, darunter
/// der Tag selbst.
class StartSeite extends StatefulWidget {
  const StartSeite({super.key, required this.daten});
  final Daten daten;

  @override
  State<StartSeite> createState() => _StartSeiteState();
}

class _StartSeiteState extends State<StartSeite> with WidgetsBindingObserver {
  late Daten _daten = widget.daten;
  late List<Tag> _tage = Tag.bauen(_daten);
  int _wahl = 0;
  bool _laedt = false;

  /// Wann zuletzt wirklich geholt wurde. Verhindert, dass jedes kurze
  /// Weglegen und Zurückholen des Telefons eine Anfrage auslöst.
  DateTime? _zuletzt;
  static const _mindestAbstand = Duration(minutes: 2);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Beim Start still nachladen. Wenn es klappt, erscheint die neue Lektion
    // von selbst; wenn nicht, bleibt einfach stehen, was schon da war.
    WidgetsBinding.instance.addPostFrameCallback((_) => _auffrischen());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// **Der Grund, warum es das gibt — ihre Meldung vom 19.09.2026:**
  /// *„j'ai déjà aussi l'app sur mon iPhone. Juste que il ne se met pas à
  /// jour automatique."*
  ///
  /// Nachgeladen wurde bis dahin nur in `initState`, also **beim Kaltstart**.
  /// Auf dem iPhone kommt der so gut wie nie vor: Man schließt eine App nicht,
  /// man wechselt weg, iOS friert sie ein, und beim Zurückwechseln läuft
  /// derselbe State weiter — `initState` nicht. Die 5:30-Lektion kam also erst
  /// an, wenn sie die App aus dem Umschalter warf oder von selbst auf die Idee
  /// kam, die Seite nach unten zu ziehen.
  ///
  /// Jetzt wird bei jedem Zurückwechseln geholt, höchstens alle zwei Minuten.
  @override
  void didChangeAppLifecycleState(AppLifecycleState zustand) {
    if (zustand != AppLifecycleState.resumed) return;
    final z = _zuletzt;
    if (z != null && DateTime.now().difference(z) < _mindestAbstand) return;
    _auffrischen();
  }

  Future<void> _auffrischen() async {
    if (_laedt) return;
    setState(() => _laedt = true);
    _zuletzt = DateTime.now();
    final neu = await Quelle.holen();
    if (!mounted) return;
    setState(() {
      _laedt = false;
      if (neu != null) {
        final altesDatum = _tage.isEmpty ? null : _tage[_wahl].datum;
        _daten = neu;
        _tage = Tag.bauen(neu);
        _wahl = 0;
        if (altesDatum != null) {
          final i = _tage.indexWhere((t) => t.datum == altesDatum);
          if (i >= 0) _wahl = i;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_tage.isEmpty) return _Leer(start: _daten.start);
    final tag = _tage[_wahl];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Kopf(daten: _daten, tage: _tage),
            _Leiste(
              tage: _tage,
              wahl: _wahl,
              beiWahl: (i) => setState(() => _wahl = i),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _auffrischen,
                child: TagSeite(
                  key: ValueKey(tag.datum),
                  tag: tag,
                  daten: _daten,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _Blaettern(
        anzahl: _tage.length,
        wahl: _wahl,
        beiWahl: (i) => setState(() => _wahl = i),
      ),
    );
  }
}

/// Der Fortschrittskopf — dieselben Zahlen wie auf der Webseite, aber
/// animiert: Der Ring füllt sich, die Zahlen zählen hoch, das Themenband
/// klappt Block für Block auf.
class _Kopf extends StatelessWidget {
  const _Kopf({required this.daten, required this.tage});
  final Daten daten;
  final List<Tag> tage;

  @override
  Widget build(BuildContext context) {
    final heute = Zyklus.heute;
    final z = daten.lektionen.isEmpty
        ? <String, dynamic>{}
        : daten.lektionen.first.zyklus;

    final lektion = zahlVon(z['lektion']) ??
        Zyklus.lektionsNr(daten.start, heute, daten.lektionenGesamt);
    final wdh =
        Zyklus.istWiederholung(daten.start, heute, daten.themenGesamt);
    final block = zahlVon(z['themaBlock']) ??
        Zyklus.themenBlock(daten.start, heute, daten.themenGesamt);

    var woerter = 0;
    for (final l in daten.lektionen) {
      final v = l.block('vokabeln');
      if (v != null) {
        woerter += zeilenVon(v['woerter']).length;
      } else {
        final ls = l.block('lesen');
        if (ls != null) {
          woerter += zeilenVon(mapVon(ls['wortschatz'])['woerter']).length;
        }
      }
    }
    final rest = Zyklus.tageZwischen(heute, daten.etappeEnde).clamp(0, 9999);
    final dabei = Zyklus.tageZwischen(daten.start, heute) + 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Stil.linienFarbe(context))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ETAPPE 1 · A2 → B1',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        color: Stil.akzentFarbe(context),
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Deutsch täglich',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                        letterSpacing: -.7,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Straehne(tage: dabei < 1 ? 1 : dabei),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Ring(
                anteil: daten.lektionenGesamt == 0
                    ? 0
                    : lektion / daten.lektionenGesamt,
                oben: '$lektion',
                unten: 'von ${daten.lektionenGesamt}',
                groesse: 110,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                // Nicht fest verdrahten: Am 19.09.2026 wurde aus 21 Bloecken 29,
                // und hier stand danach weiter "DIE 21 GRAMMATIKTHEMEN" ueber
                // einem Band mit 29 Feldern. Sie hat es auf dem Screenshot
                // gesehen, bevor ich es gemerkt habe.
                'DIE ${daten.themenGesamt} GRAMMATIKTHEMEN',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Stil.weich(context),
                ),
              ),
              Flexible(
                child: Text(
                  wdh
                      ? 'Wiederholung'
                      : (block > 0 ? 'Thema $block von ${daten.themenGesamt}' : ''),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: Stil.goldFarbe(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Themenband(
            gesamt: daten.themenGesamt,
            fertig: wdh ? daten.themenGesamt : (block - 1).clamp(0, 99),
            jetzt: wdh ? 0 : block,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Zahl(wert: daten.lektionen.length, was: 'Lektionen da'),
              const SizedBox(width: 9),
              _Zahl(wert: woerter, was: 'Vokabeln'),
              const SizedBox(width: 9),
              // Das Datum kommt aus etappeEnde, nicht aus dem Quelltext.
              // Die Zahl darueber war schon richtig (134 Tage bis zum
              // 31.01.2027), nur die Beschriftung sagte noch 31.12.
              _Zahl(
                wert: rest,
                was: 'Tage bis ${Zyklus.kurzesDatum(daten.etappeEnde)}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Zahl extends StatelessWidget {
  const _Zahl({required this.wert, required this.was});
  final int wert;
  final String was;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
          decoration: BoxDecoration(
            color: Stil.kartenGrund(context),
            border: Border.all(color: Stil.linienFarbe(context)),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ZaehlZahl(
                wert,
                stil: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                was.toUpperCase(),
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .7,
                  color: Stil.weich(context),
                ),
              ),
            ],
          ),
        ),
      );
}

/// Die Datumsleiste. Übungstage stehen gestrichelt mit ✎ da — als eigener Tag,
/// nicht als Anhängsel der Lektion.
class _Leiste extends StatelessWidget {
  const _Leiste({
    required this.tage,
    required this.wahl,
    required this.beiWahl,
  });

  final List<Tag> tage;
  final int wahl;
  final void Function(int) beiWahl;

  @override
  Widget build(BuildContext context) {
    final heute = Zyklus.heute;
    return Container(
      height: 54,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Stil.linienFarbe(context))),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        itemCount: tage.length,
        itemBuilder: (context, i) {
          final t = tage[i];
          final an = i == wahl;
          final f = t.uebung
              ? Stil.blockFarbe(context, 'probe')
              : Stil.akzentFarbe(context);
          final istHeute = t.datum == heute;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () => beiWahl(i),
              borderRadius: BorderRadius.circular(9),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                decoration: BoxDecoration(
                  color: an ? f : Stil.kartenGrund(context),
                  border: Border.all(
                    color: an ? f : (t.uebung ? f : Stil.linienFarbe(context)),
                    width: an ? 1 : 1,
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  children: [
                    if (t.uebung)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text('✎',
                            style: TextStyle(
                              fontSize: 12,
                              color: an ? Stil.kartenGrund(context) : f,
                            )),
                      ),
                    Text(
                      istHeute
                          ? 'Heute · ${Zyklus.kurzesDatum(t.datum)}'
                          : Zyklus.kurzesDatum(t.datum),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            istHeute ? FontWeight.w700 : FontWeight.w500,
                        color: an
                            ? Stil.kartenGrund(context)
                            : (t.uebung ? f : Stil.weich(context)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Blaettern extends StatelessWidget {
  const _Blaettern({
    required this.anzahl,
    required this.wahl,
    required this.beiWahl,
  });

  final int anzahl;
  final int wahl;
  final void Function(int) beiWahl;

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Stil.kartenGrund(context),
            border:
                Border(top: BorderSide(color: Stil.linienFarbe(context))),
          ),
          child: Row(
            children: [
              // „Gestern“ ist im Index weiter hinten, weil die Liste neueste
              // zuerst sortiert ist.
              OutlinedButton.icon(
                onPressed: wahl < anzahl - 1 ? () => beiWahl(wahl + 1) : null,
                icon: const Icon(Icons.chevron_left_rounded, size: 20),
                label: const Text('Gestern'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: wahl > 0 ? () => beiWahl(wahl - 1) : null,
                icon: const Icon(Icons.chevron_right_rounded, size: 20),
                iconAlignment: IconAlignment.end,
                label: const Text('Morgen'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                ),
              ),
            ],
          ),
        ),
      );
}

class _Leer extends StatelessWidget {
  const _Leer({required this.start});
  final String start;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('📚', style: TextStyle(fontSize: 44)),
                const SizedBox(height: 14),
                const Text(
                  'Noch keine Lektion',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Es geht am ${Zyklus.kurzesDatum(start)} los. '
                  'Zieh die Seite nach unten, um nachzuschauen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Stil.weich(context)),
                ),
              ],
            ),
          ),
        ),
      );
}
