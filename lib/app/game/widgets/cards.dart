/// Kart görselleri: kelime kartı, kategori kartı, kart sırtı, boş slot.
library;

import 'package:flutter/material.dart';

import '../../../content/tr_text.dart';
import '../../../engine/cards.dart';
import '../../theme/tokens.dart';

/// Ortak kart çerçevesi.
class _CardFrame extends StatelessWidget {
  const _CardFrame({
    required this.size,
    required this.color,
    required this.border,
    required this.child,
    this.elevation = 2,
    this.shadow,
  });

  final Size size;
  final Color color;
  final Color border;
  final Widget child;
  final double elevation;
  final Color? shadow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(Dim.cardRadius),
          border: Border.all(color: border, width: 1),
          boxShadow: elevation > 0
              ? [
                  BoxShadow(
                    color: shadow ?? const Color(0x22000000),
                    blurRadius: elevation * 2,
                    offset: Offset(0, elevation),
                  ),
                ]
              : null,
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
  });

  final WordCard card;
  final Size size;
  final GameColors colors;
  final bool raised;

  @override
  Widget build(BuildContext context) {
    final pad = size.width * 0.09;
    return _CardFrame(
      size: size,
      color: colors.cardFace,
      border: colors.cardEdge,
      elevation: raised ? 8 : 2,
      shadow: colors.shadow,
      child: Padding(
        padding: EdgeInsets.fromLTRB(pad, pad * 0.7, pad, pad * 0.7),
        child: Align(
          alignment: Alignment.topLeft,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: size.width * 2),
              child: Text(
                TrText.capitalize(card.word),
                maxLines: 2,
                style: TextStyle(
                  color: colors.cardText,
                  fontWeight: FontWeight.w700,
                  fontSize: size.height * 0.19,
                  height: 1.05,
                ),
              ),
            ),
          ),
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
  });

  final CategoryCard card;
  final Size size;
  final GameColors colors;

  /// null → yığın modu ("6"); değer → slot modu ("2/6").
  final int? collected;
  final bool locked;
  final bool raised;

  @override
  Widget build(BuildContext context) {
    final counterText = collected == null
        ? '${card.totalInLevel}'
        : '$collected/${card.totalInLevel}';
    final pad = size.width * 0.09;
    return _CardFrame(
      size: size,
      color: colors.categoryFace,
      border: colors.categoryFace,
      elevation: raised ? 9 : 3,
      shadow: colors.shadow,
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.folder_special_rounded,
                  size: size.height * 0.16,
                  color: colors.accent,
                ),
                if (locked) ...[
                  const Spacer(),
                  Icon(
                    Icons.lock_rounded,
                    size: size.height * 0.15,
                    color: colors.categoryText.withValues(alpha: 0.7),
                  ),
                ],
              ],
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                TrText.upper(card.name),
                style: TextStyle(
                  color: colors.categoryText,
                  fontWeight: FontWeight.w800,
                  fontSize: size.height * 0.13,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            SizedBox(height: size.height * 0.03),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.09,
                vertical: size.height * 0.02,
              ),
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                counterText,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: size.height * 0.13,
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
    return _CardFrame(
      size: size,
      color: colors.accent,
      border: colors.cardEdge,
      elevation: 1,
      shadow: colors.shadow,
      child: Center(
        child: Container(
          width: size.width * 0.58,
          height: size.height * 0.58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Transform.rotate(
              angle: 0.785398, // 45°
              child: Container(
                width: size.width * 0.22,
                height: size.width * 0.22,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.30),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Boş yer (slot veya sütun) çerçevesi.
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
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.slotEmpty.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(Dim.cardRadius),
          border: Border.all(
            color: colors.inkSoft.withValues(alpha: 0.35),
            width: 1.2,
          ),
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
                        color: colors.inkSoft.withValues(alpha: 0.6),
                        size: size.height * 0.24,
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
