/// Bölüm üreticisi: havuzdan sabit tohumla materyalize bir dağıtım üretir.
///
/// Determinizm: aynı (havuz, bölüm no, tohum) → bit-bit aynı dağıtım.
/// Üretilen dağıtımın çözülebilirliği [Solver] ile kanıtlanır (CLI'da).
library;

import '../content/category_pool.dart';
import '../content/validator.dart';
import '../engine/cards.dart';
import '../engine/level.dart';
import '../engine/prng.dart';
import 'curve.dart';

class LevelGenerator {
  const LevelGenerator._();

  /// Bir bölüm dağıtımı üretir. [moveLimit] geçici olarak 0'dır; CLI çözümden
  /// sonra gerçek limiti [LevelDef.copyWith] ile yazar.
  static LevelDef generate(
    CategoryPool pool,
    int levelNumber,
    int seed, {
    List<String> recentCategoryIds = const [],
  }) {
    final params = curveFor(levelNumber);
    final rng = Prng(seed);

    final chosen = _pickCategories(pool, params, rng, recentCategoryIds);

    final allCards = <GameCard>[];
    final levelCats = <LevelCategory>[];
    for (final cat in chosen) {
      final available = cat.words.length;
      final desired =
          params.minWords +
          (params.maxWords > params.minWords
              ? rng.nextInt(params.maxWords - params.minWords + 1)
              : 0);
      final count = desired.clamp(2, available);
      final words = _sample(cat.words, count, rng);
      for (var i = 0; i < words.length; i++) {
        allCards.add(
          WordCard(id: 'w:${cat.id}:$i', word: words[i], categoryId: cat.id),
        );
      }
      allCards.add(
        CategoryCard(
          id: 'c:${cat.id}',
          categoryId: cat.id,
          name: cat.name,
          totalInLevel: count,
        ),
      );
      levelCats.add(
        LevelCategory(categoryId: cat.id, name: cat.name, totalWords: count),
      );
    }

    rng.shuffle(allCards);

    // Dağıtım: bölüme özgü sütun sayısı. Kapalı kartlar MERDİVEN dizilir —
    // sütun c için (columnDepthMin + c) kapalı kart (soldan sağa artar, gerçek
    // solitaire gibi). Her sütuna 1 açık kart, kalanı deste.
    final columnCount = params.columnCount;
    final down = List.generate(columnCount, (_) => <GameCard>[]);
    final up = List<GameCard?>.filled(columnCount, null);
    // Merdiven: soldan sağa artar ama en fazla +3 (geniş tahtalarda en derin
    // sütun aşırı derinleşmesin — çözülebilirlik/üretim hızı için).
    final depths = [
      for (var c = 0; c < columnCount; c++)
        params.columnDepthMin + (c < 4 ? c : 3),
    ];

    var idx = 0;
    for (var c = 0; c < columnCount; c++) {
      for (var k = 0; k < depths[c] && idx < allCards.length; k++) {
        down[c].add(allCards[idx++]);
      }
    }
    for (var c = 0; c < columnCount && idx < allCards.length; c++) {
      up[c] = allCards[idx++];
    }
    final stock = allCards.sublist(idx);

    final columns = <ColumnDeal>[
      for (var c = 0; c < columnCount; c++)
        ColumnDeal(
          faceDown: down[c],
          faceUp: up[c] == null ? const [] : [up[c]!],
        ),
    ];

    return LevelDef(
      id: levelNumber,
      seed: seed,
      columns: columns,
      stock: stock,
      categories: levelCats,
      moveLimit: 0, // CLI tarafından çözümden sonra atanır
      columnCount: columnCount,
      slotCount: columnCount, // foundation slot sayısı = sütun sayısı
    );
  }

  static List<Category> _pickCategories(
    CategoryPool pool,
    LevelParams params,
    Prng rng,
    List<String> recent,
  ) {
    final softMap = ContentValidator.symmetricSoftConflicts(pool);

    List<Category> eligible(bool honorRecent) => pool.categories
        .where((c) => c.difficulty <= params.maxDifficulty)
        .where((c) => !honorRecent || !recent.contains(c.id))
        .toList();

    var candidates = eligible(true);
    if (candidates.length < params.categoryCount) {
      candidates = eligible(false); // rotasyonu gevşet
    }
    if (candidates.length < params.categoryCount) {
      candidates = List.of(pool.categories); // her şeyi kabul et
    }
    rng.shuffle(candidates);

    final chosen = <Category>[];
    for (final c in candidates) {
      if (chosen.length >= params.categoryCount) break;
      if (!params.allowSoftConflict) {
        final conflicts = softMap[c.id] ?? const {};
        if (chosen.any((x) => conflicts.contains(x.id))) continue;
      }
      chosen.add(c);
    }
    // Çakışma yüzünden yetersizse gevşeterek doldur.
    if (chosen.length < params.categoryCount) {
      for (final c in candidates) {
        if (chosen.length >= params.categoryCount) break;
        if (!chosen.contains(c)) chosen.add(c);
      }
    }
    return chosen;
  }

  /// [rng] ile [list]'ten [count] farklı öğe örnekler (sıra karışık).
  static List<String> _sample(List<String> list, int count, Prng rng) {
    final copy = List<String>.of(list);
    rng.shuffle(copy);
    return copy.take(count).toList();
  }
}
