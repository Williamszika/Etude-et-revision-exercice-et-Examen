import 'package:flutter/material.dart';

import '../daten/speicher.dart';
import 'sprecher.dart';
import 'stil.dart';

/// Die Karte, in der jeder Block steckt — mit farbigem Rücken links und einem
/// Etikett oben, genau wie auf der Webseite.
class BlockKarte extends StatelessWidget {
  const BlockKarte({
    super.key,
    required this.block,
    required this.etikett,
    required this.kinder,
    this.titel,
    this.untertitel,
  });

  final String block;
  final String etikett;
  final String? titel;
  final String? untertitel;
  final List<Widget> kinder;

  @override
  Widget build(BuildContext context) {
    final f = Stil.blockFarbe(context, block);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Stil.kartenGrund(context),
        border: Border(
          left: BorderSide(color: f, width: 3),
          top: BorderSide(color: Stil.linienFarbe(context)),
          right: BorderSide(color: Stil.linienFarbe(context)),
          bottom: BorderSide(color: Stil.linienFarbe(context)),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          bottomLeft: Radius.circular(4),
          topRight: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Etikett(etikett, farbe: f),
          if (titel != null && titel!.isNotEmpty) ...[
            const SizedBox(height: 8),
            MarkText(
              titel!,
              stil: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ],
          if (untertitel != null && untertitel!.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              untertitel!,
              style: TextStyle(
                fontSize: 14.5,
                fontStyle: FontStyle.italic,
                color: Stil.weich(context),
              ),
            ),
          ],
          ...kinder,
        ],
      ),
    );
  }
}

/// Das kleine Großbuchstaben-Etikett („VERB DES TAGES“).
class Etikett extends StatelessWidget {
  const Etikett(this.text, {super.key, required this.farbe});
  final String text;
  final Color farbe;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: Stil.blass(context, farbe),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            // 11 statt 10.5: Etiketten stehen in GROSSBUCHSTABEN und gesperrt,
            // das ist die kleinste Schrift der ganzen App.
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: .8,
            color: farbe,
          ),
        ),
      );
}

/// Die französische Hilfszeile. Auf der Webseite steht davor eine Flagge —
/// hier auch, weil sie daran erkennt: das ist die Erklärung, nicht der Stoff.
class FrZeile extends StatelessWidget {
  const FrZeile(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: MarkText(
        '🇫🇷 $text',
        stil: TextStyle(
          fontSize: 14.5,
          height: 1.5,
          color: Stil.weich(context),
        ),
      ),
    );
  }
}

/// Normaler Fließtext im Block.
class Absatz extends StatelessWidget {
  const Absatz(this.text, {super.key, this.oben = 10, this.groesse = 16});
  final String text;
  final double oben;
  final double groesse;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: oben),
      child: MarkText(text, stil: TextStyle(fontSize: groesse, height: 1.55)),
    );
  }
}

/// Der eingerückte Hinweiskasten (auf der Webseite `.tipbox`).
class Kasten extends StatelessWidget {
  const Kasten({
    super.key,
    required this.kind,
    required this.farbe,
    this.titel,
  });

  final Widget kind;
  final Color farbe;
  final String? titel;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.fromLTRB(13, 11, 13, 12),
        decoration: BoxDecoration(
          color: Stil.blass(context, farbe),
          border: Border(left: BorderSide(color: farbe, width: 3)),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (titel != null) ...[
              Text(
                titel!,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: farbe,
                ),
              ),
              const SizedBox(height: 5),
            ],
            kind,
          ],
        ),
      );
}

/// Wortchips („trennbar: nimmt … ein“).
class Chips extends StatelessWidget {
  const Chips(this.werte, {super.key});
  final List<String> werte;

  @override
  Widget build(BuildContext context) {
    if (werte.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final w in werte)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: Stil.papierZwei(context),
                border: Border.all(color: Stil.linienFarbe(context)),
                borderRadius: BorderRadius.circular(999),
              ),
              child: MarkText(w, stil: const TextStyle(fontSize: 13.5)),
            ),
        ],
      ),
    );
  }
}

/// Eine Tabelle, die auf dem Telefon seitlich scrollen darf statt zu brechen.
class Tabelle extends StatelessWidget {
  const Tabelle({super.key, required this.kopf, required this.zeilen});
  final List<String> kopf;
  final List<List<String>> zeilen;

