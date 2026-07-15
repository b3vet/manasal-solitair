/// Oyun tahtası: kartların yerleşimi, sürükle-bırak ve hareket animasyonları.
///
/// Her kart AnimatedPositioned'dır (kimliğe göre); motor bir hamleyi
/// uyguladığında kartlar yeni yuvalarına akar. Sürüklenen birim parmağı
/// gecikmesiz takip eder; bırakınca geçerliyse yeni yuvaya, değilse eskisine
/// yumuşakça döner. İpucu sızdırmaz: kelime sürüklenirken hedef VURGULANMAZ
/// (Spec K15).
library;

import 'package:flutter/material.dart';

import '../../engine/engine.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'board_metrics.dart';
import 'game_controller.dart';
import 'widgets/cards.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key, required this.controller});
  final GameController controller;

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

class _GameBoardState extends State<GameBoard> {
  _DragState? _drag;

  GameController get c => widget.controller;
  GameState get state => c.state;

  @override
  void initState() {
    super.initState();
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
    c.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() => _drag = null);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final counts = [
          for (final col in state.columns) col.faceDown.length + col.faceUp.length,
        ];
        final m = BoardMetrics(
          size: size,
          columnCount: state.columns.length,
          slotCount: state.slots.length,
          columnCounts: counts,
        );

        final children = <Widget>[];
        children.addAll(_slotFrames(m, colors));
        children.addAll(_columnFrames(m, colors));
        children.addAll(_pileFrames(m, colors));
        children.addAll(_cards(m, colors));

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
        out.add(_positioned('slot_empty_$i', m.slotTopLeft(i), m.card,
            EmptyFrameView(size: m.card, colors: colors, icon: Icons.add)));
      }
    }
    return out;
  }

  List<Widget> _columnFrames(BoardMetrics m, GameColors colors) {
    final out = <Widget>[];
    for (var col = 0; col < state.columns.length; col++) {
      if (state.columns[col].isEmpty) {
        out.add(_positioned('col_empty_$col', m.columnTopLeft(col), m.card,
            EmptyFrameView(size: m.card, colors: colors)));
      }
    }
    return out;
  }

  List<Widget> _pileFrames(BoardMetrics m, GameColors colors) {
    final out = <Widget>[];
    if (state.stock.isEmpty) {
      out.add(_positioned('stock_empty', m.stockTopLeft(), m.card,
          EmptyFrameView(size: m.card, colors: colors, icon: Icons.refresh)));
    }
    if (state.waste.isEmpty) {
      out.add(_positioned('waste_empty', m.wasteTopLeft(), m.card,
          EmptyFrameView(size: m.card, colors: colors)));
    }
    return out;
  }

  // --- Kartlar ---

  List<Widget> _cards(BoardMetrics m, GameColors colors) {
    final dragIds = _drag == null ? const <String>{} : {for (final c in _drag!.cards) c.id};
    final normal = <Widget>[];
    final dragged = <Widget>[];

    // Toplama slotlarındaki kategori kartları.
    for (var i = 0; i < state.slots.length; i++) {
      final slot = state.slots[i];
      if (slot is ActiveSlot) {
        normal.add(_positioned(
          slot.card.id,
          m.slotTopLeft(i),
          m.card,
          CategoryCardView(
            card: slot.card,
            size: m.card,
            colors: colors,
            collected: slot.collected.length,
          ),
        ));
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
        normal.add(_positioned(
          card.id,
          home,
          m.card,
          _cardWidget(card, colors, m.card,
              faceUp: faceUp, locked: column.isLocked),
        ));
      }
    }

    // Deste üstü (kapalı) + atık üstü (açık).
    if (state.stock.isNotEmpty) {
      final top = state.stock.last;
      normal.add(_positioned('stocktop_${top.id}', m.stockTopLeft(), m.card,
          CardBackView(size: m.card, colors: colors)));
    }
    if (state.waste.isNotEmpty) {
      final top = state.waste.last;
      if (!dragIds.contains(top.id)) {
        normal.add(_positioned(top.id, m.wasteTopLeft(), m.card,
            _cardWidget(top, colors, m.card, faceUp: true, locked: false)));
      }
    }

    // Sürüklenen birim (parmağı takip eder, en üstte).
    if (_drag != null) {
      final d = _drag!;
      for (var j = 0; j < d.cards.length; j++) {
        final card = d.cards[j];
        final pos = d.pointer - d.baseDelta + Offset(0, j * m.step);
        dragged.add(_positioned(
          card.id,
          pos,
          m.card,
          _cardWidget(card, colors, m.card,
              faceUp: true, locked: false, raised: true),
          instant: true,
        ));
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
      return WordCardView(card: card, size: size, colors: colors, raised: raised);
    }
    return CategoryCardView(
      card: card as CategoryCard,
      size: size,
      colors: colors,
      locked: locked,
      raised: raised,
    );
  }

  Widget _positioned(String id, Offset topLeft, Size size, Widget child,
      {bool instant = false}) {
    return AnimatedPositioned(
      key: ValueKey(id),
      duration: instant ? Duration.zero : Durations.place,
      curve: Curves.easeOutCubic,
      left: topLeft.dx,
      top: topLeft.dy,
      width: size.width,
      height: size.height,
      child: child,
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
        final faceUpIndex = k - faceDownCount;
        final startIndex = column.isLocked ? 0 : faceUpIndex;
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
