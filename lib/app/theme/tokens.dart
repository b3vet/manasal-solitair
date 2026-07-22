/// Tasarım token'ları: "Kilim" yönü — çağdaş Anadolu. Renkler, ölçüler, süreler.
///
/// Palet felsefesi (tasarım): toprak kızılı (accent) tek canlı vurgu; kilim
/// indigosu (categoryFace) YALNIZCA kategori kartı ve marka yüzeylerinde;
/// elma-altını (gold) nişan/yıldız rengi. Renk HİÇBİR yerde kategori anlamı
/// taşımaz (kelime kartlarında kategori işareti yok — Spec K7).
///
/// Tipografi: Lora (serif) = kelimeler + başlıklar; Manrope (sans) = arayüz.
library;

import 'package:flutter/material.dart';

/// Font aileleri — tek yerden.
class Fonts {
  const Fonts._();

  /// Serif — kelime kartları ve ekran başlıkları.
  static const serif = 'Lora';

  /// Sans — tüm arayüz metni (buton, etiket, sayaç, kategori adı, gövde).
  static const sans = 'Manrope';
}

/// Oyuna özgü renkler — ThemeExtension olarak taşınır.
@immutable
class GameColors extends ThemeExtension<GameColors> {
  const GameColors({
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.ink,
    required this.inkSoft,
    required this.accent,
    required this.accentDeep,
    required this.accentSoft,
    required this.onAccent,
    required this.gold,
    required this.cardFace,
    required this.cardEdge,
    required this.cardText,
    required this.categoryFace,
    required this.categoryText,
    required this.slotEmpty,
    required this.danger,
    required this.warning,
    required this.shadow,
  });

  /// Uygulama zemini (sıcak kâğıt / sıcak koyu kahve).
  final Color bg;

  /// Kart, panel, buton yüzeyi (kremimsi beyaz / koyu kahve).
  final Color surface;

  /// İkincil yüzey — kutucuk, alt panel, hafif yükselti.
  final Color surfaceAlt;

  /// Birincil metin (koyu kahve mürekkep / krem).
  final Color ink;

  /// İkincil metin (soluk taupe).
  final Color inkSoft;

  /// Toprak kızılı — tek canlı vurgu (dolgu buton, aktif, sayaç, ipucu).
  final Color accent;

  /// Daha koyu terrakotta — basılı/gradyan alt tonu, vurgu kenarı.
  final Color accentDeep;

  /// Terrakotta doku zemini (çip/kutucuk arka planı).
  final Color accentSoft;

  /// accent dolgu üzerindeki metin/ikon (açık temada krem, koyuda koyu kahve).
  final Color onAccent;

  /// Elma-altını — kilim elması, yıldız, nişan rozetleri.
  final Color gold;

  /// Kelime kartı yüzü.
  final Color cardFace;

  /// Kart kenarlığı / ayraç.
  final Color cardEdge;

  /// Kelime kartı metni.
  final Color cardText;

  /// Kategori kartı ("as") yüzü — kilim indigosu.
  final Color categoryFace;

  /// Kategori kartı metni (indigo üzerinde krem).
  final Color categoryText;

  /// Boş slot / boş sütun kesikli çerçeve rengi.
  final Color slotEmpty;

  /// Tehlike (kritik az hamle).
  final Color danger;

  /// Uyarı (hamle azalıyor).
  final Color warning;

  /// Gölge rengi.
  final Color shadow;

  static const light = GameColors(
    bg: Color(0xFFF4E9D7),
    surface: Color(0xFFFFFCF3),
    surfaceAlt: Color(0xFFFBF3E3),
    ink: Color(0xFF342519),
    inkSoft: Color(0xFF93806A),
    accent: Color(0xFFB14E24),
    accentDeep: Color(0xFF8F3E1B),
    accentSoft: Color(0xFFF2DCC9),
    onAccent: Color(0xFFFFF8EC),
    gold: Color(0xFFC79A3D),
    cardFace: Color(0xFFFFFCF3),
    cardEdge: Color(0xFFE0D0B2),
    cardText: Color(0xFF342519),
    categoryFace: Color(0xFF2E3854),
    categoryText: Color(0xFFFBF3E3),
    slotEmpty: Color(0xFFC0AC8A),
    danger: Color(0xFF9C2F2B),
    warning: Color(0xFFC0632B),
    shadow: Color(0x1F2A1B0E),
  );

