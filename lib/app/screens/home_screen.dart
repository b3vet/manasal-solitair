/// Ana menü: devam et, oyna, bölümler, nasıl oynanır, ayarlar, kredi.
library;

import 'package:flutter/material.dart';

import '../../engine/level.dart';
import '../data/asset_data.dart';
import '../game/game_screen.dart';
import '../meta/meta_scope.dart';
import '../meta/meta_service.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
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
              return const Center(child: CircularProgressIndicator());
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

    return Stack(
      children: [
        Positioned(
          top: 8,
          right: 12,
          child: _creditBadge(colors, meta.credits),
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.style_rounded, size: 72, color: colors.accent),
                  const SizedBox(height: 12),
                  Text(
                    'Manasal\nSolitaire',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.ink,
                      fontSize: 40,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Anlamı benzer kelimeleri topla',
                    style: TextStyle(color: colors.inkSoft, fontSize: 15),
                  ),
                  const SizedBox(height: 44),
                  if (hasResume)
                    _bigButton(
                      context,
                      label: 'Devam Et  ·  Bölüm ${meta.resumeLevelId}',
                      icon: Icons.play_circle_fill_rounded,
                      color: colors.accent,
                      onTap: () => _resume(context, levels, meta),
                    ),
                  _bigButton(
                    context,
                    label: hasResume ? 'Yeni Bölüm' : 'Oyna',
                    icon: Icons.play_arrow_rounded,
                    color: hasResume ? colors.surface : colors.accent,
                    textColor: hasResume ? colors.ink : Colors.white,
                    onTap: () => _openGame(context, levels, playIndex),
                  ),
                  _bigButton(
                    context,
                    label: 'Bölümler',
                    icon: Icons.grid_view_rounded,
                    color: colors.surface,
                    textColor: colors.ink,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => LevelsScreen(levels: levels),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _smallButton(
                        context,
                        'Nasıl Oynanır',
                        Icons.help_outline_rounded,
                        () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const HowToPlayScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _smallButton(
                        context,
                        'Ayarlar',
                        Icons.settings_rounded,
                        () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: colors.accentSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.undo_rounded, size: 16, color: colors.accent),
          const SizedBox(width: 4),
          Text(
            '$credits',
            style: TextStyle(color: colors.accent, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _bigButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    Color textColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: onTap,
          icon: Icon(icon),
          label: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  Widget _smallButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    final colors = context.colors;
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: colors.inkSoft),
      label: Text(
        label,
        style: TextStyle(color: colors.inkSoft, fontWeight: FontWeight.w600),
      ),
    );
  }
}
