/// Kazanma / kayıp / duraklat diyalogları.
library;

import 'package:flutter/material.dart';

import '../../../engine/engine.dart';
import '../../theme/app_theme.dart';

enum GameDialogAction { next, retry, levels, undoContinue, resume }

Future<GameDialogAction?> showWinDialog(
  BuildContext context, {
  required int movesLeft,
  required int creditsAwarded,
  required bool hasNext,
}) {
  final colors = context.colors;
  final sub = creditsAwarded > 0
      ? 'Kalan hamle: $movesLeft\n+$creditsAwarded geri alma kredisi kazandın!'
      : 'Bölümü tamamladın. Kalan hamle: $movesLeft';
  return showDialog<GameDialogAction>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _Frame(
      icon: Icons.celebration_rounded,
      iconColor: colors.accent,
      title: 'Tebrikler!',
      subtitle: sub,
      children: [
        if (hasNext)
          _PrimaryButton(
            label: 'Sıradaki Bölüm',
            color: colors.accent,
            onTap: () => Navigator.pop(context, GameDialogAction.next),
          ),
        _SecondaryButton(
          label: 'Bölümler',
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
}) {
  final colors = context.colors;
  final reason = status == GameStatus.lostOutOfMoves
      ? 'Hamlen bitti.'
      : 'Oynanacak hamle kalmadı.';
  return showDialog<GameDialogAction>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _Frame(
      icon: Icons.sentiment_dissatisfied_rounded,
      iconColor: colors.warning,
      title: 'Bölüm başarısız',
      subtitle: reason,
      children: [
        if (canUndoContinue)
          _PrimaryButton(
            label: 'Geri al ve devam et  ·  1 kredi',
            color: colors.accent,
            onTap: () => Navigator.pop(context, GameDialogAction.undoContinue),
          ),
        _PrimaryButton(
          label: 'Yeniden başla',
          color: canUndoContinue ? colors.surface : colors.accent,
          textColor: canUndoContinue ? colors.ink : Colors.white,
          onTap: () => Navigator.pop(context, GameDialogAction.retry),
        ),
        _SecondaryButton(
          label: 'Bölümler',
          onTap: () => Navigator.pop(context, GameDialogAction.levels),
        ),
      ],
    ),
  );
}

Future<GameDialogAction?> showPauseDialog(BuildContext context) {
  final colors = context.colors;
  return showDialog<GameDialogAction>(
    context: context,
    builder: (context) => _Frame(
      icon: Icons.pause_circle_outline_rounded,
      iconColor: colors.accent,
      title: 'Duraklatıldı',
      subtitle: null,
      children: [
        _PrimaryButton(
          label: 'Devam et',
          color: colors.accent,
          onTap: () => Navigator.pop(context, GameDialogAction.resume),
        ),
        _SecondaryButton(
          label: 'Yeniden başla',
          onTap: () => Navigator.pop(context, GameDialogAction.retry),
        ),
        _SecondaryButton(
          label: 'Bölümler',
          onTap: () => Navigator.pop(context, GameDialogAction.levels),
        ),
      ],
    ),
  );
}

class _Frame extends StatelessWidget {
  const _Frame({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.children,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: iconColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: colors.ink,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.inkSoft, fontSize: 14),
              ),
            ],
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.textColor = Colors.white,
  });
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onTap,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: context.colors.inkSoft,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
