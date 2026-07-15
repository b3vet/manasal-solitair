/// Reducer: bir hamleyi uygular, yeni durumu ve olay listesini üretir.
library;

import 'analysis.dart';
import 'cards.dart';
import 'events.dart';
import 'moves.dart';
import 'result.dart';
import 'rules.dart';
import 'state.dart';

class ApplyResult {
  const ApplyResult({required this.next, required this.events});
  final GameState next;
  final List<GameEvent> events;
}

class Reducer {
  const Reducer._();

  static Result<ApplyResult, RuleViolation> apply(GameState state, Move move) {
    final violation = Rules.validate(state, move);
    if (violation != null) return Err(violation);

    return switch (move) {
      DrawMove() => Ok(_finalize(_applyDraw(state))),
      RecycleMove() => Ok(_finalize(_applyRecycle(state))),
      PlaceMove() => Ok(_finalize(_applyPlace(state, move))),
    };
  }

  static _Draft _applyDraw(GameState state) {
    final stock = List<GameCard>.of(state.stock);
    final card = stock.removeLast();
    final waste = [...state.waste, card];
    return _Draft(
      state.copyWith(
        stock: stock,
        waste: waste,
        movesLeft: state.movesLeft - 1,
      ),
      [DrewEvent(card)],
    );
  }

  static _Draft _applyRecycle(GameState state) {
    final stock = state.waste.reversed.toList();
    return _Draft(
      state.copyWith(
        stock: stock,
        waste: const [],
        movesLeft: state.movesLeft - 1,
      ),
      [RecycledEvent(stock.length)],
    );
  }

  static _Draft _applyPlace(GameState state, PlaceMove move) {
    // Doğrulamadan geçtiği için çözümleme kesin başarılı.
    final unit =
        (Rules.resolveUnit(state, move.unit) as Ok<MovableUnit, RuleViolation>)
            .data;

    final columns = List<ColumnPile>.of(state.columns);
    final slots = List<FoundationSlot>.of(state.slots);
    var waste = List<GameCard>.of(state.waste);
    var completed = state.completedCount;
    final events = <GameEvent>[];

    // 1) Birimi kaynaktan çıkar.
    int? sourceColumn;
    switch (move.unit) {
      case ColumnUnitRef(:final column, :final startIndex):
        sourceColumn = column;
        final src = columns[column];
        columns[column] = src.copyWith(
          faceUp: src.faceUp.sublist(0, startIndex),
        );
      case WasteUnitRef():
        waste = waste.sublist(0, waste.length - 1);
    }

    // 2) Hedefe ekle.
    switch (move.target) {
      case ColumnTargetRef(:final column):
        final tgt = columns[column];
        columns[column] = tgt.copyWith(faceUp: [...tgt.faceUp, ...unit.cards]);
        events.add(
          UnitPlacedEvent(unit: unit, from: move.unit, target: move.target),
        );
      case FoundationTargetRef(:final slot):
        switch (unit) {
          case WordUnit():
            final active = slots[slot] as ActiveSlot;
            slots[slot] = active.addWords(unit.words);
            events.add(WordsCollectedEvent(slot: slot, words: unit.words));
          case CategoryUnit():
            slots[slot] = ActiveSlot(
              card: unit.card,
              collected: unit.sweptWords,
            );
            events.add(
              SlotActivatedEvent(
                slot: slot,
                card: unit.card,
                sweptWords: unit.sweptWords,
              ),
            );
        }
        // Tamamlanma kontrolü.
        final s = slots[slot];
        if (s is ActiveSlot && s.isComplete) {
          slots[slot] = const EmptySlot();
          completed += 1;
          events.add(
            CategoryCompletedEvent(slot: slot, categoryId: s.categoryId),
          );
        }
    }

    // 3) Kaynak sütunun kapalı kartını otomatik aç (bedava).
    if (sourceColumn != null) {
      final src = columns[sourceColumn];
      if (src.faceUp.isEmpty && src.faceDown.isNotEmpty) {
        final faceDown = List<GameCard>.of(src.faceDown);
        final revealed = faceDown.removeLast();
        columns[sourceColumn] = ColumnPile(
          faceDown: faceDown,
          faceUp: [revealed],
        );
        events.add(FlippedEvent(column: sourceColumn, card: revealed));
      }
    }

    return _Draft(
      state.copyWith(
        columns: columns,
        slots: slots,
        waste: waste,
        completedCount: completed,
        movesLeft: state.movesLeft - 1,
      ),
      events,
    );
  }

  /// Hamle sonrası kazanma/kaybetme statüsünü belirler ve olayı ekler.
  static ApplyResult _finalize(_Draft draft) {
    final s = draft.state;
    GameStatus status;
    if (s.completedCount >= s.level.totalCategories) {
      status = GameStatus.won;
    } else if (s.movesLeft <= 0) {
      status = GameStatus.lostOutOfMoves;
    } else if (Analysis.isDeadlocked(s)) {
      status = GameStatus.lostDeadlock;
    } else {
      status = GameStatus.playing;
    }

    final events = draft.events;
    if (status != GameStatus.playing) {
      events.add(GameEndedEvent(status));
    }
    return ApplyResult(
      next: s.copyWith(status: status),
      events: events,
    );
  }
}

class _Draft {
  _Draft(this.state, this.events);
  final GameState state;
  final List<GameEvent> events;
}
