/// Kart görselleri (Kilim yönü): kelime kartı, kategori kartı ("as"), kart
/// sırtı, boş slot, atık kenarı.
///
/// Kelime kartları Lora (serif) ile yazılır; kategori adı Manrope (sans),
/// büyük harf. Renk kategori anlamı taşımaz — tüm kategori kartları aynı kilim
/// indigosudur (Spec K7).
library;

import 'package:flutter/material.dart';

import '../../../content/tr_text.dart';
import '../../../engine/cards.dart';
import '../../theme/kilim.dart';
import '../../theme/tokens.dart';

/// Metnin verilen alana (maxLines satırla) sığdığı en büyük punto.
///
/// Not: TextPainter tema fontunu miras almaz; ölçüm ile çizimin uyuşması için
/// font ailesi açıkça verilir ve ölçek kapatılır (kartlar sabit düzen).
final _fitCache = <String, double>{};

double _fitFontSize({
  required String text,
  required double maxW,
  required double maxH,
  required double minFont,
  required double maxFont,
  required int maxLines,
  required FontWeight weight,
  required double height,
  required double letterSpacing,
  required String fontFamily,
}) {
  if (maxW <= 0 || maxH <= 0) return minFont;
  final key =
      '$text|${maxW.toStringAsFixed(1)}|${maxH.toStringAsFixed(1)}'
      '|$maxLines|${weight.value}|$height|$letterSpacing|$fontFamily'
      '|${minFont.toStringAsFixed(1)}|${maxFont.toStringAsFixed(1)}';
  final cached = _fitCache[key];
  if (cached != null) return cached;

  bool fits(double fs) {
    final style = TextStyle(
      fontSize: fs,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      fontFamily: fontFamily,
    );
    // Hiçbir kelime satır genişliğini aşmamalı (kelime ortadan bölünmesin;
    // yalnızca boşluklardan sarılsın). Çizici tam maxW'de sardığı için 1px
    // güvenlik payı bırakırız — aksi halde son harf alt satıra kayıyor.
    for (final word in text.split(RegExp(r'\s+'))) {
      if (word.isEmpty) continue;
      final wp = TextPainter(
        text: TextSpan(text: word, style: style),
        textDirection: TextDirection.ltr,
        textScaler: TextScaler.noScaling,
      )..layout();
      if (wp.width > maxW - 1.0) return false;
    }
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
      textScaler: TextScaler.noScaling,
    )..layout(maxWidth: maxW);
    return !tp.didExceedMaxLines && tp.height <= maxH + 0.5;
  }

  double result;
  if (fits(maxFont)) {
    result = maxFont;
  } else {
    var lo = minFont, hi = maxFont;
    for (var i = 0; i < 9; i++) {
      final mid = (lo + hi) / 2;
      if (fits(mid)) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    result = lo;
  }
  if (_fitCache.length > 400) _fitCache.clear();
  _fitCache[key] = result;
  return result;
}

/// Alanı dolduracak şekilde otomatik ölçeklenen, çok satırlı metin.
class _FitText extends StatelessWidget {
  const _FitText({
    required this.text,
    required this.maxLines,
    required this.minFont,
    required this.maxFont,
    required this.color,
    required this.weight,
    this.height = 1.05,
    this.fontFamily = Fonts.serif,
  });

  final String text;
  final int maxLines;
  final double minFont;
  final double maxFont;
  final Color color;
  final FontWeight weight;
  final double height;
  final String fontFamily;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final fs = _fitFontSize(
          text: text,
          maxW: c.maxWidth,
          maxH: c.maxHeight.isFinite
              ? c.maxHeight
              : maxFont * maxLines * height,
          minFont: minFont,
          maxFont: maxFont,
          maxLines: maxLines,
          weight: weight,
          height: height,
          letterSpacing: 0,
          fontFamily: fontFamily,
        );
        // Ölçüm ile çizim BİREBİR uyuşmalı: font ailesi ve harf aralığı burada
        // da açıkça verilir. Üste hizalı: sütunda üst üste dizilince alttaki
        // kartların yazısı da görünen üst şeritte kalır.
        return Align(
          alignment: Alignment.topLeft,
          child: Text(
            text,
            maxLines: maxLines,
            textAlign: TextAlign.left,
            softWrap: true,
            overflow: TextOverflow.clip,
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              color: color,
              fontFamily: fontFamily,
              fontWeight: weight,
              fontSize: fs,
              height: height,
              letterSpacing: 0,
            ),
          ),
        );
      },
    );
  }
}

