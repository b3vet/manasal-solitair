// Motor testleri için ortak yardımcılar ve fixture'lar.
import 'package:manasal_solitaire/engine/engine.dart';

WordCard w(String cat, int n) =>
    WordCard(id: 'w:$cat:$n', word: '${cat}_$n', categoryId: cat);

CategoryCard cc(String cat, int total, {String? name}) => CategoryCard(
  id: 'c:$cat',
  categoryId: cat,
  name: name ?? cat,
  totalInLevel: total,
);

ColumnPile col({
  List<GameCard> down = const [],
  List<GameCard> up = const [],
}) => ColumnPile(faceDown: down, faceUp: up);

/// Rastgele bir orta-oyun durumu kurar (kural/reducer testleri için).
GameState st({
  required List<ColumnPile> columns,
  required Map<String, int> categories,
  List<FoundationSlot>? slots,
  List<GameCard> stock = const [],
  List<GameCard> waste = const [],
  int movesLeft = 100,
  int completed = 0,
  int slotCount = 5,
  GameStatus status = GameStatus.playing,
}) {
  final level = LevelDef(
    id: 1,
    seed: 0,
    columns: const [],
    stock: const [],
    categories: [
      for (final e in categories.entries)
        LevelCategory(categoryId: e.key, name: e.key, totalWords: e.value),
    ],
    moveLimit: movesLeft,
    columnCount: columns.length,
    slotCount: slotCount,
  );
  return GameState(
    columns: columns,
    slots: slots ?? List<FoundationSlot>.filled(slotCount, const EmptySlot()),
    stock: stock,
    waste: waste,
    movesLeft: movesLeft,
    completedCount: completed,
    status: status,
    level: level,
  );
}

ActiveSlot active(String cat, int total, List<WordCard> got) =>
    ActiveSlot(card: cc(cat, total), collected: got);

/// Elle kurgulanmış, bilinen çözümü olan mini bölüm (2 kategori, 6 kart).
LevelDef miniLevel({int moveLimit = 15}) {
  return LevelDef(
    id: 1,
    seed: 1,
    moveLimit: moveLimit,
    categories: const [
      LevelCategory(categoryId: 'meyveler', name: 'Meyveler', totalWords: 2),
      LevelCategory(categoryId: 'hayvanlar', name: 'Hayvanlar', totalWords: 2),
    ],
    columns: const [
      ColumnDeal(
        faceDown: [],
        faceUp: [
          WordCard(id: 'w:meyveler:1', word: 'Elma', categoryId: 'meyveler'),
        ],
      ),
      ColumnDeal(
        faceDown: [],
        faceUp: [
          WordCard(id: 'w:meyveler:2', word: 'Armut', categoryId: 'meyveler'),
        ],
      ),
      ColumnDeal(
        faceDown: [],
        faceUp: [
          WordCard(id: 'w:hayvanlar:1', word: 'Kedi', categoryId: 'hayvanlar'),
        ],
      ),
      ColumnDeal(
        faceDown: [],
        faceUp: [
          WordCard(id: 'w:hayvanlar:2', word: 'Köpek', categoryId: 'hayvanlar'),
        ],
      ),
      ColumnDeal(faceDown: [], faceUp: []),
    ],
    stock: const [
      CategoryCard(
        id: 'c:meyveler',
        categoryId: 'meyveler',
        name: 'Meyveler',
        totalInLevel: 2,
      ),
      CategoryCard(
        id: 'c:hayvanlar',
        categoryId: 'hayvanlar',
        name: 'Hayvanlar',
        totalInLevel: 2,
      ),
    ],
  );
}

/// Fuzz için rastgele (mutlaka çözülebilir olmayan) legal dağıtım üretir.
/// Her dolu sütunun yalnızca en üstteki kartı açıktır.
LevelDef randomLevel(int seed) {
  final rng = Prng(seed);
  final catCount = 3 + rng.nextInt(3); // 3..5
  final allCards = <GameCard>[];
  final levelCats = <LevelCategory>[];
  for (var i = 0; i < catCount; i++) {
    final id = 'c$i';
    final total = 2 + rng.nextInt(4); // 2..5
    for (var j = 1; j <= total; j++) {
      allCards.add(WordCard(id: 'w:$id:$j', word: '$id$j', categoryId: id));
    }
    allCards.add(
      CategoryCard(id: 'k:$id', categoryId: id, name: id, totalInLevel: total),
    );
    levelCats.add(LevelCategory(categoryId: id, name: id, totalWords: total));
  }
  rng.shuffle(allCards);

  final columns = List.generate(5, (_) => <GameCard>[]);
  final tableauCount = (allCards.length * 0.5).floor();
  var idx = 0;
  for (; idx < tableauCount; idx++) {
    columns[idx % 5].add(allCards[idx]);
  }
  final stock = allCards.sublist(idx);
  final colDeals = [
    for (final c in columns)
      c.isEmpty
          ? const ColumnDeal(faceDown: [], faceUp: [])
          : ColumnDeal(faceDown: c.sublist(0, c.length - 1), faceUp: [c.last]),
  ];
  return LevelDef(
    id: seed,
    seed: seed,
    columns: colDeals,
    stock: stock,
    categories: levelCats,
    moveLimit: 100000,
  );
}

/// miniLevel'in bilinen 8 hamlelik kazanan çözümü.
List<Move> miniSolution() => const [
  // Armut -> Elma (col1 -> col0)
  PlaceMove(
    unit: ColumnUnitRef(column: 1, startIndex: 0),
    target: ColumnTargetRef(0),
  ),
  // Köpek -> Kedi (col3 -> col2)
  PlaceMove(
    unit: ColumnUnitRef(column: 3, startIndex: 0),
    target: ColumnTargetRef(2),
  ),
  DrawMove(), // c:hayvanlar
  // c:hayvanlar -> col2 (kilitle)
  PlaceMove(unit: WasteUnitRef(), target: ColumnTargetRef(2)),
  // süpür col2 -> slot0 (hayvanlar tamam)
  PlaceMove(
    unit: ColumnUnitRef(column: 2, startIndex: 0),
    target: FoundationTargetRef(0),
  ),
  DrawMove(), // c:meyveler
  // c:meyveler -> col0 (kilitle)
  PlaceMove(unit: WasteUnitRef(), target: ColumnTargetRef(0)),
  // süpür col0 -> slot1 (meyveler tamam) -> KAZAN
  PlaceMove(
    unit: ColumnUnitRef(column: 0, startIndex: 0),
    target: FoundationTargetRef(1),
  ),
];
