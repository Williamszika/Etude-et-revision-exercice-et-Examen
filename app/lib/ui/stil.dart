import 'package:flutter/material.dart';

/// Die Farben und Formen von Deutsch täglich.
///
/// Übernommen aus `deutsch-taeglich/_template.html`, damit die App und die
/// Webseite sich nicht wie zwei verschiedene Sachen anfühlen: warmes Papier,
/// tiefes Blau als Akzent, und **pro Block eine eigene Farbe**, an der sie den
/// Block wiedererkennt, ohne die Überschrift zu lesen.
class Stil {
  const Stil._();

  // helles Thema
  static const papier = Color(0xFFF5F3EE);
  static const papier2 = Color(0xFFEDEAE2);
  static const karte = Color(0xFFFFFDF9);
  static const tinte = Color(0xFF1C211F);
  static const tinteWeich = Color(0xFF4C5552);
  static const linie = Color(0xFFDCD7CC);
  static const akzent = Color(0xFF1F5F8B);
  static const akzentTief = Color(0xFF164866);
  static const akzentWeich = Color(0xFFDCE9F2);
  static const gold = Color(0xFFB5731A);
  static const gut = Color(0xFF2F7D54);

  // dunkles Thema
  static const dPapier = Color(0xFF121618);
  static const dPapier2 = Color(0xFF0D1113);
  static const dKarte = Color(0xFF1A2023);
  static const dTinte = Color(0xFFEEF2F2);
  static const dTinteWeich = Color(0xFFA4B0B2);
  static const dLinie = Color(0xFF2A3336);
  static const dAkzent = Color(0xFF6CB2DD);
  static const dAkzentWeich = Color(0xFF14293A);
  static const dGold = Color(0xFFD9A559);
  static const dGut = Color(0xFF6FC292);

  /// Blockfarben — hell und dunkel. Die Namen sind die Blocknamen im JSON.
  static const _blockHell = <String, Color>{
    'verb': Color(0xFF1F5F8B),
    'wortschatz': Color(0xFF8A5A2B),
    'vokabeln': Color(0xFF8A5A2B),
    'grammatik': Color(0xFF5C4A8A),
    'deklination': Color(0xFF4A3F8A),
    'lesen': Color(0xFF7A5A1E),
    'leben': Color(0xFF0D6B8A),
    'training': Color(0xFFA35A12),
    'telc': Color(0xFFBB4D3F),
    'probe': Color(0xFFA83B5C),
    'aussprache': Color(0xFF2F7D54),
    'diktat': Color(0xFF6B4FA8),
    'uebersetzung': Color(0xFFA83B5C),
  };
  static const _blockDunkel = <String, Color>{
    'verb': Color(0xFF6CB2DD),
    'wortschatz': Color(0xFFD9A05B),
    'vokabeln': Color(0xFFD9A05B),
    'grammatik': Color(0xFFA99AE0),
    'deklination': Color(0xFFA49AE0),
    'lesen': Color(0xFFD8B26A),
    'leben': Color(0xFF5CB8D8),
    'training': Color(0xFFE0A565),
    'telc': Color(0xFFE08A7C),
    'probe': Color(0xFFE08AA0),
    'aussprache': Color(0xFF6FC292),
    'diktat': Color(0xFFB39CE8),
    'uebersetzung': Color(0xFFE08AA0),
  };

  static Color blockFarbe(BuildContext c, String block) {
    final dunkel = Theme.of(c).brightness == Brightness.dark;
    return (dunkel ? _blockDunkel : _blockHell)[block] ??
        (dunkel ? dAkzent : akzent);
  }

