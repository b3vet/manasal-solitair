/// Zorluk eğrisi: bölüm numarası → üretim parametreleri (tuning verisi).
///
/// Tasarım (kullanıcı yönü):
///  - Oynanabilir sütun sayısı bölümden bölüme DEĞİŞİR (4/5/6).
///  - Kategori sayısı DAİMA sütun sayısından fazladır. Taban kural:
///    4 sütun→≥7 kategori, 5→≥8, 6→≥9 (yani en az columnCount+3). İlerledikçe
///    bu sayıların da üstüne çıkılır (juggle artar).
///  - Sütunlar DERİNDİR: sütun başına birkaç kapalı kart olur; üstteki bitince
///    yeni kart açılır — böylece sütunu boşaltmak düşünmeyi gerektirir, oyun
///    "kartı oradan oraya kaydırma"ya düşmez.
///  - Yalnızca ilk 3 bölüm kolaydır; 3'ten sonra zorluk hızla tırmanır.
///  - Hamle limiti dar tutulur (elde çok hamle kalmasın). (Spec §11.4)
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

  /// Toplam kapalı (gömülü) kart sayısı — sütunlara dağıtılır (derinlik).
  final int faceDownCount;
  final double marginMultiplier;
  final int maxDifficulty;
  final bool allowSoftConflict;
  final int rotationWindow;
}

/// Sütun sayısını bölümden bölüme değiştiren, deterministik küçük varyasyon.
int _columnsFor(int level, int lo, int hi) {
  final span = hi - lo + 1;
  return lo + (level % span);
}

LevelParams curveFor(int level) {
  // İlk 3 bölüm: kolay eğitim (az kategori, az gömülü, cömert hamle).
  if (level <= 3) {
    final cats = level + 3; // 4,5,6
    return LevelParams(
      columnCount: 4,
      categoryCount: cats,
      minWords: 3,
      maxWords: level == 1 ? 3 : 4,
      faceDownCount: level * 2, // 2,4,6 (sütun başına ~0.5-1.5)
      marginMultiplier: level == 1 ? 1.8 : 1.55,
      maxDifficulty: 1,
      allowSoftConflict: false,
      rotationWindow: 5,
    );
  }

  // 4. bölümden itibaren gerçek zorluk. Taban: kategori = sütun + 3
  // (4→7, 5→8, 6→9). İlerledikçe fazladan kategori (excess) ve sütun derinliği
  // (depth) artar; hamle limiti daralır.
  final cols = _columnsFor(level, 4, 6);
  // Fazladan kategori (juggle): taban 3 (4→7,5→8,6→9), sonra 4. (Çözücünün
  // güvenilir üretebilmesi için üst sınır 4.)
  final excess = level <= 25 ? 3 : 4;
  // Sütun derinliği (kapalı kart): 3 → 4. Boşaltmak düşünmeyi gerektirir.
  final depth = level <= 12 ? 3 : 4;
  final margin = level <= 12
      ? 1.32
      : level <= 35
      ? 1.24
      : 1.18;
  return LevelParams(
    columnCount: cols,
    categoryCount: cols + excess,
    minWords: level <= 25 ? 4 : 5,
    maxWords: level <= 25 ? 5 : 6,
    faceDownCount: cols * depth,
    marginMultiplier: margin,
    maxDifficulty: level <= 15 ? 2 : 3,
    allowSoftConflict: level > 40,
    rotationWindow: 12,
  );
}
