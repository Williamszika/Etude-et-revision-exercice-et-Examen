import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'stil.dart';

/// Alles, was sich bewegt.
///
/// Gezeichnet mit `CustomPainter` — das ist Flutters Canvas, dieselbe Idee wie
/// `<canvas>` im Browser, nur direkt auf der GPU. Deshalb läuft es flüssig,
/// auch auf einem älteren Telefon.
///
/// Zurückhaltung ist hier Absicht: Eine Lernseite, auf der ständig etwas
/// zappelt, liest sich schlecht. Die Bewegung markiert **Fortschritt** —
/// der Ring füllt sich, die Zahl zählt hoch, und wenn sie eine Lektion
/// wirklich fertig hat, gibt es Konfetti. Sonst ist Ruhe.

// ---------------------------------------------------------------------------
// Der Fortschrittsring
// ---------------------------------------------------------------------------

class Ring extends StatelessWidget {
  const Ring({
    super.key,
    required this.anteil,
    required this.oben,
    required this.unten,
    this.groesse = 132,
    this.farbe,
  });

  /// 0.0 … 1.0
  final double anteil;
  final String oben;
  final String unten;
  final double groesse;
  final Color? farbe;

  @override
  Widget build(BuildContext context) {
    final f = farbe ?? Stil.akzentFarbe(context);
    return SizedBox(
      width: groesse,
      height: groesse,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: anteil.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 1100),
        curve: Curves.easeOutCubic,
        builder: (context, wert, _) => CustomPaint(
          painter: _RingMaler(
            anteil: wert,
            farbe: f,
            spur: Stil.linienFarbe(context),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Die Zahl zählt mit dem Ring hoch, statt einfach dazustehen.
                Text(
                  oben,
                  style: TextStyle(
                    fontSize: groesse * .27,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    letterSpacing: -1,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unten.toUpperCase(),
                  style: TextStyle(
                    fontSize: groesse * .073,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: Stil.weich(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingMaler extends CustomPainter {
  _RingMaler({required this.anteil, required this.farbe, required this.spur});
  final double anteil;
  final Color farbe;
  final Color spur;

  @override
  void paint(Canvas canvas, Size size) {
    final mitte = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 6;
    final spurStift = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..color = spur;
    canvas.drawCircle(mitte, r, spurStift);

    if (anteil <= 0) return;

    // Ein leichter Verlauf im Bogen — er lässt den Ring lebendig wirken,
    // ohne dass irgendetwas blinkt.
    final bogen = Rect.fromCircle(center: mitte, radius: r);
    final stift = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [farbe.withValues(alpha: .55), farbe],
        stops: const [0, 1],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(bogen);

    canvas.drawArc(bogen, -math.pi / 2, math.pi * 2 * anteil, false, stift);

    // Ein Punkt an der Spitze, damit man sieht, wo sie steht.
    final winkel = -math.pi / 2 + math.pi * 2 * anteil;
    final spitze = Offset(
      mitte.dx + r * math.cos(winkel),
      mitte.dy + r * math.sin(winkel),
    );
    canvas.drawCircle(spitze, 5.5, Paint()..color = farbe);
  }

  @override
  bool shouldRepaint(_RingMaler alt) =>
      alt.anteil != anteil || alt.farbe != farbe || alt.spur != spur;
}

// ---------------------------------------------------------------------------
// Das Themenband — 21 Blöcke, die nacheinander erscheinen
// ---------------------------------------------------------------------------

class Themenband extends StatelessWidget {
  const Themenband({
    super.key,
    required this.gesamt,
    required this.fertig,
    required this.jetzt,
  });

  final int gesamt;
  final int fertig;
  final int jetzt;

  @override
  Widget build(BuildContext context) {
    final ak = Stil.akzentFarbe(context);
    final gold = Stil.goldFarbe(context);
    return Row(
      children: [
        for (var i = 1; i <= gesamt; i++)
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 260 + i * 26),
              curve: Curves.easeOutBack,
              builder: (context, w, kind) => Transform.scale(
                scaleY: w.clamp(0.0, 1.0),
                child: kind,
              ),
              child: Container(
                height: 9,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  color: i <= fertig
                      ? ak
                      : (i == jetzt ? gold : Stil.linienFarbe(context)),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: i == jetzt
                      ? [
                          BoxShadow(
                            color: gold.withValues(alpha: .5),
                            blurRadius: 7,
                            spreadRadius: .5,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Eine Zahl, die hochzählt
// ---------------------------------------------------------------------------

class ZaehlZahl extends StatelessWidget {
  const ZaehlZahl(this.wert, {super.key, this.stil, this.dauer});
  final int wert;
  final TextStyle? stil;
  final Duration? dauer;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: wert.toDouble()),
        duration: dauer ?? const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, w, _) => Text('${w.round()}', style: stil),
      );
}

// ---------------------------------------------------------------------------
// Konfetti — nur bei einem echten Erfolg
// ---------------------------------------------------------------------------

/// Zeigt Konfetti über seinem Kind, wenn `ausloesen` sich ändert.
///
/// Absichtlich sparsam: Es fliegt, wenn sie **alle** Vokabeln einer Lektion
/// als gewusst markiert hat. Nicht bei jedem Häkchen — sonst bedeutet es
/// nichts mehr.
class Konfetti extends StatefulWidget {
  const Konfetti({super.key, required this.kind, required this.ausloesen});
  final Widget kind;
  final int ausloesen;

  @override
  State<Konfetti> createState() => _KonfettiState();
}

class _KonfettiState extends State<Konfetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );
  final _zufall = math.Random();
  List<_Schnipsel> _teile = const [];

  @override
  void didUpdateWidget(Konfetti alt) {
    super.didUpdateWidget(alt);
    if (widget.ausloesen != alt.ausloesen && widget.ausloesen > 0) {
      _werfen();
    }
  }

  void _werfen() {
    const farben = [
      Color(0xFF1F5F8B), Color(0xFFB5731A), Color(0xFF2F7D54),
      Color(0xFF6B4FA8), Color(0xFFA83B5C), Color(0xFF0F6F6B),
    ];
    _teile = List.generate(46, (_) {
      final winkel = -math.pi / 2 + (_zufall.nextDouble() - .5) * 1.7;
      final kraft = .55 + _zufall.nextDouble() * .75;
      return _Schnipsel(
        vx: math.cos(winkel) * kraft,
        vy: math.sin(winkel) * kraft,
        dreh: (_zufall.nextDouble() - .5) * 9,
        farbe: farben[_zufall.nextInt(farben.length)],
        breite: 5 + _zufall.nextDouble() * 5,
        hoehe: 8 + _zufall.nextDouble() * 7,
        start: _zufall.nextDouble() * .18,
      );
    });
    _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        children: [
          widget.kind,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimationBuilderOhneNeuBau(
                animation: _c,
                maler: (t) => _KonfettiMaler(t: t, teile: _teile),
              ),
            ),
          ),
        ],
      );
}

/// Kleiner Helfer, der nur den Maler neu zeichnet statt den Baum neu zu bauen.
class AnimationBuilderOhneNeuBau extends StatelessWidget {
  const AnimationBuilderOhneNeuBau({
    super.key,
    required this.animation,
    required this.maler,
  });

  final Animation<double> animation;
  final CustomPainter Function(double t) maler;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: animation,
        builder: (context, _) => animation.value == 0
            ? const SizedBox.shrink()
            : CustomPaint(painter: maler(animation.value)),
      );
}

class _Schnipsel {
  _Schnipsel({
    required this.vx,
    required this.vy,
    required this.dreh,
    required this.farbe,
    required this.breite,
    required this.hoehe,
    required this.start,
  });

  final double vx, vy, dreh, breite, hoehe, start;
  final Color farbe;
}

class _KonfettiMaler extends CustomPainter {
  _KonfettiMaler({required this.t, required this.teile});
  final double t;
  final List<_Schnipsel> teile;

  @override
  void paint(Canvas canvas, Size size) {
    final ab = Offset(size.width / 2, size.height * .42);
    for (final s in teile) {
      final tt = ((t - s.start) / (1 - s.start)).clamp(0.0, 1.0);
      if (tt <= 0) continue;
      final weg = tt * 460;
      // Schwerkraft: Sie fliegen hoch und fallen dann.
      final x = ab.dx + s.vx * weg;
      final y = ab.dy + s.vy * weg + 780 * tt * tt * .55;
      final sicht = tt > .72 ? (1 - (tt - .72) / .28) : 1.0;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(s.dreh * tt * 2.6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: s.breite,
            height: s.hoehe,
          ),
          const Radius.circular(1.6),
        ),
        Paint()..color = s.farbe.withValues(alpha: sicht.clamp(0.0, 1.0)),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_KonfettiMaler alt) => alt.t != t;
}

// ---------------------------------------------------------------------------
// Blöcke, die beim Scrollen hereingleiten
// ---------------------------------------------------------------------------

/// Lässt sein Kind einmal sanft einblenden — versetzt nach Position, damit die
/// Seite beim Öffnen nicht auf einen Schlag dasteht.
///
/// Wichtig: Der Ruhezustand ist **sichtbar**. Wenn die Animation ausfällt
/// (oder das System Bewegung reduziert), steht trotzdem alles da.
class Herein extends StatelessWidget {
  const Herein({super.key, required this.kind, this.nr = 0});
  final Widget kind;
  final int nr;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return kind;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + (nr.clamp(0, 8)) * 65),
      curve: Curves.easeOutCubic,
      builder: (context, w, k) => Opacity(
        opacity: w.clamp(0.0, 1.0),
        child: Transform.translate(offset: Offset(0, 14 * (1 - w)), child: k),
      ),
      child: kind,
    );
  }
}

/// Der Strähnen-Zähler oben: eine kleine Flamme, die bei längeren Strähnen
/// stärker leuchtet.
class Straehne extends StatelessWidget {
  const Straehne({super.key, required this.tage});
  final int tage;

  @override
  Widget build(BuildContext context) {
    final gold = Stil.goldFarbe(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      decoration: BoxDecoration(
        color: Stil.blass(context, gold),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tage >= 6 ? '🔥' : '📚', style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          ZaehlZahl(
            tage,
            stil: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: gold,
            ),
          ),
          Text(
            tage == 1 ? ' Tag dabei' : ' Tage dabei',
            style: TextStyle(fontSize: 13.5, color: gold),
          ),
        ],
      ),
    );
  }
}
