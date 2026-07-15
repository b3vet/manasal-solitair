import 'package:flutter_test/flutter_test.dart';
import 'package:manasal_solitaire/content/category_pool.dart';
import 'package:manasal_solitaire/engine/engine.dart';
import 'package:manasal_solitaire/generator/level_generator.dart';
import 'package:manasal_solitaire/generator/solver.dart';

CategoryPool synthPool() {
  Category c(String id, int diff, List<String> extra) => Category(
        id: id,
        name: id,
        difficulty: diff,
        words: [for (var i = 0; i < 10; i++) '$id$i', ...extra],
      );
  return CategoryPool(version: 1, categories: [
    c('a', 1, const []),
    c('b', 1, const []),
    c('cc', 1, const []),
    c('d', 2, const []),
    c('e', 2, const []),
    c('f', 2, const []),
    c('g', 1, const []),
  ]);
}

void main() {
  test('üretici determinizmi: aynı tohum aynı dağıtım', () {
    final pool = synthPool();
    final l1 = LevelGenerator.generate(pool, 10, 42);
    final l2 = LevelGenerator.generate(pool, 10, 42);
    expect(
      Serde.stateToJson(GameState.deal(l1)).toString(),
      Serde.stateToJson(GameState.deal(l2)).toString(),
    );
  });

  test('üretilen bölümler çözülebilir (1..15)', () {
    final pool = synthPool();
    for (var lvl = 1; lvl <= 15; lvl++) {
      // Birkaç tohum dene (üretim hattı da böyle yapar).
      var solved = false;
      var moveCount = 0;
      for (var t = 0; t < 8 && !solved; t++) {
        final level = LevelGenerator.generate(pool, lvl, lvl * 1000 + t);
        final res = Solver.solve(level, maxNodes: 200000);
        if (res.solved) {
          solved = true;
          moveCount = res.moveCount;
          // Çözüm gerçekten kazandırıyor mu?
          final session = GameSession.replay(
            level.copyWith(moveLimit: 1 << 30),
            res.solution!,
          );
          expect(session.state.status, GameStatus.won);
        }
      }
      expect(solved, isTrue, reason: 'Bölüm $lvl 8 tohumda çözülemedi');
      expect(moveCount, greaterThan(0));
    }
  });
}
