/// Kazanma / kayıp / duraklat diyalogları — Kilim yönü.
///
/// Alttan çıkan sheet: üst kenarda kilim bordürü, Lora başlık, istatistik
/// kutucukları, terrakotta birincil buton.
library;

import 'package:flutter/material.dart';

import '../../../engine/engine.dart';
import '../../theme/app_theme.dart';
import '../../theme/kilim.dart';
import '../../theme/tokens.dart';

enum GameDialogAction { next, retry, levels, undoContinue, resume }

Future<T?> _sheet<T>(
  BuildContext context, {
  required Widget child,
  bool dismissible = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isDismissible: dismissible,
    enableDrag: dismissible,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _Sheet(child: child),
  );
}

Future<GameDialogAction?> showWinDialog(
  BuildContext context, {
  required int movesLeft,
  required int creditsAwarded,
  required bool hasNext,
  int levelId = 0,
}) {
  final colors = context.colors;
  return _sheet<GameDialogAction>(
    context,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Stars(colors: colors),
        const SizedBox(height: 14),
        _Title('Tebrikler!', colors),
        const SizedBox(height: 4),
        _Subtitle(
          levelId > 0 ? 'Bölüm $levelId tamamlandı' : 'Bölüm tamamlandı',
          colors,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                value: '$movesLeft',
                label: 'KALAN HAMLE',
                bg: colors.surfaceAlt,
                valueColor: colors.ink,
                colors: colors,
              ),
            ),
            if (creditsAwarded > 0) ...[
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  value: '+$creditsAwarded',
                  label: 'KREDİ',
                  bg: colors.accentSoft,
                  valueColor: colors.accent,
                  colors: colors,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        if (hasNext)
          _PrimaryButton(
            label: 'Sıradaki Bölüm',
            colors: colors,
            onTap: () => Navigator.pop(context, GameDialogAction.next),
          ),
        _SecondaryButton(
          label: 'Yeniden Başla',
          colors: colors,
          onTap: () => Navigator.pop(context, GameDialogAction.retry),
        ),
        _LinkButton(
          label: 'Bölümler',
          colors: colors,
          onTap: () => Navigator.pop(context, GameDialogAction.levels),
        ),
      ],
    ),
  );
}

Future<GameDialogAction?> showLoseDialog(
  BuildContext context, {
  required GameStatus status,
  required bool canUndoContinue,
  int movesLeft = 0,
}) {
  final colors = context.colors;
  final reason = status == GameStatus.lostOutOfMoves
      ? 'Hamlen bitti'
      : 'Oynanacak hamle kalmadı';
  return _sheet<GameDialogAction>(
    context,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _BigNumber('$movesLeft', 'HAMLE', colors),
        const SizedBox(height: 12),
        _Title('Bölüm Başarısız', colors),
        const SizedBox(height: 4),
        _Subtitle(reason, colors),
        const SizedBox(height: 20),
        if (canUndoContinue)
          _PrimaryButton(
            label: 'Geri Al ve Devam Et  ·  1 kredi',
            colors: colors,
            onTap: () => Navigator.pop(context, GameDialogAction.undoContinue),
          ),
        _SecondaryButton(
          label: 'Yeniden Başla',
          colors: colors,
          onTap: () => Navigator.pop(context, GameDialogAction.retry),
        ),
        _LinkButton(
          label: 'Bölümler',
          colors: colors,
          onTap: () => Navigator.pop(context, GameDialogAction.levels),
        ),
      ],
    ),
  );
}

Future<GameDialogAction?> showPauseDialog(
  BuildContext context, {
  int levelId = 0,
  int movesLeft = 0,
  int completed = 0,
  int totalCategories = 0,
}) {
  final colors = context.colors;
  final parts = <String>[
    if (levelId > 0) 'Bölüm $levelId',
    '$movesLeft hamle kaldı',
    '$completed/$totalCategories kategori',
  ];
  return _sheet<GameDialogAction>(
    context,
    dismissible: true,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.pause_rounded, size: 40, color: colors.accent),
        const SizedBox(height: 10),
        _Title('Duraklatıldı', colors),
        const SizedBox(height: 4),
        _Subtitle(parts.join('  ·  '), colors),
        const SizedBox(height: 20),
        _PrimaryButton(
          label: 'Devam Et',
          colors: colors,
          onTap: () => Navigator.pop(context, GameDialogAction.resume),
        ),
        _SecondaryButton(
          label: 'Yeniden Başla',
          colors: colors,
          onTap: () => Navigator.pop(context, GameDialogAction.retry),
        ),
        _LinkButton(
          label: 'Bölümler',
          colors: colors,
          onTap: () => Navigator.pop(context, GameDialogAction.levels),
        ),
      ],
    ),
  );
}

/// Alttan çıkan sheet gövdesi: yuvarlak üst köşeler + üst kenarda kilim bandı.
class _Sheet extends StatelessWidget {
  const _Sheet({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(Dim.panelRadius + 4),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            KilimBand(colors: colors, height: 11),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 14),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.colors});
  final GameColors colors;

  @override
  Widget build(BuildContext context) {
    Widget star(double s) =>
        Icon(Icons.star_rounded, color: colors.gold, size: s);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        star(30),
        const SizedBox(width: 6),
        star(42),
        const SizedBox(width: 6),
        star(30),
      ],
    );
  }
}

class _BigNumber extends StatelessWidget {
  const _BigNumber(this.value, this.label, this.colors);
  final String value;
  final String label;
  final GameColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: colors.danger,
            fontFamily: Fonts.sans,
            fontWeight: FontWeight.w800,
            fontSize: 40,
            height: 1,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: colors.inkSoft,
            fontFamily: Fonts.sans,
            fontSize: 11,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text, this.colors);
  final String text;
  final GameColors colors;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: colors.ink,
      fontFamily: Fonts.serif,
      fontSize: 28,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _Subtitle extends StatelessWidget {
  const _Subtitle(this.text, this.colors);
  final String text;
  final GameColors colors;

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(color: colors.inkSoft, fontSize: 14),
  );
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.bg,
    required this.valueColor,
    required this.colors,
  });
  final String value;
  final String label;
  final Color bg;
  final Color valueColor;
  final GameColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontFamily: Fonts.sans,
              fontWeight: FontWeight.w800,
              fontSize: 26,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: colors.inkSoft,
              fontFamily: Fonts.sans,
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.colors,
    required this.onTap,
  });
  final String label;
  final GameColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: colors.accent,
          borderRadius: BorderRadius.circular(Dim.pill),
          child: InkWell(
            borderRadius: BorderRadius.circular(Dim.pill),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onAccent,
                  fontWeight: FontWeight.w800,
                  fontSize: 15.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.colors,
    required this.onTap,
  });
  final String label;
  final GameColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(Dim.pill),
          child: InkWell(
            borderRadius: BorderRadius.circular(Dim.pill),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dim.pill),
                border: Border.all(color: colors.cardEdge, width: 1.5),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({
    required this.label,
    required this.colors,
    required this.onTap,
  });
  final String label;
  final GameColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: colors.accent,
          fontWeight: FontWeight.w700,
          fontSize: 14.5,
        ),
      ),
    );
  }
}
