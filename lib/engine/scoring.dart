/// Bölüm performansından yıldız (1–3). Saf Dart; UI, meta ve testler paylaşır
/// (tek doğruluk kaynağı).
///
/// Eşikler tuning verisidir: kalan hamlenin limite oranı ≥ %40 → 3 yıldız,
/// ≥ %20 → 2, aksi → 1. %40 eşiği "Verimli" başarımıyla hizalıdır.
library;

/// Kazanılan yıldız (1–3). Kaybedilen/oynanmamış bölüm için çağırma.
int starRating(int movesLeft, int moveLimit) {
  if (moveLimit <= 0) return 1;
  final ratio = movesLeft / moveLimit;
  if (ratio >= 0.40) return 3;
  if (ratio >= 0.20) return 2;
  return 1;
}

/// Belirtilen yıldız sayısı için gereken EN AZ kalan hamle (hedef göstergesi).
/// 1 yıldız her zaman garanti (bölümü bitirmek yeter) → 0 döner.
int movesForStars(int stars, int moveLimit) {
  if (stars >= 3) return (moveLimit * 0.40).ceil();
  if (stars == 2) return (moveLimit * 0.20).ceil();
  return 0;
}
