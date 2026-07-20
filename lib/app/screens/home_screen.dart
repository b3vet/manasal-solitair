/// Ana menü (Kilim yönü): devam et, oyna, bölümler, nasıl oynanır, ayarlar,
/// kredi cüzdanı, ilerleme.
library;

import 'package:flutter/material.dart';

import '../../engine/level.dart';
import '../data/asset_data.dart';
import '../game/game_screen.dart';
import '../meta/meta_scope.dart';
import '../meta/meta_service.dart';
import '../theme/app_theme.dart';
import '../theme/kilim.dart';
import '../theme/tokens.dart';
import 'achievements_screen.dart';
import 'how_to_play_screen.dart';
import 'levels_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<List<LevelDef>> _levelsFuture = AssetData.loadLevels();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: FutureBuilder<List<LevelDef>>(
          future: _levelsFuture,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator(color: colors.accent),
              );
            }
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Bölümler yüklenemedi:\n${snap.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.danger),
                  ),
                ),
              );
            }
            return _menu(context, snap.data!);
          },
        ),
      ),
    );
  }

  Widget _menu(BuildContext context, List<LevelDef> levels) {
    final colors = context.colors;
    final meta = MetaScope.of(context);
    final hasResume = meta.resumeLevelId != null;
    final playIndex = meta.highestCompleted.clamp(0, levels.length - 1);
    final progress = (meta.highestCompleted / levels.length).clamp(0.0, 1.0);

    return Stack(
      children: [
        // Alt kenarda kilim bordürü.
        const Align(alignment: Alignment.bottomCenter, child: _Footer()),
        Positioned(
          top: 6,
          right: 14,
          child: _creditBadge(colors, meta.credits),
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 34),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  KilimLogo(width: 92, colors: colors),
                  const SizedBox(height: 22),
                  Text(
                    'Manasal\nSolitaire',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.ink,
                      fontFamily: Fonts.serif,
                      fontSize: 42,
                      height: 1.02,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Anlamı benzer kelimeleri topla',
                    style: TextStyle(color: colors.inkSoft, fontSize: 15),
                  ),
                  const SizedBox(height: 22),
                  _progress(
                    colors,
                    progress,
                    meta.highestCompleted,
                    levels.length,
                  ),
                  const Spacer(flex: 4),
                  if (hasResume)
                    _primaryButton(
                      context,
                      label: 'Devam Et  ·  Bölüm ${meta.resumeLevelId}',
                      icon: Icons.play_arrow_rounded,
                      onTap: () => _resume(context, levels, meta),
                    )
                  else
                    _primaryButton(
                      context,
                      label: 'Oyna',
                      icon: Icons.play_arrow_rounded,
                      onTap: () => _openGame(context, levels, playIndex),
                    ),
                  const SizedBox(height: 10),
                  if (hasResume)
                    _secondaryButton(
                      context,
                      label: 'Yeni Bölüm',
                      onTap: () => _openGame(context, levels, playIndex),
                    ),
                  if (hasResume) const SizedBox(height: 10),
                  _secondaryButton(
                    context,
                    label: 'Bölümler',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => LevelsScreen(levels: levels),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _link(context, 'Nasıl Oynanır', () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const HowToPlayScreen(),
                          ),
                        );
                      }),
                      _dot(colors),
                      _link(context, 'Başarımlar', () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const AchievementsScreen(),
                          ),
                        );
                      }),
                      _dot(colors),
                      _link(context, 'Ayarlar', () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      }),
                    ],
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _progress(GameColors colors, double value, int done, int total) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Dim.pill),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 7,
            backgroundColor: colors.cardEdge,
            valueColor: AlwaysStoppedAnimation(colors.accent),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$done / $total BÖLÜM',
          style: TextStyle(
            color: colors.inkSoft,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  void _openGame(BuildContext context, List<LevelDef> levels, int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(levels: levels, startIndex: index),
      ),
    );
  }

  void _resume(BuildContext context, List<LevelDef> levels, MetaService meta) {
    final id = meta.resumeLevelId!;
    final index = levels.indexWhere((l) => l.id == id);
    if (index < 0) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(
          levels: levels,
          startIndex: index,
          resumeMoves: meta.resumeMoves,
        ),
      ),
    );
  }

  Widget _creditBadge(GameColors colors, int credits) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: colors.accentSoft,
        borderRadius: BorderRadius.circular(Dim.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.undo_rounded, size: 16, color: colors.accent),
          const SizedBox(width: 5),
          Text(
            '$credits',
            style: TextStyle(
              color: colors.accent,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'KREDİ',
            style: TextStyle(
              color: colors.accent.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: colors.accent,
        borderRadius: BorderRadius.circular(Dim.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(Dim.pill),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: colors.onAccent, size: 22),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: colors.onAccent,
                    fontSize: 17,
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

  Widget _secondaryButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Dim.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(Dim.pill),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dim.pill),
              border: Border.all(color: colors.cardEdge, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: colors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _link(BuildContext context, String label, VoidCallback onTap) {
    final colors = context.colors;
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.accent,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _dot(GameColors colors) =>
      Text('·', style: TextStyle(color: colors.inkSoft.withValues(alpha: 0.6)));
}

class _Footer extends StatelessWidget {
  const _Footer();
  @override
  Widget build(BuildContext context) =>
      KilimBand(colors: context.colors, height: 12);
}
