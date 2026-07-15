/// Üst bilgi çubuğu (HUD): menü, bölüm, kalan hamle, kategori sayacı, geri al.
library;

import 'package:flutter/material.dart';

import '../../../engine/engine.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

class Hud extends StatelessWidget {
  const Hud({
    super.key,
    required this.state,
    required this.undoCredits,
    required this.canUndo,
    required this.onMenu,
    required this.onUndo,
  });

  final GameState state;
  final int undoCredits;
  final bool canUndo;
  final VoidCallback onMenu;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final movesLow = state.movesLeft <= 5 && state.isPlaying;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          _iconButton(colors, Icons.menu_rounded, onMenu),
          const SizedBox(width: 6),
          Flexible(
            child: _chip(
              colors,
              icon: Icons.tag_rounded,
              label: 'Bölüm ${state.level.id}',
            ),
          ),
          Expanded(child: Center(child: _movesBadge(colors, movesLow))),
          Flexible(
            child: _chip(
              colors,
              icon: Icons.folder_special_rounded,
              label: '${state.completedCount}/${state.totalCategories}',
            ),
          ),
          const SizedBox(width: 6),
          _undoButton(colors),
        ],
      ),
    );
  }

  Widget _movesBadge(GameColors colors, bool low) {
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${state.movesLeft}',
          style: TextStyle(
            color: low ? colors.danger : colors.accent,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            height: 1,
          ),
        ),
        Text(
          'HAMLE',
          style: TextStyle(
            color: colors.inkSoft,
            fontSize: 9,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
    if (!low) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      builder: (_, v, c) => Transform.scale(scale: v, child: c),
      child: child,
    );
  }

  Widget _undoButton(GameColors colors) {
    final enabled = canUndo && undoCredits > 0;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Material(
        color: colors.accentSoft,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: enabled ? onUndo : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.undo_rounded, size: 18, color: colors.accent),
                const SizedBox(width: 3),
                Text(
                  '$undoCredits',
                  style: TextStyle(
                    color: colors.accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(
    GameColors colors, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.cardEdge),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: colors.inkSoft),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: colors.ink,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconButton(GameColors colors, IconData icon, VoidCallback onTap) {
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20, color: colors.ink),
        ),
      ),
    );
  }
}

/// Alt bilgi: deste sayısı etiketi (deste görseli tahtada).
class StockLabel extends StatelessWidget {
  const StockLabel({super.key, required this.count});
  final int count;
  @override
  Widget build(BuildContext context) => Text(
    '$count',
    style: TextStyle(color: context.colors.inkSoft, fontSize: 12),
  );
}
