/// Günlük bulmaca: tarih → deterministik tohum → çözülebilir bölüm.
///
/// Herkes aynı UTC gününde aynı bulmacayı görür (motor/PRNG platformdan bağımsız
/// deterministik — Spec §14.4). Bölüm çalışma anında üretilir; kısa bir düğüm
/// bütçesiyle çözülebilirlik doğrulanır ve bellekte önbelleklenir.
library;

import 'dart:math' as math;

import '../../content/category_pool.dart';
import '../../engine/level.dart';
import '../../generator/level_generator.dart';
import '../../generator/solver.dart';

class DailyService {
  DailyService(this.pool);

  final CategoryPool pool;

  /// Aynı gün tekrar açılışta yeniden üretmemek için önbellek.
  final Map<int, LevelDef> _cache = {};

  /// Günlük bulmacanın zorluğu — kampanya ilerlemesinden bağımsız, "ısınmış
  /// oyuncu" seviyesi. curveFor(bu değer) parametreleri kullanılır.
  static const int difficultyLevel = 18;

  /// Epoch: 2026-01-01 UTC = gün 0.
  static final DateTime _epoch = DateTime.utc(2026, 1, 1);

  /// Verilen zamanın UTC gün indeksi (epoch'tan).
  static int dayIndexUtc(DateTime now) {
    final u = now.toUtc();
    return DateTime.utc(u.year, u.month, u.day).difference(_epoch).inDays;
  }

  /// Gün indeksinden bölüm tohumu (kampanya tohum uzayından ayrık).
  static int dailySeed(int dayIndex) => 0x0DA1 * 1000003 + dayIndex * 97;

  /// Bugünün (yerel saate göre UTC gününe eşlenmiş) bulmacası.
  LevelDef today(DateTime now) => forDayIndex(dayIndexUtc(now));

  /// Belirli bir gün indeksinin bulmacası (önbellekli).
  LevelDef forDayIndex(int dayIndex) =>
      _cache[dayIndex] ??= _generate(dayIndex);

  LevelDef _generate(int dayIndex) {
    const margin = 1.15;
    LevelDef? lastTry;
    // Küçük düğüm bütçesiyle birkaç alt-tohum dene; ilk çözülebilir olanı al.
    for (var sub = 0; sub < 12; sub++) {
      final seed = dailySeed(dayIndex) + sub * 101;
      final level = LevelGenerator.generate(pool, difficultyLevel, seed);
      lastTry = level;
      final res = Solver.solve(level, maxNodes: 60000);
      if (res.solved) {
        final limit = math.max(
          res.moveCount + 5,
          (res.moveCount * margin).ceil(),
        );
        return level.copyWith(moveLimit: limit);
      }
    }
    // Çok nadir: bütçede çözülemedi → daha büyük bütçeyle son bir deneme.
    final res = Solver.solve(lastTry!, maxNodes: 400000);
    final base = res.solved ? res.moveCount : lastTry.totalCards * 2;
    final limit = math.max(base + 5, (base * margin).ceil());
    return lastTry.copyWith(moveLimit: limit);
  }
}
