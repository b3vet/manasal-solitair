/// Zorluk eğrisi: bölüm numarası → üretim parametreleri (tuning verisi).
///
/// Tasarım (kullanıcı yönü): oynanabilir sütun sayısı bölümden bölüme DEĞİŞİR
/// ve kategori sayısı HER ZAMAN sütun sayısından fazladır. Aradaki fark, aynı
/// anda foundation'a sığmayan (önce tamamlanıp yer açılması gereken) kategori
/// sayısıdır — asıl zorluk kaynağı. İlk 5 bölüm eğitimdir (küçük, cömert);
/// ~6. bölümden sonra gerçek zorluk başlar. (Spec §11.4)
library;

class LevelParams {
  const LevelParams({
    required this.columnCount,
    required this.categoryCount,
    required this.minWords,
    required this.maxWords,
    required this.faceDownCount,
    required this.marginMultiplier,
    required this.maxDifficulty,
    required this.allowSoftConflict,
    required this.rotationWindow,
  });

  /// Oynanabilir sütun (tableau) sayısı — foundation slot sayısı da buna eşittir.
  final int columnCount;

  /// Bölümdeki kategori sayısı — DAİMA columnCount'tan büyüktür.
  final int categoryCount;
  final int minWords;
  final int maxWords;
  final int faceDownCount;
  final double marginMultiplier;
  final int maxDifficulty;
  final bool allowSoftConflict;
  final int rotationWindow;
}

/// Sütun sayısını bölümden bölüme değiştiren, deterministik küçük varyasyon.
int _columnsFor(int level, int lo, int hi) {
  final span = hi - lo + 1;
  // Ardışık bölümler farklı sütun sayısı alsın diye dönüşümlü seç.
  return lo + (level % span);
}

LevelParams curveFor(int level) {
  // categoryCount = columnCount + excess (excess >= 1 → kategori > sütun).
  if (level <= 2) {
    // Eğitim başlangıcı: en küçük, gömülü kart yok, çok cömert.
    return const LevelParams(
      columnCount: 4,
      categoryCount: 5,
      minWords: 3,
      maxWords: 3,
      faceDownCount: 0,
      marginMultiplier: 2.2,
      maxDifficulty: 1,
      allowSoftConflict: false,
      rotationWindow: 4,
    );
  }
  if (level <= 5) {
    // Eğitim: hâlâ küçük ama biraz gömülü kart + tek fazladan kategori.
    final cols = level == 4 ? 5 : 4;
    return LevelParams(
      columnCount: cols,
      categoryCount: cols + 1,
      minWords: 3,
      maxWords: 4,
      faceDownCount: level - 2, // 1..3
      marginMultiplier: 1.9,
      maxDifficulty: 1,
      allowSoftConflict: false,
      rotationWindow: 5,
    );
  }
  if (level <= 12) {
    // Gerçek zorluk başlar: iki fazladan kategori (2 juggle).
    final cols = _columnsFor(level, 4, 5);
    return LevelParams(
      columnCount: cols,
      categoryCount: cols + 2,
      minWords: 3,
      maxWords: 5,
      faceDownCount: 3 + (level - 6) ~/ 3, // 3..5
      marginMultiplier: 1.6,
      maxDifficulty: 2,
      allowSoftConflict: false,
      rotationWindow: 8,
    );
  }
  if (level <= 25) {
    final cols = _columnsFor(level, 4, 6);
    return LevelParams(
      columnCount: cols,
      categoryCount: cols + 2,
      minWords: 4,
      maxWords: 5,
      faceDownCount: 5 + (level - 13) ~/ 4, // 5..8
      marginMultiplier: 1.5,
      maxDifficulty: 2,
      allowSoftConflict: false,
      rotationWindow: 10,
    );
  }
  if (level <= 45) {
    // Juggle 3: yeterli manevra için 5-6 sütun.
    final cols = _columnsFor(level, 5, 6);
    return LevelParams(
      columnCount: cols,
      categoryCount: cols + 3,
      minWords: 4,
      maxWords: 6,
      faceDownCount: 7 + (level - 26) ~/ 6, // 7..10
      marginMultiplier: 1.45,
      maxDifficulty: 3,
      allowSoftConflict: false,
      rotationWindow: 12,
    );
  }
  final cols = _columnsFor(level, 5, 6);
  return LevelParams(
    columnCount: cols,
    categoryCount: cols + 3,
    minWords: 5,
    maxWords: 6,
    faceDownCount: 9 + ((level - 46) ~/ 12).clamp(0, 4), // 9..13
    marginMultiplier: 1.4,
    maxDifficulty: 3,
    allowSoftConflict: true,
    rotationWindow: 14,
  );
}
