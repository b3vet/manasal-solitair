import 'package:flutter_test/flutter_test.dart';
import 'package:manasal_solitaire/engine/prng.dart';

void main() {
  group('Prng', () {
    test('aynı tohum aynı diziyi üretir (determinizm)', () {
      final a = Prng(12345);
      final b = Prng(12345);
      for (var i = 0; i < 100; i++) {
        expect(a.nextUint32(), b.nextUint32());
      }
    });

    test('farklı tohum farklı dizi üretir', () {
      final a = Prng(1);
      final b = Prng(2);
      var differences = 0;
      for (var i = 0; i < 50; i++) {
        if (a.nextUint32() != b.nextUint32()) differences++;
      }
      expect(differences, greaterThan(40));
    });

    test('nextInt sınır içinde kalır ve bias yok', () {
      final r = Prng(99);
      final counts = List<int>.filled(6, 0);
      for (var i = 0; i < 60000; i++) {
        final v = r.nextInt(6);
        expect(v, inInclusiveRange(0, 5));
        counts[v]++;
      }
      // Kabaca eşit dağılım (her yüz ~10000).
      for (final c in counts) {
        expect(c, inInclusiveRange(9000, 11000));
      }
    });

    test('nextInt(1) daima 0', () {
      final r = Prng(7);
      for (var i = 0; i < 10; i++) {
        expect(r.nextInt(1), 0);
      }
    });

    test('shuffle deterministik ve permütasyonu korur', () {
      List<int> shuffled(int seed) {
        final list = List<int>.generate(20, (i) => i);
        Prng(seed).shuffle(list);
        return list;
      }

      final s1 = shuffled(42);
      final s2 = shuffled(42);
      expect(s1, s2);
      expect(s1.toSet(), List<int>.generate(20, (i) => i).toSet());
      expect(s1, isNot(List<int>.generate(20, (i) => i))); // karıştı
    });

    test('fork bağımsız akış üretir', () {
      final base = Prng(5);
      final f1 = base.fork(1);
      final base2 = Prng(5);
      final f1b = base2.fork(1);
      // Aynı base + aynı streamId → aynı fork.
      expect(f1.nextUint32(), f1b.nextUint32());

      final base3 = Prng(5);
      final f2 = base3.fork(2);
      // Farklı streamId → farklı akış (çok yüksek olasılıkla).
      expect(f1.nextUint32(), isNot(f2.nextUint32()));
    });
  });
}
