/// Hamleler, birim/hedef referansları ve çözümlenmiş taşınabilir birimler.
library;

import 'cards.dart';

/// Motorun tek giriş noktası: bir hamle.
sealed class Move {
  const Move();
}

/// Desteden bir kart çek (atığın üstüne).
class DrawMove extends Move {
  const DrawMove();
}

/// Atığı ters çevirip yeniden deste yap (deste boş + atık dolu iken).
class RecycleMove extends Move {
  const RecycleMove();
}

/// Bir birimi bir hedefe yerleştir.
class PlaceMove extends Move {
  const PlaceMove({required this.unit, required this.target});
  final UnitRef unit;
  final TargetRef target;
}

// --- Birim referansları (kaynak) ---

sealed class UnitRef {
  const UnitRef();
}

/// Bir sütunun açık bölgesinde [startIndex]'ten tepeye kadarki kartlar.
class ColumnUnitRef extends UnitRef {
  const ColumnUnitRef({required this.column, required this.startIndex});
  final int column;
  final int startIndex;

  @override
  bool operator ==(Object other) =>
      other is ColumnUnitRef &&
      other.column == column &&
      other.startIndex == startIndex;

  @override
  int get hashCode => Object.hash(column, startIndex);
}

/// Atığın en üstündeki tek kart.
class WasteUnitRef extends UnitRef {
  const WasteUnitRef();

  @override
  bool operator ==(Object other) => other is WasteUnitRef;

  @override
  int get hashCode => 7919;
}

// --- Hedef referansları ---

sealed class TargetRef {
  const TargetRef();
}

class ColumnTargetRef extends TargetRef {
  const ColumnTargetRef(this.column);
  final int column;

  @override
  bool operator ==(Object other) =>
      other is ColumnTargetRef && other.column == column;

  @override
  int get hashCode => column;
}

class FoundationTargetRef extends TargetRef {
  const FoundationTargetRef(this.slot);
  final int slot;

  @override
  bool operator ==(Object other) =>
      other is FoundationTargetRef && other.slot == slot;

  @override
  int get hashCode => 100 + slot;
}

// --- Çözümlenmiş taşınabilir birim ---

sealed class MovableUnit {
  const MovableUnit();
  String get categoryId;

  /// Birimdeki tüm kartlar (alt → üst).
  List<GameCard> get cards;
}

/// 1..n adet aynı kategoriden kelime kartı.
class WordUnit extends MovableUnit {
  const WordUnit({required this.categoryId, required this.words});
  @override
  final String categoryId;
  final List<WordCard> words;

  @override
  List<GameCard> get cards => words;
}

/// Bir kategori kartı + altındaki eşleşen kelime zinciri (süpürme birimi).
/// [sweptWords] boş olabilir (tek başına kategori kartı).
class CategoryUnit extends MovableUnit {
  const CategoryUnit({required this.card, required this.sweptWords});
  final CategoryCard card;
  final List<WordCard> sweptWords;

  @override
  String get categoryId => card.categoryId;

  @override
  List<GameCard> get cards => [...sweptWords, card];
}
