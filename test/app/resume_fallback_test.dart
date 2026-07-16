// Bayat resume kaydı (bölüm yeniden üretilince eski hamleler uymaz) çökme
// yaratmaz: loadReplay baştan başlar ve false döner.
import 'package:flutter_test/flutter_test.dart';
import 'package:manasal_solitaire/app/game/game_controller.dart';
import 'package:manasal_solitaire/engine/engine.dart';

LevelDef _level() => const LevelDef(
  id: 1,
  seed: 0,
  columnCount: 2,
  slotCount: 2,
  moveLimit: 50,
  categories: [LevelCategory(categoryId: 'a', name: 'A', totalWords: 2)],
  columns: [
    ColumnDeal(
      faceDown: [],
      faceUp: [WordCard(id: 'w:a:1', word: 'Elma', categoryId: 'a')],
    ),
    ColumnDeal(faceDown: [], faceUp: []),
  ],
  stock: [CategoryCard(id: 'c:a', categoryId: 'a', name: 'A', totalInLevel: 2)],
);

void main() {
  test('bayat replay çökmez, baştan başlar (false döner)', () {
    final controller = GameController(_level());

    // Bu bölümde geçersiz bir hamle (boş slota kelime konamaz).
    final stale = <Move>[
      const PlaceMove(
        unit: ColumnUnitRef(column: 0, startIndex: 0),
        target: FoundationTargetRef(0),
      ),
    ];

    final applied = controller.loadReplay(_level(), stale);

    expect(applied, isFalse, reason: 'uyumsuz kayıt uygulanmamalı');
    expect(controller.state.status, GameStatus.playing);
    expect(controller.moveCount, 0, reason: 'taze dağıtım, hamle yok');
  });

  test('geçerli replay uygulanır (true döner)', () {
    final controller = GameController(_level());
    // Geçerli tek hamle: destedeki kategori kartını yüzeye çekmeden önce
    // sadece "draw" oyna (her zaman geçerli, deste dolu).
    final ok = controller.loadReplay(_level(), const [DrawMove()]);
    expect(ok, isTrue);
    expect(controller.moveCount, 1);
  });
}
