/// Oyun tahtası: kartların yerleşimi, sürükle-bırak ve hareket animasyonları.
///
/// Her kart AnimatedPositioned'dır (kimliğe göre); motor bir hamleyi
/// uyguladığında kartlar yeni yuvalarına akar. Sürüklenen birim parmağı
/// gecikmesiz takip eder; bırakınca geçerliyse yeni yuvaya, değilse eskisine
/// yumuşakça döner. İpucu sızdırmaz: kelime sürüklenirken hedef VURGULANMAZ
/// (Spec K15).
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../engine/engine.dart';
import '../audio/sound_service.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'board_metrics.dart';
import 'game_controller.dart';
import 'widgets/cards.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({
    super.key,
    required this.controller,
    this.reduceMotion = false,
    this.haptics = true,
  });
  final GameController controller;
  final bool reduceMotion;
  final bool haptics;

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _DragState {
  _DragState({
    required this.source,
    required this.cards,
    required this.baseDelta,
    required this.pointer,
    required this.isCategory,
  });
  final UnitRef source;
  final List<GameCard> cards;
  final Offset baseDelta; // pointer - birimin taban kartının sol-üstü
  Offset pointer;
  final bool isCategory;
}

class _GameBoardState extends State<GameBoard>
    with SingleTickerProviderStateMixin {
  _DragState? _drag;
  int _celebrateToken = 0;
  String? _celebrateText;
  late final AnimationController _pulse;

  GameController get c => widget.controller;
  GameState get state => c.state;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    c.addListener(_onChange);
  }

  @override
  void didUpdateWidget(covariant GameBoard old) {
    super.didUpdateWidget(old);
    if (old.controller != c) {
      old.controller.removeListener(_onChange);
      c.addListener(_onChange);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    c.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    _feedback(c.lastEvents);
    for (final e in c.lastEvents) {
      if (e is CategoryCompletedEvent) {
        final cat = c.level.categories.firstWhere(
          (x) => x.categoryId == e.categoryId,
          orElse: () => c.level.categories.first,
        );
        _celebrateText = cat.name;
        _celebrateToken++;
      }
    }
    // Nabzı yalnızca ipucu aktifken çalıştır (sonsuz animasyon değil).
    if (c.hintMove != null && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (c.hintMove == null && _pulse.isAnimating) {
      _pulse.stop();
    }
    if (mounted) setState(() => _drag = null);
  }

  void _feedback(List<GameEvent> events) {
    if (events.isEmpty) return;
    if (widget.haptics) {
      if (events.any((e) => e is CategoryCompletedEvent)) {
        HapticFeedback.heavyImpact();
      } else if (events.any(
        (e) =>
            e is UnitPlacedEvent ||
            e is WordsCollectedEvent ||
            e is SlotActivatedEvent,
      )) {
        HapticFeedback.lightImpact();
      }
    }
    final sfx = _soundFor(events);
    if (sfx != null) SoundService.instance.play(sfx);
  }

  Sfx? _soundFor(List<GameEvent> events) {
    if (events.any((e) => e is CategoryCompletedEvent)) return Sfx.complete;
    for (final e in events) {
      if (e is SlotActivatedEvent) {
        return e.sweptWords.isNotEmpty ? Sfx.sweep : Sfx.place;
      }
    }
    if (events.any((e) => e is WordsCollectedEvent)) return Sfx.collect;
    if (events.any((e) => e is UnitPlacedEvent)) return Sfx.place;
    if (events.any((e) => e is FlippedEvent)) return Sfx.flip;
    if (events.any((e) => e is DrewEvent)) return Sfx.draw;
    if (events.any((e) => e is RecycledEvent)) return Sfx.draw;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final counts = [
          for (final col in state.columns)
            col.faceDown.length + col.faceUp.length,
        ];
        final faceDown = [for (final col in state.columns) col.faceDown.length];
        final m = BoardMetrics(
          size: size,
          columnCount: state.columns.length,
          slotCount: state.slots.length,
          columnCounts: counts,
          columnFaceDown: faceDown,
        );

        final children = <Widget>[];
        children.addAll(_slotFrames(m, colors));
        children.addAll(_columnFrames(m, colors));
        children.addAll(_pileFrames(m, colors));
        children.addAll(_cards(m, colors));
        children.addAll(_topInfo(m, colors));
        if (_celebrateText != null) {
          children.add(
            Positioned.fill(
              child: IgnorePointer(
                child: _CelebrationBanner(
                  key: ValueKey('celebrate_$_celebrateToken'),
                  text: _celebrateText!,
                  colors: colors,
                  reduceMotion: widget.reduceMotion,
                ),
              ),
            ),
          );
        }
        if (c.hintMove != null) {
          children.addAll(_hintRings(m, colors));
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) => _onTap(m, d.localPosition),
          onDoubleTapDown: (d) => _onDoubleTap(m, d.localPosition),
          onPanStart: (d) => _onPanStart(m, d.localPosition),
          onPanUpdate: (d) => _onPanUpdate(d.localPosition),
          onPanEnd: (_) => _onPanEnd(m),
          child: SizedBox.expand(
            child: Stack(clipBehavior: Clip.none, children: children),
          ),
        );
      },
    );
  }

  // --- Boş çerçeveler (slotlar, sütunlar, deste/atık) ---

  List<Widget> _slotFrames(BoardMetrics m, GameColors colors) {
    final out = <Widget>[];
    for (var i = 0; i < state.slots.length; i++) {
      final slot = state.slots[i];
      if (slot is EmptySlot) {
        out.add(
          _positioned(
            'slot_empty_$i',
            m.slotTopLeft(i),
            m.card,
            EmptyFrameView(size: m.card, colors: colors, icon: Icons.add),
          ),
        );
      }
    }
    return out;
  }

  List<Widget> _columnFrames(BoardMetrics m, GameColors colors) {
    final out = <Widget>[];
    for (var col = 0; col < state.columns.length; col++) {
      if (state.columns[col].isEmpty) {
        out.add(
          _positioned(
            'col_empty_$col',
            m.columnTopLeft(col),
            m.card,
            EmptyFrameView(size: m.card, colors: colors),
          ),
        );
      }
    }
    return out;
  }

  List<Widget> _pileFrames(BoardMetrics m, GameColors colors) {
    final out = <Widget>[];
    if (state.stock.isEmpty) {
      out.add(
        _positioned(
          'stock_empty',
          m.stockTopLeft(),
          m.card,
          EmptyFrameView(size: m.card, colors: colors, icon: Icons.refresh),
        ),
      );
    }
    if (state.waste.isEmpty) {
      out.add(
        _positioned(
          'waste_empty',
          m.wasteTopLeft(),
          m.card,
          EmptyFrameView(size: m.card, colors: colors),
        ),
      );
    }
    return out;
  }

  // --- Üst bilgi (kalan hamle, kategori sayacı, deste kart sayısı) ---

  List<Widget> _topInfo(BoardMetrics m, GameColors colors) {
    final out = <Widget>[];
    final area = m.statArea;
    out.add(
      Positioned(
        left: area.left,
        top: area.top,
        width: area.width,
        height: area.height,
        child: IgnorePointer(
          child: _StatRow(
            movesLeft: state.movesLeft,
            completed: state.completedCount,
            totalCategories: state.totalCategories,
            colors: colors,
          ),
        ),
      ),
    );
    if (state.stock.isNotEmpty) {
      final tl = m.stockTopLeft();
      out.add(
        Positioned(
          left: tl.dx,
          top: tl.dy + m.card.height * 0.6,
          width: m.card.width,
          height: m.card.height * 0.32,
          child: IgnorePointer(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xE6231710),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${state.stock.length}',
                  style: const TextStyle(
                    color: Color(0xFFF4E9D7),
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return out;
  }

  // --- Kartlar ---

  List<Widget> _cards(BoardMetrics m, GameColors colors) {
    final dragIds = _drag == null
        ? const <String>{}
        : {for (final c in _drag!.cards) c.id};
    final normal = <Widget>[];
    final dragged = <Widget>[];

    // Toplama slotlarındaki kategori kartları.
    for (var i = 0; i < state.slots.length; i++) {
      final slot = state.slots[i];
      if (slot is ActiveSlot) {
        normal.add(
          _positioned(
            slot.card.id,
            m.slotTopLeft(i),
            m.card,
            CategoryCardView(
              card: slot.card,
              size: m.card,
              colors: colors,
              collected: slot.collected.length,
            ),
          ),
        );
      }
    }

    // Sütun kartları.
    for (var col = 0; col < state.columns.length; col++) {
      final column = state.columns[col];
      final all = [...column.faceDown, ...column.faceUp];
      final faceDownCount = column.faceDown.length;
      for (var k = 0; k < all.length; k++) {
        final card = all[k];
        if (dragIds.contains(card.id)) continue;
        final faceUp = k >= faceDownCount;
        final home = m.cardTopLeft(col, k);
        normal.add(
          _positioned(
            card.id,
            home,
            m.card,
            _cardWidget(
              card,
              colors,
              m.card,
              faceUp: faceUp,
              locked: column.isLocked,
            ),
          ),
        );
      }
    }

    // Deste üstü (kapalı) + atık üstü (açık).
    if (state.stock.isNotEmpty) {
      final top = state.stock.last;
      normal.add(
        _positioned(
          'stocktop_${top.id}',
          m.stockTopLeft(),
          m.card,
          CardBackView(size: m.card, colors: colors),
        ),
      );
    }
    // Atık: son birkaç açılan kartı yelpaze halinde göster. Eski kartlar arkada
    // ince dikey kenar (90° yazı), en yeni tam kart (etkileşimli, en üstte).
    if (state.waste.isNotEmpty) {
      final n = state.waste.length;
      final shown = n < BoardMetrics.wasteFanMax ? n : BoardMetrics.wasteFanMax;
      for (var back = shown - 1; back >= 1; back--) {
        final edge = state.waste[n - 1 - back];
        normal.add(
          _positioned(
            'wasteedge_${edge.id}',
            m.wasteEdgeTopLeft(back),
            Size(m.wasteStripWidth, m.card.height),
            WasteEdgeView(
              card: edge,
              width: m.wasteStripWidth,
              height: m.card.height,
              colors: colors,
            ),
          ),
        );
      }
      final top = state.waste.last;
      if (!dragIds.contains(top.id)) {
        normal.add(
          _positioned(
            top.id,
            m.wasteTopLeft(),
            m.card,
            _cardWidget(top, colors, m.card, faceUp: true, locked: false),
          ),
        );
      }
    }

    // Sürüklenen birim (parmağı takip eder, en üstte).
    if (_drag != null) {
      final d = _drag!;
      for (var j = 0; j < d.cards.length; j++) {
        final card = d.cards[j];
        final pos = d.pointer - d.baseDelta + Offset(0, j * m.step);
        dragged.add(
          _positioned(
            card.id,
            pos,
            m.card,
            _cardWidget(
              card,
              colors,
              m.card,
              faceUp: true,
              locked: false,
              raised: true,
            ),
            instant: true,
          ),
        );
      }
    }

    return [...normal, ...dragged];
  }

  Widget _cardWidget(
    GameCard card,
    GameColors colors,
    Size size, {
    required bool faceUp,
    required bool locked,
    bool raised = false,
  }) {
    if (!faceUp) return CardBackView(size: size, colors: colors);
    if (card is WordCard) {
      return WordCardView(
        card: card,
        size: size,
        colors: colors,
        raised: raised,
      );
    }
    return CategoryCardView(
      card: card as CategoryCard,
      size: size,
      colors: colors,
      locked: locked,
      raised: raised,
    );
  }

  Widget _positioned(
    String id,
    Offset topLeft,
    Size size,
    Widget child, {
    bool instant = false,
  }) {
    return AnimatedPositioned(
      key: ValueKey(id),
      duration: (instant || widget.reduceMotion) ? Duration.zero : Anim.place,
      curve: Curves.easeOutCubic,
      left: topLeft.dx,
      top: topLeft.dy,
      width: size.width,
      height: size.height,
      child: child,
    );
  }

  // --- İpucu vurgusu ---

  List<Widget> _hintRings(BoardMetrics m, GameColors colors) {
    final hm = c.hintMove!;
    final rects = <Rect>[];
    if (hm is PlaceMove) {
      switch (hm.unit) {
        case ColumnUnitRef(:final column):
          // Tüm açık yığın tek birim taşınır: yığının tabanını vurgula.
          final fd = state.columns[column].faceDown.length;
          rects.add(m.cardTopLeft(column, fd) & m.card);
        case WasteUnitRef():
          rects.add(m.wasteTopLeft() & m.card);
      }
      switch (hm.target) {
        case ColumnTargetRef(:final column):
          final col = state.columns[column];
          final count = col.faceDown.length + col.faceUp.length;
          rects.add(m.cardTopLeft(column, count) & m.card);
        case FoundationTargetRef(:final slot):
          rects.add(m.slotTopLeft(slot) & m.card);
      }
    } else if (hm is DrawMove) {
      rects.add(m.stockTopLeft() & m.card);
    }
    return [for (final r in rects) _hintRing(r, colors)];
  }

  Widget _hintRing(Rect rect, GameColors colors) {
    final r = rect.inflate(3);
    return Positioned(
      key: ValueKey('hint_${r.left}_${r.top}'),
      left: r.left,
      top: r.top,
      width: r.width,
      height: r.height,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            final t = widget.reduceMotion ? 0.5 : _pulse.value;
            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dim.cardRadius + 2),
                border: Border.all(
                  color: colors.accent.withValues(alpha: 0.45 + 0.55 * t),
                  width: 2.5 + 1.5 * t,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Etkileşim ---

  void _onTap(BoardMetrics m, Offset p) {
    final stockRect = m.stockTopLeft() & m.card;
    if (stockRect.inflate(Dim.gap).contains(p)) {
      if (state.stock.isNotEmpty) {
        c.draw();
      } else if (state.waste.isNotEmpty) {
        c.recycle();
      }
    }
  }

  void _onDoubleTap(BoardMetrics m, Offset p) {
    final grab = _hitGrab(m, p);
    if (grab == null) return;
    if (grab.isCategory) {
      c.autoPlaceCategory(grab.source);
    }
  }

  void _onPanStart(BoardMetrics m, Offset p) {
    c.clearHint();
    final grab = _hitGrab(m, p);
    if (grab == null) return;
    setState(() {
      _drag = _DragState(
        source: grab.source,
        cards: grab.cards,
        baseDelta: p - grab.baseTopLeft,
        pointer: p,
        isCategory: grab.isCategory,
      );
    });
  }

  void _onPanUpdate(Offset p) {
    if (_drag == null) return;
    setState(() => _drag!.pointer = p);
  }

  void _onPanEnd(BoardMetrics m) {
    final d = _drag;
    if (d == null) return;
    final topLeft = d.pointer - d.baseDelta;
    final center = topLeft + Offset(m.card.width / 2, m.card.height / 2);

    TargetRef? target;
    final slot = m.slotAt(center);
    if (slot != null) {
      target = FoundationTargetRef(slot);
    } else {
      final col = m.columnAt(center);
      if (col != null) target = ColumnTargetRef(col);
    }

    var applied = false;
    if (target != null) {
      applied = c.place(d.source, target);
    }
    if (!applied) {
      if (widget.haptics) HapticFeedback.mediumImpact();
      SoundService.instance.play(Sfx.invalid);
      setState(() => _drag = null); // eskisine döner (animasyon)
    }
    // applied ise controller notifyListeners → _onChange drag'i temizler.
  }

  /// Bir noktada tutulabilir birim var mı? (waste top veya sütun kartı)
  _Grab? _hitGrab(BoardMetrics m, Offset p) {
    // Atık üstü?
    if (state.waste.isNotEmpty) {
      final r = m.wasteTopLeft() & m.card;
      if (r.contains(p)) {
        final resolved = Rules.resolveUnit(state, const WasteUnitRef());
        if (resolved is Ok<MovableUnit, RuleViolation>) {
          return _Grab(
            source: const WasteUnitRef(),
            cards: resolved.data.cards,
            baseTopLeft: m.wasteTopLeft(),
            isCategory: resolved.data is CategoryUnit,
          );
        }
      }
    }
    // Sütun kartları (üstten alta doğru ilk isabet).
    for (var col = 0; col < state.columns.length; col++) {
      final column = state.columns[col];
      final all = [...column.faceDown, ...column.faceUp];
      final faceDownCount = column.faceDown.length;
      for (var k = all.length - 1; k >= faceDownCount; k--) {
        final r = m.cardTopLeft(col, k) & m.card;
        if (!r.contains(p)) continue;
        // Açık bölge tek kategoridir: kategori kartı olsun olmasın, tüm açık
        // yığın tek birim olarak taşınır — kartlar birbirinden koparılamaz
        // (kategori kartının kilidiyle aynı davranış).
        const startIndex = 0;
        final ref = ColumnUnitRef(column: col, startIndex: startIndex);
        final resolved = Rules.resolveUnit(state, ref);
        if (resolved is Ok<MovableUnit, RuleViolation>) {
          return _Grab(
            source: ref,
            cards: resolved.data.cards,
            baseTopLeft: m.cardTopLeft(col, faceDownCount + startIndex),
            isCategory: resolved.data is CategoryUnit,
          );
        }
        return null; // isabet var ama tutulamaz
      }
    }
    return null;
  }
}

class _Grab {
  _Grab({
    required this.source,
    required this.cards,
    required this.baseTopLeft,
    required this.isCategory,
  });
  final UnitRef source;
  final List<GameCard> cards;
  final Offset baseTopLeft;
  final bool isCategory;
}

/// Üstteki sayaçlar: kalan hamle + tamamlanan kategori.
class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.movesLeft,
    required this.completed,
    required this.totalCategories,
    required this.colors,
  });
  final int movesLeft;
  final int completed;
  final int totalCategories;
  final GameColors colors;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tile(
            'HAMLE',
            '$movesLeft',
            movesLeft <= 5 ? colors.danger : colors.accent,
          ),
          const SizedBox(width: 14),
          _tile('KATEGORİ', '$completed/$totalCategories', colors.ink),
        ],
      ),
    );
  }

  Widget _tile(String label, String value, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontFamily: Fonts.sans,
              fontWeight: FontWeight.w800,
              fontSize: 29,
              height: 1,
            ),
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: TextStyle(
            color: colors.inkSoft,
            fontFamily: Fonts.sans,
            fontSize: 10,
            letterSpacing: 1.3,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Kategori tamamlandığında kısa süreli kutlama afişi (belirir, solar).
class _CelebrationBanner extends StatelessWidget {
  const _CelebrationBanner({
    super.key,
    required this.text,
    required this.colors,
    required this.reduceMotion,
  });
  final String text;
  final GameColors colors;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    if (reduceMotion) return const SizedBox.shrink();
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Anim.complete,
        curve: Curves.easeOut,
        builder: (context, t, child) {
          // 0.0-0.25 belir, 0.25-1.0 sol.
          final opacity = t < 0.25 ? (t / 0.25) : (1 - (t - 0.25) / 0.75);
          final scale = 0.85 + 0.3 * (t < 0.25 ? t / 0.25 : 1);
          return Opacity(
            opacity: opacity.clamp(0, 1),
            child: Transform.scale(scale: scale, child: child),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: colors.categoryFace,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, color: colors.accent, size: 24),
              const SizedBox(width: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tamamlandı!',
                    style: TextStyle(
                      color: colors.categoryText,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    text,
                    style: TextStyle(
                      color: colors.categoryText.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
