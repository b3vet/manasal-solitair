/// Zorluk eğrisi: bölüm numarası → üretim parametreleri (tuning verisi).
///
/// Tüm sayılar ayarlanabilir; erken bölümler cömert ve az gömülü kartlı,
/// ileri bölümler daha çok kategori/kelime ve gömülü kart içerir. (Spec §11.4)
library;

class LevelParams {
  const LevelParams({
    required this.categoryCount,
    required this.minWords,
    required this.maxWords,
    required this.faceDownCount,
    required this.marginMultiplier,
    required this.maxDifficulty,
    required this.allowSoftConflict,
    required this.rotationWindow,
  });

  final int categoryCount;
  final int minWords;
  final int maxWords;
  final int faceDownCount;
  final double marginMultiplier;
  final int maxDifficulty;
  final bool allowSoftConflict;
  final int rotationWindow;
}

LevelParams curveFor(int level) {
  if (level <= 3) {
    // Öğretici: çok küçük, gömülü kart yok, çok cömert.
    return LevelParams(
      categoryCount: level == 1 ? 2 : (level == 2 ? 2 : 3),
      minWords: 3,
      maxWords: 4,
      faceDownCount: 0,
      marginMultiplier: 2.0,
      maxDifficulty: 1,
      allowSoftConflict: false,
      rotationWindow: 4,
    );
  }
  if (level <= 8) {
    return LevelParams(
      categoryCount: 3,
      minWords: 3,
      maxWords: 5,
      faceDownCount: 2 + (level - 4) ~/ 3, // 2..3
      marginMultiplier: 1.7,
      maxDifficulty: 1,
      allowSoftConflict: false,
      rotationWindow: 6,
    );
  }
  if (level <= 20) {
    return LevelParams(
      categoryCount: 4,
      minWords: 4,
      maxWords: 5,
      faceDownCount: 4 + (level - 9) ~/ 4, // 4..6
      marginMultiplier: 1.5,
      maxDifficulty: 2,
      allowSoftConflict: false,
      rotationWindow: 8,
    );
  }
  if (level <= 40) {
    return LevelParams(
      categoryCount: 4,
      minWords: 4,
      maxWords: 6,
      faceDownCount: 6 + (level - 21) ~/ 7, // 6..8
      marginMultiplier: 1.4,
      maxDifficulty: 3,
      allowSoftConflict: false,
      rotationWindow: 10,
    );
  }
  return LevelParams(
    categoryCount: 5,
    minWords: 5,
    maxWords: 6,
    faceDownCount: 8 + ((level - 41) ~/ 10).clamp(0, 4), // 8..12
    marginMultiplier: 1.3,
    maxDifficulty: 3,
    allowSoftConflict: true,
    rotationWindow: 12,
  );
}