  @override
  Widget build(BuildContext context) {
    if (zeilen.isEmpty) return const SizedBox.shrink();
    final linie = Stil.linienFarbe(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 38,
          dataRowMinHeight: 36,
          dataRowMaxHeight: 58,
          horizontalMargin: 10,
          columnSpacing: 22,
          border: TableBorder.all(color: linie, width: .7),
          columns: [
            for (final k in kopf)
              DataColumn(
                label: Text(
                  k.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .6,
                    color: Stil.weich(context),
                  ),
                ),
              ),
          ],
          rows: [
            for (final z in zeilen)
              DataRow(
                cells: [
                  for (var i = 0; i < kopf.length; i++)
                    DataCell(MarkText(
                      i < z.length ? z[i] : '',
                      stil: const TextStyle(fontSize: 14.5),
                    )),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Aufklappbare Lösung. Zu, bis sie selbst nachgedacht hat — das ist der
/// ganze Sinn der Sache, deshalb ist nichts davon vorher sichtbar.
class Loesung extends StatefulWidget {
  const Loesung({
    super.key,
    required this.text,
    this.hinweis = '',
    this.beschriftung = 'Lösung zeigen',
    this.farbe,
  });

  final String text;
  final String hinweis;
  final String beschriftung;
  final Color? farbe;

  @override
  State<Loesung> createState() => _LoesungState();
}

class _LoesungState extends State<Loesung> {
  bool _offen = false;

  @override
  Widget build(BuildContext context) {
    if (widget.text.trim().isEmpty && widget.hinweis.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    final f = widget.farbe ?? Stil.gutFarbe(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => setState(() => _offen = !_offen),
          icon: Icon(_offen ? Icons.remove : Icons.add, size: 17),
          label: Text(_offen ? 'Lösung verbergen' : widget.beschriftung),
          style: TextButton.styleFrom(
            foregroundColor: f,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const Size(0, 34),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        if (_offen)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: f, width: 2.5)),
              color: Stil.blass(context, f),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(9),
                bottomRight: Radius.circular(9),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.text.trim().isNotEmpty)
                  MarkText(
                    widget.text,
                    stil: TextStyle(
                      fontSize: 15.5,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      color: f,
                    ),
                  ),
                if (widget.hinweis.trim().isNotEmpty) ...[
                  const SizedBox(height: 5),
                  MarkText(
                    widget.hinweis,
                    stil: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Stil.weich(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// Ein Schreibfeld, das sich merkt, was drinsteht — gebunden an **Tag +
/// Feldname**, damit ein Übungstag wirklich leer anfängt.
class AntwortFeld extends StatefulWidget {
  const AntwortFeld({
    super.key,
    required this.datum,
    required this.feld,
    this.platzhalter = '',
    this.zeilen = 3,
  });

  final String datum;
  final String feld;
  final String platzhalter;
  final int zeilen;

  @override
  State<AntwortFeld> createState() => _AntwortFeldState();
}

class _AntwortFeldState extends State<AntwortFeld> {
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(
      text: Speicher.ich.antwort(widget.datum, widget.feld),
    );
  }

  @override
  void dispose() {
    Speicher.ich.antwortSetzen(widget.datum, widget.feld, _c.text);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: TextField(
          controller: _c,
          minLines: widget.zeilen,
          maxLines: widget.zeilen + 6,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(fontSize: 16, height: 1.5),
          decoration: InputDecoration(
            hintText: widget.platzhalter.isEmpty
                ? 'Deine Antwort …'
                : widget.platzhalter,
            hintStyle: TextStyle(color: Stil.weich(context), fontSize: 15),
            contentPadding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
          ),
          onChanged: (v) =>
              Speicher.ich.antwortSetzen(widget.datum, widget.feld, v),
        ),
      );
}

/// Eine Zeile „Deutsch — Französisch“ mit Vorlese-Knopf, wie im `leben`-Block.
class SatzZeile extends StatelessWidget {
  const SatzZeile({
    super.key,
    required this.de,
    required this.fr,
    required this.farbe,
  });

  final String de;
  final String fr;
  final Color farbe;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HoerKnopf(de, farbe: farbe),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarkText(
                    de,
                    stil: const TextStyle(fontSize: 16, height: 1.45),
                  ),
                  if (fr.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        fr,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.4,
                          fontStyle: FontStyle.italic,
                          color: Stil.weich(context),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
}
