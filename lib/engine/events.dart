/// Reducer'ın ürettiği oyun olayları — UI animasyon kuyruğunun dili.
library;

import 'cards.dart';
import 'moves.dart';
import 'state.dart';

sealed class GameEvent {
  const GameEvent();
}

class DrewEvent extends GameEvent {
  const DrewEvent(this.card);
  final GameCard card;
}

class RecycledEvent extends GameEvent {
  const RecycledEvent(this.count);
  final int count;
}

/// Bir birim, kaynak yığından hedefe taşındı.
class UnitPlacedEvent extends GameEvent {
  const UnitPlacedEvent({
    required this.unit,
    required this.from,
    required this.target,
  });
  final MovableUnit unit;
  final UnitRef from;
  final TargetRef target;
}

/// Bir sütunun kapalı kartı otomatik açıldı (bedava).
class FlippedEvent extends GameEvent {
  const FlippedEvent({required this.column, required this.card});
  final int column;
  final GameCard card;
}

/// Boş bir slot, kategori kartıyla aktifleşti (süpürülen kelimeler dahil).
class SlotActivatedEvent extends GameEvent {
  const SlotActivatedEvent({
    required this.slot,
    required this.card,
    required this.sweptWords,
  });
  final int slot;
  final CategoryCard card;
  final List<WordCard> sweptWords;
}

/// Aktif bir slota kelime(ler) toplandı.
class WordsCollectedEvent extends GameEvent {
  const WordsCollectedEvent({required this.slot, required this.words});
  final int slot;
  final List<WordCard> words;
}

/// Bir kategori tamamlandı; slot boşaldı.
class CategoryCompletedEvent extends GameEvent {
  const CategoryCompletedEvent({required this.slot, required this.categoryId});
  final int slot;
  final String categoryId;
}

class GameEndedEvent extends GameEvent {
  const GameEndedEvent(this.status);
  final GameStatus status;
}
