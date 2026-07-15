/// (De)serileştirme: kartlar, bölümler, hamleler ve durum → JSON.
///
/// Bölümler `levels.json`'da, resume kayıtları hamle listesi (replay) olarak
/// saklanır. Durum JSON'u tanılama/eşitlik testleri içindir.
library;

import 'cards.dart';
import 'level.dart';
import 'moves.dart';
import 'state.dart';

class Serde {
  const Serde._();

  // --- Kartlar ---

  static Map<String, dynamic> cardToJson(GameCard card) => switch (card) {
    WordCard(:final id, :final word, :final categoryId) => {
      't': 'w',
      'id': id,
      'w': word,
      'c': categoryId,
    },
    CategoryCard(
      :final id,
      :final categoryId,
      :final name,
      :final totalInLevel,
    ) =>
      {'t': 'c', 'id': id, 'c': categoryId, 'n': name, 'tot': totalInLevel},
  };

  static GameCard cardFromJson(Map<String, dynamic> j) {
    final type = j['t'] as String;
    if (type == 'w') {
      return WordCard(
        id: j['id'] as String,
        word: j['w'] as String,
        categoryId: j['c'] as String,
      );
    }
    return CategoryCard(
      id: j['id'] as String,
      categoryId: j['c'] as String,
      name: j['n'] as String,
      totalInLevel: j['tot'] as int,
    );
  }

  // --- Bölüm ---

  static Map<String, dynamic> levelToJson(LevelDef level) => {
    'id': level.id,
    'seed': level.seed,
    'columnCount': level.columnCount,
    'slotCount': level.slotCount,
    'moveLimit': level.moveLimit,
    'generatorVersion': level.generatorVersion,
    'categories': [
      for (final c in level.categories)
        {'id': c.categoryId, 'name': c.name, 'total': c.totalWords},
    ],
    'columns': [
      for (final col in level.columns)
        {
          'down': [for (final c in col.faceDown) cardToJson(c)],
          'up': [for (final c in col.faceUp) cardToJson(c)],
        },
    ],
    'stock': [for (final c in level.stock) cardToJson(c)],
  };

  static LevelDef levelFromJson(Map<String, dynamic> j) => LevelDef(
    id: j['id'] as int,
    seed: j['seed'] as int,
    columnCount: j['columnCount'] as int? ?? 5,
    slotCount: j['slotCount'] as int? ?? 5,
    moveLimit: j['moveLimit'] as int,
    generatorVersion: j['generatorVersion'] as int? ?? 1,
    categories: [
      for (final c in (j['categories'] as List).cast<Map<String, dynamic>>())
        LevelCategory(
          categoryId: c['id'] as String,
          name: c['name'] as String,
          totalWords: c['total'] as int,
        ),
    ],
    columns: [
      for (final col in (j['columns'] as List).cast<Map<String, dynamic>>())
        ColumnDeal(
          faceDown: [
            for (final c in (col['down'] as List).cast<Map<String, dynamic>>())
              cardFromJson(c),
          ],
          faceUp: [
            for (final c in (col['up'] as List).cast<Map<String, dynamic>>())
              cardFromJson(c),
          ],
        ),
    ],
    stock: [
      for (final c in (j['stock'] as List).cast<Map<String, dynamic>>())
        cardFromJson(c),
    ],
  );

  // --- Hamleler (replay/resume) ---

  static Map<String, dynamic> moveToJson(Move move) => switch (move) {
    DrawMove() => {'m': 'draw'},
    RecycleMove() => {'m': 'recycle'},
    PlaceMove(:final unit, :final target) => {
      'm': 'place',
      'unit': _unitToJson(unit),
      'target': _targetToJson(target),
    },
  };

  static Move moveFromJson(Map<String, dynamic> j) {
    switch (j['m'] as String) {
      case 'draw':
        return const DrawMove();
      case 'recycle':
        return const RecycleMove();
      case 'place':
        return PlaceMove(
          unit: _unitFromJson(j['unit'] as Map<String, dynamic>),
          target: _targetFromJson(j['target'] as Map<String, dynamic>),
        );
      default:
        throw ArgumentError('Bilinmeyen hamle: ${j['m']}');
    }
  }

  static Map<String, dynamic> _unitToJson(UnitRef u) => switch (u) {
    ColumnUnitRef(:final column, :final startIndex) => {
      'k': 'col',
      'c': column,
      'i': startIndex,
    },
    WasteUnitRef() => {'k': 'waste'},
  };

  static UnitRef _unitFromJson(Map<String, dynamic> j) =>
      (j['k'] as String) == 'waste'
      ? const WasteUnitRef()
      : ColumnUnitRef(column: j['c'] as int, startIndex: j['i'] as int);

  static Map<String, dynamic> _targetToJson(TargetRef t) => switch (t) {
    ColumnTargetRef(:final column) => {'k': 'col', 'c': column},
    FoundationTargetRef(:final slot) => {'k': 'slot', 's': slot},
  };

  static TargetRef _targetFromJson(Map<String, dynamic> j) =>
      (j['k'] as String) == 'slot'
      ? FoundationTargetRef(j['s'] as int)
      : ColumnTargetRef(j['c'] as int);

  static List<Map<String, dynamic>> movesToJson(List<Move> moves) => [
    for (final m in moves) moveToJson(m),
  ];

  static List<Move> movesFromJson(List<dynamic> j) => [
    for (final m in j.cast<Map<String, dynamic>>()) moveFromJson(m),
  ];

  // --- Durum (tanılama/eşitlik) ---

  static Map<String, dynamic> stateToJson(GameState s) => {
    'movesLeft': s.movesLeft,
    'completed': s.completedCount,
    'status': s.status.name,
    'columns': [
      for (final col in s.columns)
        {
          'down': [for (final c in col.faceDown) c.id],
          'up': [for (final c in col.faceUp) c.id],
        },
    ],
    'slots': [
      for (final slot in s.slots)
        switch (slot) {
          EmptySlot() => {'e': true},
          ActiveSlot(:final card, :final collected) => {
            'cat': card.categoryId,
            'got': [for (final w in collected) w.id],
            'tot': card.totalInLevel,
          },
        },
    ],
    'stock': [for (final c in s.stock) c.id],
    'waste': [for (final c in s.waste) c.id],
  };
}
