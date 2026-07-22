/// Bölümler (Kilim yönü): dikey kilim patikası — elmas düğümler, yıldız
/// performansı (bestMovesLeft/moveLimit'ten türetilir), bölüm bantları.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../engine/level.dart';
import '../../engine/scoring.dart';
import '../game/game_screen.dart';
import '../meta/meta_scope.dart';
import '../meta/meta_service.dart';
import '../theme/app_theme.dart';
import '../theme/kilim.dart';
import '../theme/tokens.dart';

const _sectionSize = 20;
const _rowH = 132.0;
const _headerH = 58.0;
const _topPad = 8.0;

const _stageNames = [
  'BAŞLANGIÇ',
  'GELİŞİM',
  'USTALIK',
  'ZORLU',
  'UZMAN',
  'EFSANE',
];

class LevelsScreen extends StatefulWidget {
  const LevelsScreen({super.key, required this.levels});
  final List<LevelDef> levels;

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // İlk çerçeveden sonra mevcut bölüme kaydır.
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToCurrent());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  int get _currentIndex {
    final meta = MetaScope.read(context);
    return meta.highestCompleted.clamp(0, widget.levels.length - 1);
  }

  /// Bölüm indeksinin dikey ofseti (bantlar dahil).
  double _offsetFor(int index) {
    final sectionsBefore = index ~/ _sectionSize + 1; // üstteki bant sayısı
    return _topPad + sectionsBefore * _headerH + index * _rowH;
  }

  void _jumpToCurrent() {
    if (!_scroll.hasClients) return;
    final target = (_offsetFor(_currentIndex) - 220).clamp(
      0.0,
      _scroll.position.maxScrollExtent,
    );
    _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final meta = MetaScope.of(context);
    final totalStars = widget.levels
        .where((l) => meta.isCompleted(l.id))
        .fold<int>(
          0,
          (s, l) => s + starRating(meta.bestMovesLeft(l.id), l.moveLimit),
        );
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: kilimAppBar(
        context,
        'Bölümler',
        actions: [
          if (totalStars > 0) _starChip(colors, totalStars),
          _creditChip(colors, meta.credits),
        ],
      ),
      floatingActionButton: _currentFab(colors),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          controller: _scroll,
          child: Padding(
            padding: const EdgeInsets.only(top: _topPad, bottom: 90),
            child: Column(children: _buildRows(context, meta)),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRows(BuildContext context, MetaService meta) {
    final rows = <Widget>[];
    for (var i = 0; i < widget.levels.length; i++) {
      if (i % _sectionSize == 0) {
        final stage = i ~/ _sectionSize;
        final name = stage < _stageNames.length ? _stageNames[stage] : 'BÖLÜM';
        rows.add(_sectionBand(context, '$name · ${i + 1}–${i + _sectionSize}'));
      }
      rows.add(_levelRow(context, i, meta));
    }
    return rows;
  }

  Widget _sectionBand(BuildContext context, String label) {
    final colors = context.colors;
    return SizedBox(
      height: _headerH,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const _Spine(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              borderRadius: BorderRadius.circular(Dim.pill),
              border: Border.all(color: colors.cardEdge),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: colors.inkSoft,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _levelRow(BuildContext context, int index, MetaService meta) {
    final level = widget.levels[index];
    final unlocked = level.id <= meta.unlockedUpTo;
    final done = meta.isCompleted(level.id);
    final isCurrent = !done && unlocked;
    // Zigzag: çift indeks solda, tek indeks sağda.
    final xFrac = index.isEven ? -0.46 : 0.46;

    return SizedBox(
      height: _rowH,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const _Spine(),
          Align(
            alignment: Alignment(xFrac, 0),
            child: _node(context, index, level, done, unlocked, isCurrent),
          ),
        ],
      ),
    );
  }

  Widget _node(
    BuildContext context,
    int index,
    LevelDef level,
    bool done,
    bool unlocked,
    bool isCurrent,
  ) {
    final colors = context.colors;
    if (!unlocked) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.slotEmpty.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_rounded,
              color: colors.inkSoft.withValues(alpha: 0.8),
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${level.id}',
            style: TextStyle(
              color: colors.inkSoft,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }

    final stars = _starsFor(level, done);
    return GestureDetector(
      onTap: () => _open(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Diamond(
            size: isCurrent ? 76 : 66,
            fill: done ? colors.accent : colors.surface,
            border: isCurrent ? colors.accent : null,
            child: Text(
              '${level.id}',
              style: TextStyle(
                color: done ? colors.onAccent : colors.ink,
                fontFamily: Fonts.sans,
                fontWeight: FontWeight.w800,
                fontSize: isCurrent ? 24 : 21,
              ),
            ),
          ),
          const SizedBox(height: 6),
          if (isCurrent)
            _playButton(colors)
          else if (done)
            _stars(colors, stars),
        ],
      ),
    );
  }

  Widget _stars(GameColors colors, int stars) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Icon(
            i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 15,
            color: i < stars
                ? colors.gold
                : colors.inkSoft.withValues(alpha: 0.5),
          ),
      ],
    );
  }

  Widget _playButton(GameColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: BorderRadius.circular(Dim.pill),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.35),
            blurRadius: 10,
          ),
        ],
      ),
      child: Text(
        'Oyna',
        style: TextStyle(
          color: colors.onAccent,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }

  int _starsFor(LevelDef level, bool done) {
    if (!done) return 0;
    return starRating(
      MetaScope.read(context).bestMovesLeft(level.id),
      level.moveLimit,
    );
  }

  Widget _starChip(GameColors colors, int total) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: colors.gold.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(Dim.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, size: 15, color: colors.gold),
              const SizedBox(width: 4),
              Text(
                '$total',
                style: TextStyle(
                  color: colors.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _creditChip(GameColors colors, int credits) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: colors.accentSoft,
            borderRadius: BorderRadius.circular(Dim.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.undo_rounded, size: 15, color: colors.accent),
              const SizedBox(width: 4),
              Text(
                '$credits',
                style: TextStyle(
                  color: colors.accent,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _currentFab(GameColors colors) {
    return FloatingActionButton.extended(
      onPressed: _jumpToCurrent,
      backgroundColor: colors.ink,
      foregroundColor: colors.bg,
      elevation: 3,
      icon: Icon(Icons.my_location_rounded, size: 18, color: colors.gold),
      label: Text(
        'Bölüm ${widget.levels[_currentIndex].id}',
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
      ),
    );
  }

  void _open(int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(levels: widget.levels, startIndex: index),
      ),
    );
  }
}

/// Merkezî dikey kesikli patika omurgası (bir satır yüksekliğinde).
class _Spine extends StatelessWidget {
  const _Spine();
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(painter: _SpinePainter(context.colors.slotEmpty)),
    );
  }
}

class _SpinePainter extends CustomPainter {
  _SpinePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    const dash = 6.0, gap = 6.0;
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(x, y),
        Offset(x, math.min(y + dash, size.height)),
        paint,
      );
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_SpinePainter old) => old.color != color;
}

/// Elmas (döndürülmüş yuvarlak kare) düğüm + ortada döndürülmemiş içerik.
class _Diamond extends StatelessWidget {
  const _Diamond({
    required this.size,
    required this.fill,
    required this.child,
    this.border,
  });
  final double size;
  final Color fill;
  final Color? border;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final side = size / 1.41;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: side,
              height: side,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(size * 0.14),
                border: border != null
                    ? Border.all(color: border!, width: 2.5)
                    : Border.all(color: colors.cardEdge, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
