import 'package:flutter_test/flutter_test.dart';
import 'package:manasal_solitaire/engine/engine.dart';

import 'helpers.dart';

RuleViolation? place(GameState s, UnitRef u, TargetRef t) {
  final resolved = Rules.resolveUnit(s, u);
  if (resolved is Err<MovableUnit, RuleViolation>) return resolved.cause;
  return Rules.validatePlace(
    s,
    (resolved as Ok<MovableUnit, RuleViolation>).data,
    t,
    source: u,
  );
}

void main() {
  group('resolveUnit', () {
    test(
      'kilitli sütunda yalnızca startIndex 0 geçerli (kategori ayrılamaz)',
      () {
        final s = st(
          columns: [
            col(up: [w('m', 1), w('m', 2), cc('m', 2)]),
          ],
          categories: {'m': 2},
        );
        final ok = Rules.resolveUnit(
          s,
          const ColumnUnitRef(column: 0, startIndex: 0),
        );
        expect(ok, isA<Ok<MovableUnit, RuleViolation>>());
        expect((ok as Ok).data, isA<CategoryUnit>());
        final bad = Rules.resolveUnit(
          s,
          const ColumnUnitRef(column: 0, startIndex: 1),
        );
        expect((bad as Err).cause, RuleViolation.notAUnit);
      },
    );

    test('boş atık birim değildir', () {
      final s = st(columns: [col()], categories: {'m': 1});
      expect(
        (Rules.resolveUnit(s, const WasteUnitRef()) as Err).cause,
        RuleViolation.notAUnit,
      );
    });

    test('kelime zinciri suffix olarak çözülür', () {
      final s = st(
        columns: [
          col(up: [w('m', 1), w('m', 2), w('m', 3)]),
        ],
        categories: {'m': 3},
      );
      final u = Rules.resolveUnit(
        s,
        const ColumnUnitRef(column: 0, startIndex: 1),
      );
      final unit = (u as Ok).data as WordUnit;
      expect(unit.words.length, 2);
      expect(unit.categoryId, 'm');
    });
  });

  group('matris: kelime birimi (U1/U3-word)', () {
    test('eşleşen dolu sütuna ✓', () {
      final s = st(
        columns: [
          col(up: [w('m', 1)]),
          col(up: [w('m', 2)]),
        ],
        categories: {'m': 2},
      );
      expect(
        place(
          s,
          const ColumnUnitRef(column: 1, startIndex: 0),
          const ColumnTargetRef(0),
        ),
        isNull,
      );
    });
    test('eşleşmeyen dolu sütuna ✗', () {
      final s = st(
        columns: [
          col(up: [w('m', 1)]),
          col(up: [w('h', 1)]),
        ],
        categories: {'m': 1, 'h': 1},
      );
      expect(
        place(
          s,
          const ColumnUnitRef(column: 1, startIndex: 0),
          const ColumnTargetRef(0),
        ),
        RuleViolation.catMismatchColumn,
      );
    });
    test('boş sütuna ✓', () {
      final s = st(
        columns: [
          col(up: [w('m', 1)]),
          col(),
        ],
        categories: {'m': 1},
      );
      expect(
        place(
          s,
          const ColumnUnitRef(column: 0, startIndex: 0),
          const ColumnTargetRef(1),
        ),
        isNull,
      );
    });
    test('kilitli sütuna ✗', () {
      final s = st(
        columns: [
          col(up: [w('m', 1), cc('m', 1)]),
          col(up: [w('m', 2)]),
        ],
        categories: {'m': 2},
      );
      expect(
        place(
          s,
          const ColumnUnitRef(column: 1, startIndex: 0),
          const ColumnTargetRef(0),
        ),
        RuleViolation.targetLocked,
      );
    });
    test('boş slota ✗ (kategori gerekir)', () {
      final s = st(
        columns: [
          col(up: [w('m', 1)]),
        ],
        categories: {'m': 1},
      );
      expect(
        place(
          s,
          const ColumnUnitRef(column: 0, startIndex: 0),
          const FoundationTargetRef(0),
        ),
        RuleViolation.emptySlotNeedsCat,
      );
    });
    test('eşleşen aktif slota ✓', () {
      final s = st(
        columns: [
          col(up: [w('m', 2)]),
        ],
        slots: [
          active('m', 3, [w('m', 1)]),
          const EmptySlot(),
        ],
        categories: {'m': 3},
        slotCount: 2,
      );
      expect(
        place(
          s,
          const ColumnUnitRef(column: 0, startIndex: 0),
          const FoundationTargetRef(0),
        ),
        isNull,
      );
    });
    test('eşleşmeyen aktif slota ✗', () {
      final s = st(
        columns: [
          col(up: [w('m', 1)]),
        ],
        slots: [
          active('h', 3, [w('h', 1)]),
          const EmptySlot(),
        ],
        categories: {'m': 1, 'h': 3},
        slotCount: 2,
      );
      expect(
        place(
          s,
          const ColumnUnitRef(column: 0, startIndex: 0),
          const FoundationTargetRef(0),
        ),
        RuleViolation.catMismatchSlot,
      );
    });
  });

  group('matris: kategori/süpürme birimi (U2/U3-cat)', () {
    GameState withWasteCat() => st(
      columns: [
        col(up: [w('m', 1), w('m', 2)]),
        col(up: [w('h', 1)]),
        col(),
      ],
      waste: [cc('m', 2)],
      categories: {'m': 2, 'h': 1},
    );

    test('eşleşen zincirli sütuna ✓', () {
      expect(
        place(withWasteCat(), const WasteUnitRef(), const ColumnTargetRef(0)),
        isNull,
      );
    });
    test('boş sütuna ✓', () {
      expect(
        place(withWasteCat(), const WasteUnitRef(), const ColumnTargetRef(2)),
        isNull,
      );
    });
    test('eşleşmeyen sütuna ✗', () {
      expect(
        place(withWasteCat(), const WasteUnitRef(), const ColumnTargetRef(1)),
        RuleViolation.catMismatchColumn,
      );
    });
    test('boş slota ✓ (aktifleşir)', () {
      expect(
        place(
          withWasteCat(),
          const WasteUnitRef(),
          const FoundationTargetRef(0),
        ),
        isNull,
      );
    });
    test('aktif slota ✗', () {
      final s = st(
        columns: [col()],
        waste: [cc('m', 2)],
        slots: [
          active('m', 2, [w('m', 1)]),
          const EmptySlot(),
        ],
        categories: {'m': 2},
        slotCount: 2,
      );
      expect(
        place(s, const WasteUnitRef(), const FoundationTargetRef(0)),
        RuleViolation.activeSlotNoCat,
      );
    });
  });

  group('genel doğrulama', () {
    test('aynı sütuna kendini bırakmak noOp', () {
      final s = st(
        columns: [
          col(up: [w('m', 1), w('m', 2)]),
        ],
        categories: {'m': 2},
      );
      expect(
        place(
          s,
          const ColumnUnitRef(column: 0, startIndex: 1),
          const ColumnTargetRef(0),
        ),
        RuleViolation.noOp,
      );
    });
    test('çekme boş desteyle geçersiz', () {
      final s = st(
        columns: [
          col(up: [w('m', 1)]),
        ],
        categories: {'m': 1},
      );
      expect(Rules.validate(s, const DrawMove()), RuleViolation.drawEmpty);
    });
    test('devir yalnızca deste boş + atık dolu iken', () {
      final ok = st(columns: [col()], waste: [w('m', 1)], categories: {'m': 1});
      expect(Rules.validate(ok, const RecycleMove()), isNull);
      final bad = st(
        columns: [col()],
        stock: [w('m', 1)],
        waste: [w('m', 2)],
        categories: {'m': 2},
      );
      expect(
        Rules.validate(bad, const RecycleMove()),
        RuleViolation.recycleInvalid,
      );
    });
    test('oyun bittiğinde gameOver', () {
      final s = st(
        columns: [col()],
        categories: {'m': 1},
        status: GameStatus.won,
      );
      expect(Rules.validate(s, const DrawMove()), RuleViolation.gameOver);
    });
    test('hamle kalmadığında noMovesLeft', () {
      final s = st(
        columns: [
          col(up: [w('m', 1)]),
        ],
        stock: [w('m', 2)],
        categories: {'m': 2},
        movesLeft: 0,
      );
      expect(Rules.validate(s, const DrawMove()), RuleViolation.noMovesLeft);
    });
  });
}