/// Ortak kart çerçevesi.
class _CardFrame extends StatelessWidget {
  const _CardFrame({
    required this.size,
    required this.color,
    required this.border,
    required this.child,
    this.elevation = 2,
    this.shadow,
    this.gradient,
    this.highlight,
  });

  final Size size;
  final Color color;
  final Color border;
  final Widget child;
  final double elevation;
  final Color? shadow;
  final Gradient? gradient;

  /// Verilirse: bu renkte belirgin kenarlık + hafif dış parıltı (seçili/ipucu).
  final Color? highlight;

  @override
  Widget build(BuildContext context) {
    final hl = highlight;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: gradient == null ? color : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(Dim.cardRadius),
          border: Border.all(color: hl ?? border, width: hl != null ? 2.5 : 1),
          boxShadow: [
            if (elevation > 0)
              BoxShadow(
                color: shadow ?? const Color(0x22000000),
                blurRadius: elevation * 2.2,
                offset: Offset(0, elevation),
              ),
            if (hl != null)
              BoxShadow(
                color: hl.withValues(alpha: 0.35),
                blurRadius: 14,
                spreadRadius: 0.5,
              ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class WordCardView extends StatelessWidget {
  const WordCardView({
    super.key,
    required this.card,
    required this.size,
    required this.colors,
    this.raised = false,
    this.highlight = false,
  });

  final WordCard card;
  final Size size;
  final GameColors colors;
  final bool raised;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final padH = size.width * 0.10;
    final padV = size.height * 0.08;
    return _CardFrame(
      size: size,
      color: colors.cardFace,
      border: colors.cardEdge,
      elevation: raised ? 10 : 2,
      shadow: colors.shadow,
      highlight: highlight ? colors.accent : null,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
        // Lora (serif). Çok satır kullanır; sadece gerçekten sığmazsa küçülür
        // (Spec K7). minFont düşük: 10+ harfli tek kelimeler ("Bağışıklık")
        // kırpılmadan sığsın.
        child: _FitText(
          text: TrText.capitalize(card.word),
          maxLines: 3,
          minFont: size.height * 0.085,
          maxFont: size.height * 0.28,
          color: colors.cardText,
          weight: FontWeight.w600,
          height: 1.08,
          fontFamily: Fonts.serif,
        ),
      ),
    );
  }
}

class CategoryCardView extends StatelessWidget {
  const CategoryCardView({
    super.key,
    required this.card,
    required this.size,
    required this.colors,
    this.collected,
    this.locked = false,
    this.raised = false,
    this.highlight = false,
  });

  final CategoryCard card;
  final Size size;
  final GameColors colors;

  /// null → yığın modu ("6"); değer → slot modu ("2/6").
  final int? collected;
  final bool locked;
  final bool raised;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final counterText = collected == null
        ? '${card.totalInLevel}'
        : '$collected/${card.totalInLevel}';
    // Sayaç pili: ilerleme varsa terrakotta, yoksa soluk indigo çip.
    final progressed = collected != null && collected! > 0;
    final pillBg = progressed
        ? colors.accent
        : colors.categoryText.withValues(alpha: 0.16);
    final pillText = progressed ? colors.onAccent : colors.categoryText;
    final pad = size.width * 0.10;
    // Kategori kartı: hafif dikey gradyan (üstte biraz açık) — dokuma his.
    final faceTop = Color.lerp(colors.categoryFace, colors.categoryText, 0.07)!;
    return _CardFrame(
      size: size,
      color: colors.categoryFace,
      border: colors.categoryFace,
      elevation: raised ? 11 : 3,
      shadow: colors.shadow,
      highlight: highlight ? colors.accent : null,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [faceTop, colors.categoryFace],
      ),
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                KilimDiamond(size: size.height * 0.13, color: colors.gold),
                if (locked) ...[
                  const Spacer(),
                  Icon(
                    Icons.lock_rounded,
                    size: size.height * 0.14,
                    color: colors.categoryText.withValues(alpha: 0.75),
                  ),
                ],
              ],
            ),
            const Spacer(),
            // Kategori adı Manrope (sans), büyük harf. Serbestçe satıra sarılır;
            // FittedBox tüm bloğu kutuya sığdırır (asla kırpma).
            SizedBox(
              width: double.infinity,
              height: size.height * 0.34,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: size.width * 1.5),
                  child: Text(
                    TrText.upper(card.name),
                    textScaler: TextScaler.noScaling,
                    style: TextStyle(
                      color: colors.categoryText,
                      fontFamily: Fonts.sans,
                      fontWeight: FontWeight.w800,
                      fontSize: size.height * 0.135,
                      height: 1.05,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.035),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.10,
                vertical: size.height * 0.022,
              ),
              decoration: BoxDecoration(
                color: pillBg,
                borderRadius: BorderRadius.circular(Dim.pill),
              ),
              child: Text(
                counterText,
                style: TextStyle(
                  color: pillText,
                  fontFamily: Fonts.sans,
                  fontWeight: FontWeight.w800,
                  fontSize: size.height * 0.12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardBackView extends StatelessWidget {
  const CardBackView({super.key, required this.size, required this.colors});
  final Size size;
  final GameColors colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dim.cardRadius),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 3,
            offset: const Offset(0, 1.5),
          ),
        ],
        border: Border.all(
          color: colors.onAccent.withValues(alpha: 0.85),
          width: 2,
        ),
      ),
      child: KilimCardBack(size: size, colors: colors),
    );
  }
}