  static ThemeData thema(Brightness helligkeit) {
    final dunkel = helligkeit == Brightness.dark;
    final grund = dunkel ? dPapier : papier;
    final vorne = dunkel ? dTinte : tinte;
    final ak = dunkel ? dAkzent : akzent;

    final basis = ThemeData(
      useMaterial3: true,
      brightness: helligkeit,
      colorScheme: ColorScheme.fromSeed(
        seedColor: akzent,
        brightness: helligkeit,
      ).copyWith(surface: grund, primary: ak),
      scaffoldBackgroundColor: grund,
    );

    return basis.copyWith(
      textTheme: basis.textTheme.apply(
        bodyColor: vorne,
        displayColor: vorne,
      ),
      dividerColor: dunkel ? dLinie : linie,
      cardTheme: CardThemeData(
        color: dunkel ? dKarte : karte,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: dunkel ? dLinie : linie),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dunkel ? dKarte : karte,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: dunkel ? dLinie : linie),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: dunkel ? dLinie : linie),
        ),
      ),
    );
  }

  static Color weich(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? dTinteWeich : tinteWeich;
  static Color kartenGrund(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? dKarte : karte;
  static Color linienFarbe(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? dLinie : linie;
  static Color papierZwei(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? dPapier2 : papier2;
  static Color akzentFarbe(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? dAkzent : akzent;
  static Color goldFarbe(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? dGold : gold;
  static Color gutFarbe(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? dGut : gut;

  /// Eine Farbe sehr blass, als Hintergrund hinter Text derselben Familie.
  static Color blass(BuildContext c, Color f) =>
      f.withValues(alpha: Theme.of(c).brightness == Brightness.dark ? .16 : .12);
}

/// Text mit `**fett**` aus dem JSON in echte Fettschrift verwandeln.
///
/// Die Lektionen sind mit Markdown-Sternchen geschrieben, weil die Webseite
/// das so rendert. Ohne diesen Schritt stünden hier überall Sternchen.
///
/// **Warum die Farbe hier so umständlich hergeleitet wird.** Am 16.09.2026 war
/// auf ihrem iPhone der halbe Lektionstext unlesbar — weiß auf hellem Papier.
/// Der Grund: `RichText` erbt **nicht** vom `DefaultTextStyle`, und ein
/// `TextSpan` ohne `color` wird von der Engine **weiß** gezeichnet. Überall, wo
/// ein Aufrufer ein eigenes `stil` mitgab (`const TextStyle(fontSize: 14.5)`),
/// fiel damit die Farbe weg. Deshalb wird der übergebene Stil jetzt **auf** den
/// Standardstil gelegt statt ihn zu ersetzen, und am Ende ist eine Farbe
/// garantiert. Ein Aufrufer, der bewusst eine Farbe setzt, gewinnt weiterhin.
class MarkText extends StatelessWidget {
  const MarkText(this.text, {super.key, this.stil, this.ausrichtung});

  final String text;
  final TextStyle? stil;
  final TextAlign? ausrichtung;

  @override
  Widget build(BuildContext context) {
    var grund = DefaultTextStyle.of(context).style.merge(stil);
    if (grund.color == null && grund.foreground == null) {
      grund = grund.copyWith(
        color: Theme.of(context).textTheme.bodyMedium?.color ??
            (Theme.of(context).brightness == Brightness.dark ? dTinte : tinte),
      );
    }
    return RichText(
      textAlign: ausrichtung ?? TextAlign.start,
      text: TextSpan(style: grund, children: teile(text, grund)),
    );
  }

  static List<InlineSpan> teile(String text, TextStyle grund) {
    final raus = <InlineSpan>[];
    final muster = RegExp(r'\*\*(.+?)\*\*', dotAll: true);
    var pos = 0;
    for (final t in muster.allMatches(text)) {
      if (t.start > pos) {
        raus.add(TextSpan(text: text.substring(pos, t.start)));
      }
      raus.add(TextSpan(
        text: t.group(1),
        style: grund.merge(const TextStyle(fontWeight: FontWeight.w700)),
      ));
      pos = t.end;
    }
    if (pos < text.length) raus.add(TextSpan(text: text.substring(pos)));
    return raus;
  }
}
