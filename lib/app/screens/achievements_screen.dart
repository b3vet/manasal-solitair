/// Başarımlar ekranı: kredi bakiyesi + başarım listesi (kazanıldı/ilerleme).
library;

import 'package:flutter/material.dart';

import '../meta/meta_scope.dart';
import '../meta/meta_service.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final meta = MetaScope.of(context);
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(title: const Text('Başarımlar')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _walletCard(colors, meta.credits),
            const SizedBox(height: 16),
            _card(
              colors,
              icon: Icons.emoji_people_rounded,
              title: 'Hoş geldin',
              desc: 'Oyuna başladın.',
              reward: '+3',
              granted: meta.hasAchievement('welcome'),
            ),
            _card(
              colors,
              icon: Icons.military_tech_rounded,
              title: 'İlk zafer',
              desc: 'İlk bölümü tamamla.',
              reward: '+2',
              granted: meta.hasAchievement('first_win'),
            ),
            _card(
              colors,
              icon: Icons.bolt_rounded,
              title: 'Verimli',
              desc:
                  'Bir bölümü hamle limitinin en fazla %60\'ını harcayarak '
                  'bitir. Şimdiye dek ${meta.efficientCount()} bölümde başardın.',
              reward: '+1',
              granted: meta.efficientCount() > 0,
              repeat: true,
            ),
            _card(
              colors,
              icon: Icons.local_fire_department_rounded,
              title: 'Seri',
              desc:
                  'Art arda 3 bölümü ilk denemede bitir. '
                  'Şu anki seri: ${meta.streak}.',
              reward: '+1',
              granted: meta.streak >= 3,
              repeat: true,
            ),
            _collectorCard(colors, meta),
          ],
        ),
      ),
    );
  }

  Widget _walletCard(GameColors colors, int credits) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: colors.categoryFace,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.undo_rounded, color: colors.accent, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$credits geri alma kredisi',
                style: TextStyle(
                  color: colors.categoryText,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'İpucu ve geri alma için kullanılır',
                style: TextStyle(
                  color: colors.categoryText.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _collectorCard(GameColors colors, MetaService meta) {
    final total = meta.totalCategoriesCompleted;
    const thresholds = [25, 50, 100];
    final next = thresholds.firstWhere((t) => total < t, orElse: () => 100);
    final progress = (total / next).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.cardEdge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.collections_bookmark_rounded,
                color: colors.accent,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Koleksiyoncu',
                  style: TextStyle(
                    color: colors.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                '25/50/100 → +1/+2/+3',
                style: TextStyle(color: colors.inkSoft, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Toplam $total kategori tamamladın.',
            style: TextStyle(color: colors.inkSoft, fontSize: 13),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: colors.slotEmpty,
              valueColor: AlwaysStoppedAnimation(colors.accent),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final t in thresholds)
                Row(
                  children: [
                    Icon(
                      total >= t
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      size: 14,
                      color: total >= t ? colors.accent : colors.inkSoft,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '$t',
                      style: TextStyle(
                        color: total >= t ? colors.accent : colors.inkSoft,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card(
    GameColors colors, {
    required IconData icon,
    required String title,
    required String desc,
    required String reward,
    required bool granted,
    bool repeat = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: granted ? colors.accent : colors.cardEdge,
          width: granted ? 1.6 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: granted ? colors.accent : colors.inkSoft, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colors.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.accentSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$reward kredi${repeat ? ' ×' : ''}',
                        style: TextStyle(
                          color: colors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    color: colors.inkSoft,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (granted)
            Icon(Icons.check_circle_rounded, color: colors.accent, size: 20)
          else
            Icon(Icons.lock_outline_rounded, color: colors.inkSoft, size: 18),
        ],
      ),
    );
  }
}
