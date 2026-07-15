/// Değişmez oyun durumu ve türetme (deal).
library;

import 'cards.dart';
import 'level.dart';

enum GameStatus { playing, won, lostOutOfMoves, lostDeadlock }

/// Bir oyun alanı sütunu.
///
/// Değişmez. Açık bölge (faceUp) tek kategoriden oluşur; bir kategori kartı
/// içeriyorsa yalnızca en üstte (son eleman) bulunur.
class ColumnPile {
  ColumnPile({required List<GameCard> faceDown, required List<GameCard> faceUp})
    : faceDown = List.unmodifiable(faceDown),
      faceUp = List.unmodifiable(faceUp);

  final List<GameCard> faceDown;
  final List<GameCard> faceUp;

  bool get isEmpty => faceDown.isEmpty && faceUp.isEmpty;

  bool get isLocked => faceUp.isNotEmpty && faceUp.last is CategoryCard;

  /// Açık bölgenin kategorisi (boşsa null). Açık bölge tek kategoriliktir.
  String? get topCategory => faceUp.isEmpty ? null : faceUp.last.categoryId;

  /// En üstteki açık kart (boşsa null).
  GameCard? get top => faceUp.isEmpty ? null : faceUp.last;

  ColumnPile copyWith({List<GameCard>? faceDown, List<GameCard>? faceUp}) =>
      ColumnPile(
        faceDown: faceDown ?? this.faceDown,
        faceUp: faceUp ?? this.faceUp,
      );
}

/// Bir toplama slotu: boş ya da aktif.
sealed class FoundationSlot {
  const FoundationSlot();
  bool get isEmpty => this is EmptySlot;
}

class EmptySlot extends FoundationSlot {
  const EmptySlot();
}

class ActiveSlot extends FoundationSlot {
  ActiveSlot({required this.card, required List<WordCard> collected})
    : collected = List.unmodifiable(collected);

  final CategoryCard card;
  final List<WordCard> collected;

  String get categoryId => card.categoryId;
  int get total => card.totalInLevel;
  bool get isComplete => collected.length >= card.totalInLevel;

  ActiveSlot addWords(List<WordCard> words) =>
      ActiveSlot(card: card, collected: [...collected, ...words]);
}

class GameState {
  GameState({
    required List<ColumnPile> columns,
    required List<FoundationSlot> slots,
    required List<GameCard> stock,
    required List<GameCard> waste,
    required this.movesLeft,
    required this.completedCount,
    required this.status,
    required this.level,
  }) : columns = List.unmodifiable(columns),
       slots = List.unmodifiable(slots),
       stock = List.unmodifiable(stock),
       waste = List.unmodifiable(waste);

  final List<ColumnPile> columns;
  final List<FoundationSlot> slots;

  /// Çekme destesi (üst = son eleman).
  final List<GameCard> stock;

  /// Atık yığını (üst = son eleman).
  final List<GameCard> waste;

  final int movesLeft;
  final int completedCount;
  final GameStatus status;
  final LevelDef level;

  bool get isPlaying => status == GameStatus.playing;
  bool get isWon => status == GameStatus.won;
  bool get isLost =>
      status == GameStatus.lostOutOfMoves || status == GameStatus.lostDeadlock;

  int get totalCategories => level.totalCategories;

  GameCard? get wasteTop => waste.isEmpty ? null : waste.last;

  GameState copyWith({
    List<ColumnPile>? columns,
    List<FoundationSlot>? slots,
    List<GameCard>? stock,
    List<GameCard>? waste,
    int? movesLeft,
    int? completedCount,
    GameStatus? status,
  }) => GameState(
    columns: columns ?? this.columns,
    slots: slots ?? this.slots,
    stock: stock ?? this.stock,
    waste: waste ?? this.waste,
    movesLeft: movesLeft ?? this.movesLeft,
    completedCount: completedCount ?? this.completedCount,
    status: status ?? this.status,
    level: level,
  );

  /// Bir bölüm tanımından başlangıç durumunu kurar.
  static GameState deal(LevelDef level) {
    final columns = <ColumnPile>[
      for (final c in level.columns)
        ColumnPile(faceDown: c.faceDown, faceUp: c.faceUp),
    ];
    final slots = <FoundationSlot>[
      for (var i = 0; i < level.slotCount; i++) const EmptySlot(),
    ];
    return GameState(
      columns: columns,
      slots: slots,
      stock: List.of(level.stock),
      waste: const [],
      movesLeft: level.moveLimit,
      completedCount: 0,
      status: GameStatus.playing,
      level: level,
    );
  }
}
