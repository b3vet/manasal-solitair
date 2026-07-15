/// Bölüm ızgarası: sıralı kilit + tamamlandı işareti (ilerleme).
library;

import 'package:flutter/material.dart';

import '../../engine/level.dart';
import '../game/game_screen.dart';
import '../meta/meta_scope.dart';
import '../theme/app_theme.dart';

class LevelsScreen extends StatelessWidget {
  const LevelsScreen({super.key, required this.levels});

  final List<LevelDef> levels;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final meta = MetaScope.of(context);
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const Text('Bölümler'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Row(
                children: [
                  Icon(Icons.undo_rounded, size: 16, color: colors.accent),
                  const SizedBox(width: 3),
                  Text(
                    '${meta.credits}',
                    style: TextStyle(
                      color: colors.accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: levels.length,
          itemBuilder: (context, i) {
            final level = levels[i];
            final unlocked = level.id <= meta.unlockedUpTo;
            final isDone = meta.isCompleted(level.id);
            return _tile(context, i, level, unlocked, isDone);
          },
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    int index,
    LevelDef level,
    bool unlocked,
    bool isDone,
  ) {
    final colors = context.colors;
    return Material(
      color: unlocked
          ? colors.surface
          : colors.slotEmpty.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: unlocked ? () => _open(context, index) : null,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDone ? colors.accent : colors.cardEdge,
              width: isDone ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!unlocked)
                Icon(Icons.lock_rounded, color: colors.inkSoft, size: 22)
              else ...[
                Text(
                  '${level.id}',
                  style: TextStyle(
                    color: colors.ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (isDone)
                  Icon(
                    Icons.check_circle_rounded,
                    color: colors.accent,
                    size: 16,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(levels: levels, startIndex: index),
      ),
    );
  }
}
