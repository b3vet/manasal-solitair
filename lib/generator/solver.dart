/// Bölüm çözücü: bir dağıtımın çözülebilirliğini kanıtlar ve çözüm bulur.
///
/// Makro-çekiş (Spec §11.2): deste tek tek çekilerek DEĞİL, "bir deste kartını
/// yüzeye getir + oyna" bileşik eylemiyle aranır. Bu, arama derinliğini üretken
/// hamle sayısıyla sınırlar (deste döngüsü dallanmayı patlatmaz). DFS +
/// transposition (kanonik imza) budaması + düğüm/derinlik bütçesi.
library;

import '../engine/analysis.dart';
import '../engine/cards.dart';
import '../engine/level.dart';
import '../engine/moves.dart';
import '../engine/reducer.dart';
import '../engine/result.dart';
import '../engine/rules.dart';
import '../engine/state.dart';

class SolveResult {
  const SolveResult({
    required this.solved,
    required this.moveCount,
    required this.nodes,
    this.solution,
  });
  final bool solved;
  final int moveCount;
  final int nodes;
  final List<Move>? solution;
}

class Solver {
  const Solver._();

  static SolveResult solve(
    LevelDef level, {
    int maxNodes = 250000,
    int maxDepth = 400,
  }) {
    final solveLevel = level.copyWith(moveLimit: 1 << 30);
    final start = GameState.deal(solveLevel);
    final visited = <String>{};
    final solution = <Move>[];
    var nodes = 0;
    var exhausted = false;

    bool dfs(GameState s, int depth) {
      if (s.isWon) return true;
      if (nodes >= maxNodes) {
        exhausted = true;
        return false;
      }
      if (depth >= maxDepth) return false;
      nodes++;
      if (!visited.add(_sig(s))) return false;

      final actions = _actions(s);
      for (final act in actions) {
        var cur = s;
        var ok = true;
        for (final mv in act) {
          final r = Reducer.apply(cur, mv);
          if (r is! Ok<ApplyResult, RuleViolation>) {
            ok = false;
            break;
          }
          cur = r.data.next;
          if (cur.status == GameStatus.lostDeadlock) {
            ok = false;
            break;
          }
        }
        if (!ok) continue;
        for (final mv in act) {
          solution.add(mv);
        }
        if (dfs(cur, depth + 1)) return true;
        for (var i = 0; i < act.length; i++) {
          solution.removeLast();
        }
        if (exhausted) return false;
      }
      return false;
    }

    final ok = dfs(start, 0);
    return SolveResult(
      solved: ok,
      moveCount: ok ? solution.length : 0,
      nodes: nodes,
      solution: ok ? List<Move>.of(solution) : null,
    );
  }

  /// Bir durumdan üretken eylemler (her biri ilkel hamle listesi).
  static List<List<Move>> _actions(GameState s) {
    final out = <List<Move>>[];

    // 1) Tahta yerleştirmeleri (sütun kaynakları + mevcut atık üstü).
    for (final pm in Analysis.placeMoves(s)) {
      out.add([pm]);
    }

    // 2) Deste makroları: gömülü deste kartını yüzeye getir + oyna.
    final deck = [...s.stock, ...s.waste];
    final currentWasteTop = s.waste.isEmpty ? null : s.waste.last.id;
    final considered = <String>{};
    for (final card in deck) {
      if (card.id == currentWasteTop) continue; // atık üstü zaten (1)'de
      if (!considered.add(card.id)) continue;
      final targets = _singleTargets(s, card);
      if (targets.isEmpty) continue;
      final surface = _surface(s, card.id);
      if (surface == null || surface.isEmpty) continue;
      for (final t in targets) {
        out.add([...surface, PlaceMove(unit: const WasteUnitRef(), target: t)]);
      }
    }

    // Öncelik: toplama hedefli > sütun hedefli; kısa diziler önce.
    out.sort((a, b) {
      final pa = _actionPriority(a);
      final pb = _actionPriority(b);
      if (pa != pb) return pb.compareTo(pa);
      return a.length.compareTo(b.length);
    });
    return out;
  }

  static int _actionPriority(List<Move> act) {
    final last = act.last;
    if (last is PlaceMove && last.target is FoundationTargetRef) return 3;
    if (last is PlaceMove) return 2;
    return 1;
  }

  /// Tek bir kartın (word/category) mevcut tahtada geçerli hedefleri.
  static List<TargetRef> _singleTargets(GameState s, GameCard card) {
    final targets = <TargetRef>[];
    for (var c = 0; c < s.columns.length; c++) {
      final col = s.columns[c];
      if (col.isLocked) continue;
      if (col.isEmpty) {
        targets.add(ColumnTargetRef(c));
      } else if (col.topCategory == card.categoryId) {
        targets.add(ColumnTargetRef(c));
      }
    }
    for (var i = 0; i < s.slots.length; i++) {
      final slot = s.slots[i];
      if (card is CategoryCard) {
        if (slot.isEmpty) targets.add(FoundationTargetRef(i));
      } else {
        if (slot is ActiveSlot && slot.categoryId == card.categoryId) {
          targets.add(FoundationTargetRef(i));
        }
      }
    }
    return targets;
  }

  /// Bir deste kartını atık üstüne getiren çekme/devir dizisi (ya da null).
  static List<Move>? _surface(GameState s, String cardId) {
    var stock = List<GameCard>.of(s.stock);
    var waste = List<GameCard>.of(s.waste);
    final moves = <Move>[];
    final limit = stock.length + waste.length + 2;
    for (var step = 0; step < limit; step++) {
      if (waste.isNotEmpty && waste.last.id == cardId) return moves;
      if (stock.isNotEmpty) {
        waste.add(stock.removeLast());
        moves.add(const DrawMove());
      } else if (waste.isNotEmpty) {
        stock = waste.reversed.toList();
        waste = [];
        moves.add(const RecycleMove());
      } else {
        return null;
      }
    }
    return null;
  }

  static String _sig(GameState s) {
    final cols = [
      for (final col in s.columns)
        '${col.faceDown.map((c) => c.id).join(",")}|'
            '${col.faceUp.map((c) => c.id).join(",")}',
    ]..sort();
    final slots = [
      for (final slot in s.slots)
        slot is ActiveSlot ? '${slot.categoryId}:${slot.collected.length}' : 'e',
    ]..sort();
    return '${cols.join(";")}#'
        '${s.stock.map((c) => c.id).join(",")}#'
        '${s.waste.map((c) => c.id).join(",")}#'
        '${slots.join(",")}';
  }
}
