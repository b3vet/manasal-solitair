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
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Row(
        children: [
          _circleButton(colors, Icons.menu_rounded, onMenu),
          const SizedBox(width: 8),
          Flexible(child: _levelChip(colors)),
          const Spacer(),
          _hintButton(colors),
          const SizedBox(width: 8),
          _undoButton(colors),
        ],
      ),
    );
  }

  Widget _hintButton(GameColors colors) {
    return Material(
      color: colors.accentSoft,
      borderRadius: BorderRadius.circular(Dim.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dim.pill),
        onTap: onHint,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 19,
                color: colors.accent,
              ),
              const SizedBox(width: 6),
              Text(
                'İpucu',
                style: TextStyle(
                  color: colors.accent,
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _undoButton(GameColors colors) {
    final enabled = canUndo && undoCredits > 0;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: colors.surface,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onUndo : null,
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.undo_rounded, size: 20, color: colors.ink),
                const SizedBox(width: 5),
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$undoCredits',
                    style: TextStyle(
                      color: colors.onAccent,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _levelChip(GameColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Dim.pill),
        border: Border.all(color: colors.cardEdge),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'Bölüm $levelId',
          style: TextStyle(
            color: colors.ink,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }

  Widget _circleButton(GameColors colors, IconData icon, VoidCallback onTap) {
    return Material(
      color: colors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Icon(icon, size: 22, color: colors.ink),
        ),
      ),
    );
  }
}
