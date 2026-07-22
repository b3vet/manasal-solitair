import 'package:flutter_test/flutter_test.dart';
import 'package:manasal_solitaire/engine/scoring.dart';

void main() {
  group('starRating', () {
    test('kalan ≥ %40 → 3 yıldız', () {
      expect(starRating(8, 20), 3); // tam %40
      expect(starRating(20, 20), 3);
    });
    test('kalan ≥ %20 → 2 yıldız', () {
      expect(starRating(4, 20), 2); // tam %20
      expect(starRating(7, 20), 2);
    });
    test('kalan < %20 → 1 yıldız', () {
      expect(starRating(3, 20), 1);
      expect(starRating(0, 20), 1);
    });
    test('moveLimit 0 → 1 (bölünme yok)', () => expect(starRating(0, 0), 1));
  });

  group('movesForStars', () {
    test('3 yıldız eşiği = ceil(%40)', () => expect(movesForStars(3, 20), 8));
    test('2 yıldız eşiği = ceil(%20)', () => expect(movesForStars(2, 20), 4));
    test('1 yıldız her zaman garanti → 0', () {
      expect(movesForStars(1, 20), 0);
    });
    test('ceil doğru (tek sayı limit)', () {
      expect(movesForStars(3, 25), 10); // 25*0.4 = 10
      expect(movesForStars(2, 25), 5); // 25*0.2 = 5
      expect(movesForStars(3, 23), 10); // 23*0.4 = 9.2 → 10
    });
  });
}
