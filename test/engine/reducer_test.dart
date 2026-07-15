import 'package:flutter_test/flutter_test.dart';
import 'package:manasal_solitaire/engine/engine.dart';

import 'helpers.dart';

ApplyResult applyOk(GameState s, Move m) {
  final r = Reducer.apply(s, m);
  if (r is Err<ApplyResult, RuleViolation>) {
    fail('hamle geçerli olmalı ama reddedildi: ${r.cause}');
  }
  return (r as Ok<ApplyResult, RuleViolation>).data;
}

void main() {
  group('çekme ve devir', () {
    test('çekme kartı atığa taşır, 1 hamle', () {
      final s = st(
        columns: [col()],
        stock: [w('m', 1), w('m', 2)],
        categories: {'m': 2},
      );
      final r = applyOk(s, const DrawMove());
      expect(r.next.waste.single.id, 'w:m:2'); // üst
      expect(r.next.stock.length, 1);
      expect(r.next.movesLeft, 99);
      expect(r.events.single, isA<DrewEvent>());
    });

    test('devir atığı ters çevirir; sıra korunur', () {
      var s = st(
        columns: [col()],
        stock: [w('m', 1), w('m', 2), w('m', 3)],
        categories: {'m': 3},
      );
      // Üç çekiş: waste = [m1, m2, m3] (üst m3)
      s = applyOk(s, const DrawMove()).next;
      s = applyOk(s, const DrawMove()).next;
      s = applyOk(s, const DrawMove()).next;
      expect(s.stock, isEmpty);
      // Devir: çekme döngüsü korunur (aynı sıra tekrarlanır).
      final rec = applyOk(s, const RecycleMove());
      expect(rec.next.waste, isEmpty);
      expect(rec.next.stock.length, 3);
      // Tekrar çekince döngü baştan başlar: yine en üstteki (m3) gelir.
      final again = applyOk(rec.next, const DrawMove());
      expect(again.next.waste.single.id, 'w:m:3');
    });
  });

  group('yerleştirme etkileri', () {
    test('kelime zincirini taşımak tek hamle (kart sayısından bağımsız)', () {
      final s = st(
        columns: [
          col(up: [w('m', 1), w('m', 2), w('m', 3)]),
          col(),
        ],
        categories: {'m': 3},
      );
      final r = applyOk(
        s,
        const PlaceMove(
          unit: ColumnUnitRef(column: 0, startIndex: 0),
          target: ColumnTargetRef(1),
        ),
      );
      expect(r.next.columns[1].faceUp.map((c) => c.id), [
        'w:m:1',
        'w:m:2',
        'w:m:3',
      ]);
      expect(r.next.columns[0].isEmpty, isTrue);
      expect(r.next.movesLeft, 99); // yalnızca 1
    });

    test('kaynak sütun boşalınca kapalı kart otomatik açılır (bedava)', () {
      final s = st(
        columns: [
          col(down: [w('h', 1)], up: [w('m', 1)]),
          col(up: [w('m', 2)]),
        ],
        categories: {'m': 2, 'h': 1},
      );
      final r = applyOk(
        s,
        const PlaceMove(
          unit: ColumnUnitRef(column: 0, startIndex: 0),
          target: ColumnTargetRef(1),
        ),
      );
      expect(r.next.columns[0].faceUp.single.id, 'w:h:1'); // açıldı
      expect(r.next.columns[0].faceDown, isEmpty);
      expect(r.events.whereType<FlippedEvent>().length, 1);
      expect(r.next.movesLeft, 99); // flip bedava
    });

    test('kategori kartı sütunu kilitler', () {
      final s = st(
        columns: [
          col(up: [w('m', 1), w('m', 2)]),
          col(),
        ],
        waste: [cc('m', 2)],
        categories: {'m': 2},
      );
      final r = applyOk(
        s,
        const PlaceMove(unit: WasteUnitRef(), target: ColumnTargetRef(0)),
      );
      expect(r.next.columns[0].isLocked, isTrue);
      expect(r.next.waste, isEmpty);
    });
  });

  group('süpürme ve tamamlanma', () {
    test(
      'süpürme: kategori + zincir tek hamlede slota, kelimeler toplanır',
      () {
        final s = st(
          columns: [
            col(up: [w('m', 1), w('m', 2), cc('m', 3)]),
          ],
          categories: {'m': 3},
        );
        final r = applyOk(
          s,
          const PlaceMove(
            unit: ColumnUnitRef(column: 0, startIndex: 0),
            target: FoundationTargetRef(0),
          ),
        );
        final slot = r.next.slots[0] as ActiveSlot;
        expect(slot.collected.length, 2); // süpürülen 2 kelime
        expect(slot.total, 3);
        expect(
          r.events.whereType<SlotActivatedEvent>().single.sweptWords.length,
          2,
        );
        expect(r.next.movesLeft, 99);
      },
    );

    test('kategori tamamlanınca slot boşalır ve sayaç artar', () {
      final s = st(
        columns: [
          col(up: [w('m', 2)]),
        ],
        slots: [
          active('m', 2, [w('m', 1)]),
          const EmptySlot(),
        ],
        categories: {'m': 2, 'h': 1},
        slotCount: 2,
      );
      final r = applyOk(
        s,
        const PlaceMove(
          unit: ColumnUnitRef(column: 0, startIndex: 0),
          target: FoundationTargetRef(0),
        ),
      );
      expect(r.next.slots[0], isA<EmptySlot>());
      expect(r.next.completedCount, 1);
      expect(r.events.whereType<CategoryCompletedEvent>().length, 1);
    });
  });

  group('statü geçişleri', () {
    test('tüm kategoriler bitince kazanma', () {
      final s = st(
        columns: [
          col(up: [w('m', 2)]),
        ],
        slots: [
          active('m', 2, [w('m', 1)]),
        ],
        categories: {'m': 2},
        slotCount: 1,
      );
      final r = applyOk(
        s,
        const PlaceMove(
          unit: ColumnUnitRef(column: 0, startIndex: 0),
          target: FoundationTargetRef(0),
        ),
      );
      expect(r.next.status, GameStatus.won);
      expect(
        r.events.whereType<GameEndedEvent>().single.status,
        GameStatus.won,
      );
    });

    test('hamle biterse ve kazanılmadıysa kayıp', () {
      final s = st(
        columns: [
          col(up: [w('m', 1)]),
          col(up: [w('m', 2)]),
        ],
        categories: {'m': 2, 'h': 2},
        movesLeft: 1,
      );
      final r = applyOk(
        s,
        const PlaceMove(
          unit: ColumnUnitRef(column: 1, startIndex: 0),
          target: ColumnTargetRef(0),
        ),
      );
      expect(r.next.movesLeft, 0);
      expect(r.next.status, GameStatus.lostOutOfMoves);
    });

    test('anlamlı hamle kalmayınca çıkmaz kaybı', () {
      // a1'i col3'e taşımak tahtayı çıkmaza sokar (tüm sütun tepeleri farklı kategori).
      final s = st(
        columns: [
          col(down: [w('x', 1)], up: [w('a', 1)]),
          col(up: [w('b', 1)]),
          col(up: [w('c', 1)]),
          col(up: [w('a', 2)]),
        ],
        categories: {'a': 2, 'b': 1, 'c': 1, 'x': 1},
        movesLeft: 5,
      );
      final r = applyOk(
        s,
        const PlaceMove(
          unit: ColumnUnitRef(column: 0, startIndex: 0),
          target: ColumnTargetRef(3),
        ),
      );
      expect(r.next.columns[0].faceUp.single.id, 'w:x:1'); // flip oldu
      expect(r.next.status, GameStatus.lostDeadlock);
    });
  });

  group('mini bölüm tam oyun', () {
    test('bilinen çözüm 8 hamlede kazanır', () {
      final session = GameSession.start(miniLevel());
      for (final m in miniSolution()) {
        final r = session.play(m);
        expect(
          r,
          isA<Ok<List<GameEvent>, RuleViolation>>(),
          reason: 'çözüm hamlesi geçerli olmalı',
        );
      }
      expect(session.state.status, GameStatus.won);
      expect(session.moveCount, 8);
    });
  });

  group('geri alma', () {
    test('her hamle geri alınca durum birebir eski haline döner', () {
      final session = GameSession.start(miniLevel());
      final snapshots = <String>[Serde.stateToJson(session.state).toString()];
      for (final m in miniSolution()) {
        session.play(m);
        snapshots.add(Serde.stateToJson(session.state).toString());
      }
      // Sondan başa geri al, her adımda snapshot eşleşmeli.
      for (var i = snapshots.length - 1; i > 0; i--) {
        expect(Serde.stateToJson(session.state).toString(), snapshots[i]);
        expect(session.undo(), isTrue);
      }
      expect(Serde.stateToJson(session.state).toString(), snapshots[0]);
      expect(session.canUndo, isFalse);
    });

    test('kayıptan geri almak oyunu sürdürür', () {
      final s = st(
        columns: [
          col(up: [w('m', 1)]),
          col(up: [w('m', 2)]),
        ],
        categories: {'m': 2, 'h': 2},
        movesLeft: 1,
      );
      final session = GameSession.fromState(s);
      session.play(
        const PlaceMove(
          unit: ColumnUnitRef(column: 1, startIndex: 0),
          target: ColumnTargetRef(0),
        ),
      );
      expect(session.state.isLost, isTrue);
      expect(session.undo(), isTrue);
      expect(session.state.isPlaying, isTrue);
      expect(session.state.movesLeft, 1);
    });
  });
}
