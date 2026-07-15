/// Legal hamle üretimi ve çıkmaz (deadlock) tespiti.
library;

import 'cards.dart';
import 'moves.dart';
import 'result.dart';
import 'rules.dart';
import 'state.dart';

class Analysis {
  const Analysis._();

  /// Tüm geçerli hamleler (çekme, devir ve yerleştirmeler).
  static List<Move> legalMoves(GameState state) {
    final moves = <Move>[];
    if (state.status != GameStatus.playing || state.movesLeft <= 0) {
      return moves;
    }
    if (state.stock.isNotEmpty) moves.add(const DrawMove());
    if (state.stock.isEmpty && state.waste.isNotEmpty) {
      moves.add(const RecycleMove());
    }
    for (final m in _placeMoves(state)) {
      moves.add(m);
    }
    return moves;
  }

  /// Yalnızca yerleştirme hamleleri (tahtayı değiştirenler).
  static List<PlaceMove> placeMoves(GameState state) =>
      _placeMoves(state).toList();

  static Iterable<PlaceMove> _placeMoves(GameState state) sync* {
    final sources = <UnitRef>[];
    if (state.waste.isNotEmpty) sources.add(const WasteUnitRef());
    for (var c = 0; c < state.columns.length; c++) {
      final col = state.columns[c];
      if (col.faceUp.isEmpty) continue;
      if (col.isLocked) {
        sources.add(ColumnUnitRef(column: c, startIndex: 0));
      } else {
        for (var i = 0; i < col.faceUp.length; i++) {
          sources.add(ColumnUnitRef(column: c, startIndex: i));
        }
      }
    }

    final targets = <TargetRef>[
      for (var c = 0; c < state.columns.length; c++) ColumnTargetRef(c),
      for (var s = 0; s < state.slots.length; s++) FoundationTargetRef(s),
    ];

    for (final src in sources) {
      final resolved = Rules.resolveUnit(state, src);
      if (resolved is! Ok<MovableUnit, RuleViolation>) continue;
      final unit = resolved.data;
      for (final tgt in targets) {
        if (Rules.validatePlace(state, unit, tgt, source: src) == null) {
          yield PlaceMove(unit: src, target: tgt);
        }
      }
    }
  }

  /// Tahtayı değiştiren en az bir yerleştirme var mı?
  static bool hasBoardMove(GameState state) => _placeMoves(state).isNotEmpty;

  /// Spec §9.3: (1) hiçbir legal yerleştirme yok VE (2) deste/atıktaki hiçbir
  /// kartın mevcut tahtada geçerli hedefi yok → çıkmaz.
  static bool isDeadlocked(GameState state) {
    if (state.status != GameStatus.playing) return false;
    if (hasBoardMove(state)) return false;
    // Deste ve atıktaki kartlar çekme/devirle er geç oynanabilir hale gelir.
    final pileCards = [...state.stock, ...state.waste];
    for (final card in pileCards) {
      if (_isPlaceableSomewhere(state, card)) return false;
    }
    return true;
  }

  /// Oyuncuya önerilecek "iyi" bir hamle (ipucu). Üretken hamleleri
  /// önceliklendirir: toplama > kategori kartı yerleştirme / kapalı kart açma >
  /// çekme > sade birleştirme > devir. Çıkmazda null.
  static Move? suggestHint(GameState state) {
    if (state.status != GameStatus.playing) return null;
    PlaceMove? best;
    var bestScore = 0;
    for (final pm in _placeMoves(state)) {
      final s = _hintScore(state, pm);
      if (s > bestScore) {
        bestScore = s;
        best = pm;
      }
    }
    // Yüksek değerli tahta hamlesi varsa onu öner.
    if (best != null && bestScore >= 40) return best;
    // Yoksa yeni kart açmak için çekmeyi öner.
    if (state.stock.isNotEmpty) return const DrawMove();
    // Yoksa elde ne varsa.
    if (best != null) return best;
    if (state.waste.isNotEmpty) return const RecycleMove();
    return null;
  }

  static int _hintScore(GameState state, PlaceMove pm) {
    final resolved = Rules.resolveUnit(state, pm.unit);
    if (resolved is! Ok<MovableUnit, RuleViolation>) return 0;
    final unit = resolved.data;
    final target = pm.target;

    if (target is FoundationTargetRef) {
      final slot = state.slots[target.slot];
      if (unit is WordUnit) {
        if (slot is ActiveSlot &&
            slot.collected.length + unit.words.length >= slot.total) {
          return 100; // kategoriyi tamamlar
        }
        return 80; // kelime toplar
      }
      if (unit is CategoryUnit) {
        if (unit.sweptWords.length >= unit.card.totalInLevel) return 100;
        return 70; // slot aktifleştirir
      }
    } else if (target is ColumnTargetRef) {
      final src = pm.unit;
      final unbury =
          src is ColumnUnitRef &&
          src.startIndex == 0 &&
          state.columns[src.column].faceDown.isNotEmpty;
      if (unit is CategoryUnit) return unbury ? 60 : 55;
      return unbury ? 50 : 20; // kelime: kapalı kart açar / sade birleştirme
    }
    return 0;
  }

  static bool _isPlaceableSomewhere(GameState state, GameCard card) {
    var hasEmptyColumn = false;
    final unlockedTops = <String>{};
    for (final col in state.columns) {
      if (col.isEmpty) {
        hasEmptyColumn = true;
      } else if (!col.isLocked) {
        unlockedTops.add(col.topCategory!);
      }
    }
    if (hasEmptyColumn) return true; // Boş sütun her kartı kabul eder.

    if (card is WordCard) {
      if (unlockedTops.contains(card.categoryId)) return true;
      for (final s in state.slots) {
        if (s is ActiveSlot && s.categoryId == card.categoryId) return true;
      }
      return false;
    } else {
      // Kategori kartı: eşleşen zincir veya boş slot.
      if (unlockedTops.contains(card.categoryId)) return true;
      return state.slots.any((s) => s.isEmpty);
    }
  }
}