  static const dark = GameColors(
    bg: Color(0xFF1A120D),
    surface: Color(0xFF2C211A),
    surfaceAlt: Color(0xFF241A13),
    ink: Color(0xFFF0E9D8),
    inkSoft: Color(0xFFA8917A),
    accent: Color(0xFFDD7E4B),
    accentDeep: Color(0xFFB14E24),
    accentSoft: Color(0xFF3B2314),
    onAccent: Color(0xFF241206),
    gold: Color(0xFFC79A3D),
    cardFace: Color(0xFF2C211A),
    cardEdge: Color(0xFF433C2E),
    cardText: Color(0xFFF0E9D8),
    categoryFace: Color(0xFF39466B),
    categoryText: Color(0xFFF0E9D8),
    slotEmpty: Color(0xFF55412E),
    danger: Color(0xFFE06452),
    warning: Color(0xFFE0B34C),
    shadow: Color(0x59000000),
  );

  @override
  GameColors copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceAlt,
    Color? ink,
    Color? inkSoft,
    Color? accent,
    Color? accentDeep,
    Color? accentSoft,
    Color? onAccent,
    Color? gold,
    Color? cardFace,
    Color? cardEdge,
    Color? cardText,
    Color? categoryFace,
    Color? categoryText,
    Color? slotEmpty,
    Color? danger,
    Color? warning,
    Color? shadow,
  }) => GameColors(
    bg: bg ?? this.bg,
    surface: surface ?? this.surface,
    surfaceAlt: surfaceAlt ?? this.surfaceAlt,
    ink: ink ?? this.ink,
    inkSoft: inkSoft ?? this.inkSoft,
    accent: accent ?? this.accent,
    accentDeep: accentDeep ?? this.accentDeep,
    accentSoft: accentSoft ?? this.accentSoft,
    onAccent: onAccent ?? this.onAccent,
    gold: gold ?? this.gold,
    cardFace: cardFace ?? this.cardFace,
    cardEdge: cardEdge ?? this.cardEdge,
    cardText: cardText ?? this.cardText,
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
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentDeep: Color.lerp(accentDeep, other.accentDeep, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      cardFace: Color.lerp(cardFace, other.cardFace, t)!,
      cardEdge: Color.lerp(cardEdge, other.cardEdge, t)!,
      cardText: Color.lerp(cardText, other.cardText, t)!,
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
  static const double cardRadius = 13;
  static const double panelRadius = 20; // panel, kutucuk, diyalog
  static const double pill = 999; // hap biçim (buton, çip, sayaç)
  static const double gap = 8;
  static const double pagePad = 12;
  // Tahta, dikey oranlı sabit bir alandır; geniş/yatay ekranlarda büyümez,
  // ekranda ortalanır (kenarlar arka planla dolar). Genişlik hem mutlak üst
  // sınırla (telefon genişliği) hem de dikey oranla kısılır.
  static const double maxBoardWidth =
      460; // px — en büyük telefondan biraz geniş
  static const double maxBoardAspect = 0.60; // genişlik / yükseklik
  // Kolon içi bindirme oranları (kart yüksekliğine göre).
  // Açık kartlar okunacak kadar açılır (üstteki yazı görünür); kapalı kartlar
  // sıkı durur.
  static const double overlapFaceUp = 0.40;
  static const double overlapFaceDown = 0.14;
  static const double overlapTight = 0.20; // taşma sıkıştırması
}

/// Animasyon süreleri (tek yerden — tuning). (Spec §13.3)
class Anim {
  const Anim._();
  static const draw = Duration(milliseconds: 240);
  static const flip = Duration(milliseconds: 280);
  static const place = Duration(milliseconds: 260);
  static const invalid = Duration(milliseconds: 340);
  static const sweep = Duration(milliseconds: 460);
  static const complete = Duration(milliseconds: 820);
  static const deal = Duration(milliseconds: 1100);
  static const counter = Duration(milliseconds: 220);
}
