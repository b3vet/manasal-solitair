/// Başarımlar (Kilim yönü): kredi cüzdanı banner'ı + başarım listesi.
library;

import 'package:flutter/material.dart';

import '../meta/meta_scope.dart';
import '../meta/meta_service.dart';
import '../theme/app_theme.dart';
import '../theme/kilim.dart';
import '../theme/tokens.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final meta = MetaScope.of(context);
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: kilimAppBar(context, 'Başarımlar'),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _walletCard(colors, meta.credits),
            const SizedBox(height: 16),
            _card(
              colors,
              icon: Icons.emoji_people_rounded,
              tint: colors.accent,
              title: 'Hoş geldin',
              desc: 'Oyuna başladın.',
              reward: '+3',
              granted: meta.hasAchievement('welcome'),
            ),
            _card(
              colors,
              icon: Icons.star_rounded,
              tint: colors.gold,
              title: 'İlk zafer',
              desc: 'İlk bölümü tamamla.',
              reward: '+2',
              granted: meta.hasAchievement('first_win'),
            ),
            _card(
              colors,
              icon: Icons.bolt_rounded,
              tint: colors.gold,
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
              tint: colors.accent,
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
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.categoryFace,
        borderRadius: BorderRadius.circular(Dim.panelRadius),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          KilimBand(colors: colors, height: 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.categoryText.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.undo_rounded,
                    color: colors.categoryText,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$credits geri alma kredisi',
                        style: TextStyle(
                          color: colors.categoryText,
                          fontFamily: Fonts.serif,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'İpucu ve geri alma için kullanılır',
                        style: TextStyle(
                          color: colors.categoryText.withValues(alpha: 0.72),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
        borderRadius: BorderRadius.circular(Dim.panelRadius),
        border: Border.all(color: colors.cardEdge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconTile(colors, Icons.grid_view_rounded, colors.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Koleksiyoncu',
                  style: TextStyle(
                    color: colors.ink,
                    fontFamily: Fonts.serif,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              Text(
                '25/50/100 → +1/+2/+3',
                style: TextStyle(color: colors.inkSoft, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Toplam $total kategori tamamladın.',
            style: TextStyle(color: colors.inkSoft, fontSize: 13),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(Dim.pill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: colors.cardEdge,
              valueColor: AlwaysStoppedAnimation(colors.accent),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final t in thresholds)
                Row(
                  children: [
                    KilimDiamond(
                      size: 11,
                      color: total >= t ? colors.gold : colors.inkSoft,
                      filled: total >= t,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$t',
                      style: TextStyle(
                        color: total >= t ? colors.ink : colors.inkSoft,
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

  Widget _iconTile(GameColors colors, IconData icon, Color tint) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, color: tint, size: 22),
    );
  }

  Widget _card(
    GameColors colors, {
    required IconData icon,
    required Color tint,
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
        borderRadius: BorderRadius.circular(Dim.panelRadius),
        border: Border.all(
          color: granted ? colors.accent : colors.cardEdge,
          width: granted ? 1.6 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconTile(colors, icon, tint),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: colors.ink,
                          fontFamily: Fonts.serif,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.accentSoft,
                        borderRadius: BorderRadius.circular(Dim.pill),
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
                const SizedBox(height: 5),
                Text(
                  desc,
                  style: TextStyle(
                    color: colors.inkSoft,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (granted)
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.accent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: colors.onAccent,
                size: 16,
              ),
            )
          else
            Icon(
              Icons.lock_outline_rounded,
              color: colors.inkSoft.withValues(alpha: 0.7),
              size: 20,
            ),
        ],
      ),
    );
  }
}
