/// Kural doğrulama: birim çözümleme + yerleştirme matrisi (Spec §6.2).
library;

import 'cards.dart';
import 'moves.dart';
import 'result.dart';
import 'state.dart';

/// Kural ihlali kodları (doğrulayıcının sözlüğü — Spec Faz 1 §3.3).
enum RuleViolation {
  notAUnit, // V_NOT_A_UNIT
  targetLocked, // V_TARGET_LOCKED
  catMismatchColumn, // V_CAT_MISMATCH_COLUMN
  emptySlotNeedsCat, // V_EMPTY_SLOT_NEEDS_CAT
  activeSlotNoCat, // V_ACTIVE_SLOT_NO_CAT
  catMismatchSlot, // V_CAT_MISMATCH_SLOT
  drawEmpty, // V_DRAW_EMPTY
  recycleInvalid, // V_RECYCLE_INVALID
  noMovesLeft, // V_NO_MOVES_LEFT
  gameOver, // V_GAME_OVER
  noOp, // V_NO_OP (kaynak == hedef, faydasız)
  slotOverflow, // V_SLOT_OVERFLOW (savunma amaçlı)
}

class Rules {
  const Rules._();

  /// Bir birim referansını kartlara çözer; tutulabilirlik kuralını uygular.
  static Result<MovableUnit, RuleViolation> resolveUnit(
    GameState state,
    UnitRef ref,
  ) {
    switch (ref) {
      case ColumnUnitRef(:final column, :final startIndex):
        if (column < 0 || column >= state.columns.length) {
          return const Err(RuleViolation.notAUnit);
        }
        final col = state.columns[column];
        if (startIndex < 0 || startIndex >= col.faceUp.length) {
          return const Err(RuleViolation.notAUnit);
        }
        if (col.isLocked) {
          // Kategori kartı en üstte. Yalnızca tüm açık bölge (kategori kartı +
          // altındaki tüm eşleşen zincir) taşınabilir — kartı zincirinden
          // ayırmak yasak (K11).
          if (startIndex != 0) {
            return const Err(RuleViolation.notAUnit);
          }
          final card = col.faceUp.last as CategoryCard;
          final swept = col.faceUp
              .sublist(0, col.faceUp.length - 1)
              .cast<WordCard>();
          return Ok(CategoryUnit(card: card, sweptWords: swept));
        } else {
          // Saf kelime zinciri (açık bölge tek kategorili).
          final sub = col.faceUp.sublist(startIndex).cast<WordCard>();
          return Ok(WordUnit(categoryId: sub.first.categoryId, words: sub));
        }
      case WasteUnitRef():
        final top = state.wasteTop;
        if (top == null) return const Err(RuleViolation.notAUnit);
        if (top is CategoryCard) {
          return Ok(CategoryUnit(card: top, sweptWords: const []));
        }
        return Ok(
          WordUnit(categoryId: top.categoryId, words: [top as WordCard]),
        );
    }
  }

  /// Çözümlenmiş bir birimin hedefe yerleştirilebilirliği. null = geçerli.
  static RuleViolation? validatePlace(
    GameState state,
    MovableUnit unit,
    TargetRef target, {
    UnitRef? source,
  }) {
    switch (target) {
      case ColumnTargetRef(:final column):
        if (column < 0 || column >= state.columns.length) {
          return RuleViolation.notAUnit;
        }
        if (source is ColumnUnitRef && source.column == column) {
          return RuleViolation.noOp;
        }
        final col = state.columns[column];
        if (col.isLocked) return RuleViolation.targetLocked;
        if (col.isEmpty) return null; // Boş sütun her birimi kabul eder (K6).
        return col.topCategory == unit.categoryId
            ? null
            : RuleViolation.catMismatchColumn;

      case FoundationTargetRef(:final slot):
        if (slot < 0 || slot >= state.slots.length) {
          return RuleViolation.notAUnit;
        }
        final s = state.slots[slot];
        switch (unit) {
          case WordUnit():
            if (s is! ActiveSlot) return RuleViolation.emptySlotNeedsCat;
            if (s.categoryId != unit.categoryId) {
              return RuleViolation.catMismatchSlot;
            }
            if (s.collected.length + unit.words.length > s.total) {
              return RuleViolation.slotOverflow;
            }
            return null;
          case CategoryUnit():
            if (s is ActiveSlot) return RuleViolation.activeSlotNoCat;
            return null; // Boş slot: aktifleşir + süpürme.
        }
    }
  }

  /// Bir hamlenin tümüyle geçerliliği. null = geçerli.
  static RuleViolation? validate(GameState state, Move move) {
    if (state.status != GameStatus.playing) return RuleViolation.gameOver;
    if (state.movesLeft <= 0) return RuleViolation.noMovesLeft;

    switch (move) {
      case DrawMove():
        return state.stock.isEmpty ? RuleViolation.drawEmpty : null;
      case RecycleMove():
        return (state.stock.isEmpty && state.waste.isNotEmpty)
            ? null
            : RuleViolation.recycleInvalid;
      case PlaceMove(:final unit, :final target):
        final resolved = resolveUnit(state, unit);
        if (resolved is Err<MovableUnit, RuleViolation>) return resolved.cause;
        return validatePlace(state, resolved.value, target, source: unit);
    }
  }
}
