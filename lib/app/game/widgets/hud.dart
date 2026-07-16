/// Alt kontrol çubuğu: menü, bölüm no, ipucu, geri al.
///
/// Odak dışı kontroller en altta (baş parmak bölgesi); önemli oyun bilgisi
/// (kalan hamle, kategori, deste) tahtanın en üstünde gösterilir.
library;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required this.levelId,
    required this.undoCredits,
    required this.canUndo,
    required this.onMenu,
    required this.onUndo,
    required this.onHint,
  });

  final int levelId;
  final int undoCredits;
  final bool canUndo;
  final VoidCallback onMenu;
  final VoidCallback onUndo;
  final VoidCallback onHint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      child: Row(
        children: [
          _iconButton(colors, Icons.menu_rounded, onMenu),
          const SizedBox(width: 6),
          Flexible(
            child: _chip(
              colors,
              icon: Icons.tag_rounded,
              label: 'Bölüm $levelId',
            ),
          ),
          const SizedBox(width: 6),
          _actionButton(
            colors,
            icon: Icons.lightbulb_outline_rounded,
            label: 'İpucu',
            onTap: onHint,
          ),
          const SizedBox(width: 6),
          _actionButton(
            colors,
            icon: Icons.undo_rounded,
            label: '$undoCredits',
            onTap: canUndo && undoCredits > 0 ? onUndo : null,
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    GameColors colors, {
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Material(
        color: colors.accentSoft,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 20, color: colors.accent),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: colors.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
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
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 22, color: colors.ink),
        ),
      ),
    );
  }
}
