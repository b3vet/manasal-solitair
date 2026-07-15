/// Tasarım token'ları: kağıt/kitap teması renkleri, ölçüler, süreler.
///
/// Renge dayalı kategori ayrımı YOKTUR (kelime kartlarında kategori işareti
/// yok — Spec K7). Renkler yalnızca yüzey/mürekkep/vurgu içindir.
library;

import 'package:flutter/material.dart';

/// Oyuna özgü renkler — ThemeExtension olarak taşınır.
@immutable
class GameColors extends ThemeExtension<GameColors> {
  const GameColors({
    required this.bg,
    required this.surface,
    required this.cardFace,
    required this.cardEdge,
    required this.cardText,
    required this.ink,
    required this.inkSoft,
    required this.accent,
    required this.accentSoft,
    required this.categoryFace,
    required this.categoryText,
    required this.slotEmpty,
    required this.danger,
    required this.warning,
    required this.shadow,
  });

  final Color bg;
  final Color surface;
  final Color cardFace;
  final Color cardEdge;
  final Color cardText;
  final Color ink;
  final Color inkSoft;
  final Color accent;
  final Color accentSoft;
  final Color categoryFace;
  final Color categoryText;
  final Color slotEmpty;
  final Color danger;
  final Color warning;
  final Color shadow;

  static const light = GameColors(
    bg: Color(0xFFF7F1E4),
    surface: Color(0xFFFFFDF7),
    cardFace: Color(0xFFFFFDF6),
    cardEdge: Color(0xFFE4DAC5),
    cardText: Color(0xFF2A2620),
    ink: Color(0xFF2A2620),
    inkSoft: Color(0xFF6A6153),
    accent: Color(0xFF0E7A6D),
    accentSoft: Color(0xFFDDEEEA),
    categoryFace: Color(0xFF243027),
    categoryText: Color(0xFFF4ECD9),
    slotEmpty: Color(0xFFE9E0CE),
    danger: Color(0xFFB3261E),
    warning: Color(0xFFB9791C),
    shadow: Color(0x33000000),
  );

  static const dark = GameColors(
    bg: Color(0xFF16130E),
    surface: Color(0xFF221E17),
    cardFace: Color(0xFF2A251C),
    cardEdge: Color(0xFF433C2E),
    cardText: Color(0xFFEDE7DA),
    ink: Color(0xFFEDE7DA),
    inkSoft: Color(0xFFB3A991),
    accent: Color(0xFF4FC2B2),
    accentSoft: Color(0xFF11302B),
    categoryFace: Color(0xFF0E1613),
    categoryText: Color(0xFFDCE9DF),
    slotEmpty: Color(0xFF2E2921),
    danger: Color(0xFFEF8A84),
    warning: Color(0xFFE0B34C),
    shadow: Color(0x55000000),
  );

  @override
  GameColors copyWith({
    Color? bg,
    Color? surface,
    Color? cardFace,
    Color? cardEdge,
    Color? cardText,
    Color? ink,
    Color? inkSoft,
    Color? accent,
    Color? accentSoft,
    Color? categoryFace,
    Color? categoryText,
    Color? slotEmpty,
    Color? danger,
    Color? warning,
    Color? shadow,
  }) =>
      GameColors(
        bg: bg ?? this.bg,
        surface: surface ?? this.surface,
        cardFace: cardFace ?? this.cardFace,
        cardEdge: cardEdge ?? this.cardEdge,
        cardText: cardText ?? this.cardText,
        ink: ink ?? this.ink,
        inkSoft: inkSoft ?? this.inkSoft,
        accent: accent ?? this.accent,
        accentSoft: accentSoft ?? this.accentSoft,
        categoryFace: categoryFace ?? this.categoryFace,
        categoryText: categoryText ?? this.categoryText,
        slotEmpty: slotEmpty ?? this.slotEmpty,
        danger: danger ?? this.danger,
        warning: warning ?? this.warning,
        shadow: shadow ?? this.shadow,
      );

  @override
  GameColors lerp(GameColors? other, double t) {
    if (other == null) return this;
    return GameColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      cardFace: Color.lerp(cardFace, other.cardFace, t)!,
      cardEdge: Color.lerp(cardEdge, other.cardEdge, t)!,
      cardText: Color.lerp(cardText, other.cardText, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      categoryFace: Color.lerp(categoryFace, other.categoryFace, t)!,
      categoryText: Color.lerp(categoryText, other.categoryText, t)!,
      slotEmpty: Color.lerp(slotEmpty, other.slotEmpty, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

/// Ölçü ve biçim sabitleri.
class Dim {
  const Dim._();
  static const double cardAspect = 0.72; // genişlik / yükseklik
  static const double cardRadius = 10;
  static const double gap = 8;
  static const double pagePad = 12;
  // Kolon içi bindirme oranları (kart yüksekliğine göre).
  static const double overlapFaceUp = 0.32;
  static const double overlapFaceDown = 0.14;
  static const double overlapTight = 0.20; // taşma sıkıştırması
}

/// Animasyon süreleri (tek yerden — tuning). (Spec §13.3)
class Durations {
  const Durations._();
  static const draw = Duration(milliseconds: 240);
  static const flip = Duration(milliseconds: 280);
  static const place = Duration(milliseconds: 260);
  static const invalid = Duration(milliseconds: 340);
  static const sweep = Duration(milliseconds: 460);
  static const complete = Duration(milliseconds: 820);
  static const deal = Duration(milliseconds: 1100);
  static const counter = Duration(milliseconds: 220);
}
