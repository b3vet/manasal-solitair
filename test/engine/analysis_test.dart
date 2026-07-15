import 'package:flutter_test/flutter_test.dart';
import 'package:manasal_solitaire/engine/engine.dart';

import 'helpers.dart';

void main() {
  group('legalMoves', () {
    test('mini başlangıçta çekme + eşleşen taşımalar üretir', () {
      final s = GameState.deal(miniLevel());
      final moves = Analysis.legalMoves(s);
      expect(moves.whereType<DrawMove>().length, 1);
      // Armut->Elma ve Köpek->Kedi gibi eşleşmeler mevcut.
      expect(moves.whereType<PlaceMove>().isNotEmpty, isTrue);
    });

    test('kilitli sütun asla hedef değildir', () {
      final s = st(
        columns: [
          col(up: [w('m', 1), cc('m', 1)]), // kilitli
          col(up: [w('m', 2)]),
        ],
        categories: {'m': 2},
      );
      final targetsToLocked = Analysis.placeMoves(
        s,
      ).where((m) => m.target == const ColumnTargetRef(0));
      expect(targetsToLocked, isEmpty);
    });
  });

  group('isDeadlocked', () {
    test('boş sütun varken çıkmaz değil', () {
      final s = st(
        columns: [
          col(up: [w('a', 1)]),
          col(up: [w('b', 1)]),
          col(),
        ],
        categories: {'a': 1, 'b': 1},
      );
      expect(Analysis.isDeadlocked(s), isFalse);
    });

    test('statik çıkmaz durumu tespit edilir', () {
      final s = st(
        columns: [
          col(up: [w('a', 1)]),
          col(up: [w('b', 1)]),
          col(up: [w('c', 1)]),
          col(up: [w('d', 1)]),
          col(up: [w('e', 1)]),
        ],
        categories: {'a': 1, 'b': 1, 'c': 1, 'd': 1, 'e': 1},
      );
      expect(Analysis.isDeadlocked(s), isTrue);
    });

    test('destede oynanabilir kart varsa çıkmaz değil', () {
      final s = st(
        columns: [
          col(up: [w('a', 1)]),
          col(up: [w('b', 1)]),
          col(up: [w('c', 1)]),
          col(up: [w('d', 1)]),
          col(up: [w('e', 1)]),
        ],
        stock: [w('a', 2)], // a1 üzerine oynanabilir
        categories: {'a': 2, 'b': 1, 'c': 1, 'd': 1, 'e': 1},
      );
      expect(Analysis.isDeadlocked(s), isFalse);
    });

    test('faydasız ileri-geri hamle çıkmazı bozmaz (board move var)', () {
      // İki aynı-kategori tek kart: ileri geri taşınabilir → çıkmaz DEĞİL.
      final s = st(
        columns: [
          col(up: [w('a', 1)]),
          col(up: [w('a', 2)]),
          col(up: [w('b', 1)]),
        ],
        categories: {'a': 2, 'b': 1},
      );
      expect(Analysis.isDeadlocked(s), isFalse);
    });
  });
}