/// Atık yelpazesinde arkada kalan bir kartın ince dikey kenarı.
///
/// Yalnızca sol kenar görünür; etiket 90° döndürülüp bu dar şeride yazılır.
/// Son birkaç açılan kartı hatırlatmak içindir (etkileşimsiz).
class WasteEdgeView extends StatelessWidget {
  const WasteEdgeView({
    super.key,
    required this.card,
    required this.width,
    required this.height,
    required this.colors,
  });

  final GameCard card;
  final double width;
  final double height;
  final GameColors colors;

  @override
  Widget build(BuildContext context) {
    final isCategory = card is CategoryCard;
    final face = isCategory ? colors.categoryFace : colors.cardFace;
    final textColor = isCategory ? colors.categoryText : colors.cardText;
    final label = isCategory
        ? TrText.upper((card as CategoryCard).name)
        : TrText.capitalize((card as WordCard).word);
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: face,
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(Dim.cardRadius),
          ),
          border: Border(
            left: BorderSide(color: colors.cardEdge),
            top: BorderSide(color: colors.cardEdge),
            bottom: BorderSide(color: colors.cardEdge),
          ),
        ),
        child: ClipRect(
          child: RotatedBox(
            quarterTurns: 3,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: height * 0.08),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.92),
                    fontFamily: isCategory ? Fonts.sans : Fonts.serif,
                    fontWeight: isCategory ? FontWeight.w700 : FontWeight.w600,
                    fontSize: width * 0.5,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Boş yer (slot veya sütun) çerçevesi — kesikli kilim çerçevesi.
class EmptyFrameView extends StatelessWidget {
  const EmptyFrameView({
    super.key,
    required this.size,
    required this.colors,
    this.icon,
    this.label,
  });
  final Size size;
  final GameColors colors;
  final IconData? icon;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: CustomPaint(
        painter: DashedRRectPainter(
          color: colors.slotEmpty.withValues(alpha: 0.8),
          radius: Dim.cardRadius,
        ),
        child: icon == null && label == null
            ? null
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null)
                      Icon(
                        icon,
                        color: colors.slotEmpty,
                        size: size.height * 0.22,
                      ),
                    if (label != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          label!,
                          style: TextStyle(
                            color: colors.inkSoft.withValues(alpha: 0.7),
                            fontSize: size.height * 0.11,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
