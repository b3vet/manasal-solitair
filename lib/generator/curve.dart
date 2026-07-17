/// Zorluk eğrisi: bölüm numarası → üretim parametreleri (tuning verisi).
///
/// Tasarım (kullanıcı yönü):
///  - Oynanabilir sütun sayısı bölümden bölüme DEĞİŞİR (4/5/6).
///  - Kategori sayısı DAİMA sütun sayısından fazladır. Taban: 4→7, 5→8, 6→9
///    (columnCount+3); ilerledikçe üstüne çıkılır (juggle artar).
///  - Kapalı kartlar gerçek solitaire gibi MERDİVEN dizilir: sütun başına artan
///    (soldan sağa depthMin, depthMin+1, ...). Derin sütunları boşaltmak sıra ve
///    düşünme gerektirir.
///  - Yalnızca ilk 3 bölüm kolaydır; 4. bölümden itibaren zorluk HIZLA tırmanır
///    (~15. bölümde belirgin şekilde zor).
///  - Hamle limiti dardır (üretici en kısa çözümü seçer, marj küçüktür).
library;

class LevelParams {
  const LevelParams({
    required this.columnCount,
    required this.categoryCount,
    required this.minWords,
    required this.maxWords,
    required this.columnDepthMin,
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

  /// Merdiven dağılımında en sığ (soldaki) sütunun kapalı kart sayısı. Sütun c
  /// için kapalı kart = columnDepthMin + c (soldan sağa artar).
  final int columnDepthMin;
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
  // İlk 3 bölüm: kolay eğitim (küçük, sığ merdiven, cömert hamle).
  if (level <= 3) {
    return LevelParams(
      columnCount: 4,
      categoryCount: level + 3, // 4,5,6
      minWords: 3,
      maxWords: level == 1 ? 3 : 4,
      columnDepthMin: 0, // merdiven: 0,1,2,3
      marginMultiplier: level == 1 ? 1.7 : 1.5,
      maxDifficulty: 1,
      allowSoftConflict: false,
      rotationWindow: 6,
    );
  }

  // 4. bölümden itibaren HIZLI tırmanış. Sütun sayısı 4/5/6 arası değişir.
  final cols = _columnsFor(level, 4, 6);
  final int excess; // categories - columns (juggle)
  final int depthMin; // merdivenin en sığ sütunu
  final double margin;
  if (level <= 6) {
    excess = 3;
    depthMin = 1;
    margin = 1.26;
  } else if (level <= 10) {
    excess = 3;
    depthMin = 1;
    margin = 1.20;
  } else if (level <= 15) {
    excess = 4;
    depthMin = 2;
    margin = 1.15;
  } else if (level <= 30) {
    excess = 4;
    depthMin = 2;
    margin = 1.13;
  } else if (level <= 60) {
    excess = 4;
    depthMin = 2;
    margin = 1.12;
  } else {
    excess = 4;
    depthMin = 2;
    margin = 1.12;
  }

  return LevelParams(
    columnCount: cols,
    categoryCount: cols + excess,
    minWords: level <= 15 ? 4 : 5,
    maxWords: level <= 15 ? 5 : 6,
    columnDepthMin: depthMin,
    marginMultiplier: margin,
    maxDifficulty: level <= 10 ? 2 : 3,
    allowSoftConflict: level > 30,
    rotationWindow: 12,
  );
}
