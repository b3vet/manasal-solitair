/// Kart modelleri. Saf veri; değişmez (immutable).
library;

sealed class GameCard {
  const GameCard(this.id);

  /// Bölüm içinde benzersiz kimlik (ör. "w:meyveler:3", "c:meyveler").
  final String id;

  String get categoryId;
}

/// Üzerinde bir kelime yazan düz kart.
class WordCard extends GameCard {
  const WordCard({
    required String id,
    required this.word,
    required this.categoryId,
  }) : super(id);

  final String word;

  @override
  final String categoryId;

  @override
  bool operator ==(Object other) => other is WordCard && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'W($word)';
}

/// Bir kategoriyi temsil eden özel kart (iskambildeki as gibi).
class CategoryCard extends GameCard {
  const CategoryCard({
    required String id,
    required this.categoryId,
    required this.name,
    required this.totalInLevel,
  }) : super(id);

  /// Kategorinin görünen adı (ör. "Meyveler").
  final String name;

  /// Bu bölümde bu kategoriden kaç kelime kartı olduğu.
  final int totalInLevel;

  @override
  final String categoryId;

  @override
  bool operator ==(Object other) => other is CategoryCard && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'C($name/$totalInLevel)';
}
