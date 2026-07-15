/// Materyalize edilmiş bölüm tanımı — üretim hattının çıktısı, motorun girdisi.
///
/// Bir bölüm kart kart yazılır; içerik havuzu sonradan değişse bile yayınlanmış
/// bölümü etkilemez (Spec §11.1, K14). `seed` yalnızca yeniden üretim/tanılama
/// içindir.
library;

import 'cards.dart';

/// Bir sütunun başlangıç dizilişi.
class ColumnDeal {
  const ColumnDeal({required this.faceDown, required this.faceUp});

  /// Alt → üst sırayla kapalı kartlar.
  final List<GameCard> faceDown;

  /// Alt → üst sırayla açık kartlar (v1: dağıtımda en fazla 1).
  final List<GameCard> faceUp;
}

/// Bir bölümdeki kategori özeti.
class LevelCategory {
  const LevelCategory({
    required this.categoryId,
    required this.name,
    required this.totalWords,
  });

  final String categoryId;
  final String name;
  final int totalWords;
}

class LevelDef {
  const LevelDef({
    required this.id,
    required this.seed,
    required this.columns,
    required this.stock,
    required this.categories,
    required this.moveLimit,
    this.columnCount = 5,
    this.slotCount = 5,
    this.generatorVersion = 1,
  });

  /// 1-tabanlı bölüm numarası.
  final int id;
  final int seed;
  final List<ColumnDeal> columns;

  /// Kapalı çekme destesi (alt → üst; üst = son eleman).
  final List<GameCard> stock;
  final List<LevelCategory> categories;
  final int moveLimit;
  final int columnCount;
  final int slotCount;
  final int generatorVersion;

  int get totalCategories => categories.length;

  LevelDef copyWith({int? moveLimit}) => LevelDef(
    id: id,
    seed: seed,
    columns: columns,
    stock: stock,
    categories: categories,
    moveLimit: moveLimit ?? this.moveLimit,
    columnCount: columnCount,
    slotCount: slotCount,
    generatorVersion: generatorVersion,
  );

  /// Bölümdeki toplam kart sayısı (doğrulama için).
  int get totalCards {
    var n = stock.length;
    for (final c in columns) {
      n += c.faceDown.length + c.faceUp.length;
    }
    return n;
  }
}
