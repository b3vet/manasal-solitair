/// İstatistik ekranı (Kilim yönü): kampanya + günlük + cüzdan özetleri.
///
/// Yeni durum tutmaz — hepsi mevcut meta verisinden türetilir.
library;

import 'package:flutter/material.dart';

import '../../engine/level.dart';
import '../../engine/scoring.dart';
import '../meta/meta_scope.dart';
import '../theme/app_theme.dart';
import '../theme/kilim.dart';
import '../theme/tokens.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.levels});

  final List<LevelDef> levels;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final meta = MetaScope.of(context);

    final totalStars = levels
        .where((l) => meta.isCompleted(l.id))
        .fold<int>(
          0,
          (s, l) => s + starRating(meta.bestMovesLeft(l.id), l.moveLimit),
        );
    final maxStars = levels.length * 3;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: kilimAppBar(context, 'İstatistik'),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            _section(colors, 'KAMPANYA', [
              _Stat(
                Icons.flag_rounded,
                '${meta.highestCompleted}/${levels.length}',
                'Bölüm',
                colors.accent,
              ),
              _Stat(
                Icons.star_rounded,
                '$totalStars',
                'Yıldız · $maxStars',
                colors.gold,
              ),
              _Stat(
                Icons.category_rounded,
                '${meta.totalCategoriesCompleted}',
                'Kategori',
                colors.accent,
              ),
              _Stat(
                Icons.bolt_rounded,
                '${meta.efficientCount()}',
                'Verimli bölüm',
                colors.gold,
              ),
            ]),
            const SizedBox(height: 16),
            _section(colors, 'GÜNLÜK BULMACA', [
              _Stat(
                Icons.local_fire_department_rounded,
                '${meta.dailyStreak}',
                'Güncel seri',
                colors.accent,
              ),
              _Stat(
                Icons.emoji_events_rounded,
                '${meta.dailyBestStreak}',
                'En iyi seri',
                colors.gold,
              ),
              _Stat(
                Icons.today_rounded,
                '${meta.dailyPlayedCount}',
                'Oynanan gün',
                colors.accent,
              ),
              _Stat(
                Icons.star_rounded,
                '${meta.dailyThreeStarCount}',
                '3 yıldız',
                colors.gold,
              ),
            ]),
            const SizedBox(height: 16),
            _section(colors, 'CÜZDAN', [
              _Stat(
                Icons.undo_rounded,
                '${meta.credits}',
                'Kredi',
                colors.accent,
              ),
              _Stat(
                Icons.check_circle_rounded,
                '${meta.levelsCompleted}',
                'Tamamlanan',
                colors.gold,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _section(GameColors colors, String title, List<_Stat> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              color: colors.inkSoft,
              fontFamily: Fonts.sans,
              fontSize: 12,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(Dim.panelRadius),
            border: Border.all(color: colors.cardEdge),
          ),
          padding: const EdgeInsets.all(6),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.4,
            children: [for (final s in stats) _tile(colors, s)],
          ),
        ),
      ],
    );
  }

  Widget _tile(GameColors colors, _Stat s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(s.icon, size: 26, color: s.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  s.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.ink,
                    fontFamily: Fonts.sans,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.inkSoft,
                    fontFamily: Fonts.sans,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat {
  const _Stat(this.icon, this.value, this.label, this.accent);
  final IconData icon;
  final String value;
  final String label;
  final Color accent;
}
