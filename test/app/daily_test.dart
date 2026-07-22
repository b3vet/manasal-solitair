// Günlük bulmaca çekirdeği: tarih→gün indeksi, deterministik üretim,
// çözülebilirlik ve spoiler'sız paylaşım metni.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:manasal_solitaire/app/daily/daily_service.dart';
import 'package:manasal_solitaire/app/daily/daily_share.dart';
import 'package:manasal_solitaire/content/loader.dart';
import 'package:manasal_solitaire/generator/solver.dart';

void main() {
  group('gün indeksi', () {
    test('epoch = 0, sonraki günler artar', () {
      expect(DailyService.dayIndexUtc(DateTime.utc(2026, 1, 1)), 0);
      expect(DailyService.dayIndexUtc(DateTime.utc(2026, 1, 2)), 1);
      expect(DailyService.dayIndexUtc(DateTime.utc(2026, 1, 31)), 30);
      expect(DailyService.dayIndexUtc(DateTime.utc(2027, 1, 1)), 365);
    });

    test('yerel saat UTC güne eşlenir', () {
      // Aynı takvim günü içindeki farklı saatler aynı indeks.
      final a = DailyService.dayIndexUtc(DateTime.utc(2026, 3, 10, 0, 5));
      final b = DailyService.dayIndexUtc(DateTime.utc(2026, 3, 10, 23, 55));
      expect(a, b);
    });
  });

  group('günlük üretim', () {
    final pool = Loader.parse(
      File('assets/content/categories.json').readAsStringSync(),
    );

    test('aynı gün → bit-bit aynı bölüm (deterministik)', () {
      final s1 = DailyService(pool);
      final s2 = DailyService(pool);
      final l1 = s1.forDayIndex(42);
      final l2 = s2.forDayIndex(42);
      expect(l1.moveLimit, l2.moveLimit);
      expect(l1.totalCards, l2.totalCards);
      expect(l1.columns.length, l2.columns.length);
      expect(
        l1.stock.map((c) => c.id).toList(),
        l2.stock.map((c) => c.id).toList(),
      );
      for (var c = 0; c < l1.columns.length; c++) {
        expect(
          l1.columns[c].faceDown.map((x) => x.id).toList(),
          l2.columns[c].faceDown.map((x) => x.id).toList(),
        );
      }
    });

    test('farklı günler farklı bölüm', () {
      final s = DailyService(pool);
      final a = s.forDayIndex(1);
      final b = s.forDayIndex(2);
      // Aynı olması neredeyse imkânsız; en azından bir fark bekleriz.
      final same =
          a.stock.map((c) => c.id).join() == b.stock.map((c) => c.id).join();
      expect(same, isFalse);
    });

    test('örneklem günler çözülebilir ve limit içinde', () {
      final s = DailyService(pool);
      for (final day in [0, 1, 50, 100, 365]) {
        final lvl = s.forDayIndex(day);
        expect(lvl.moveLimit, greaterThan(0));
        final res = Solver.solve(lvl, maxNodes: 400000);
        expect(res.solved, isTrue, reason: 'gün $day çözülemedi');
        expect(
          res.moveCount,
          lessThanOrEqualTo(lvl.moveLimit),
          reason: 'gün $day: çözüm limiti aşıyor',
        );
      }
    });
  });

  group('paylaşım metni (spoiler\'sız)', () {
    test('tarih etiketi Türkçe kısa ay', () {
      expect(dailyDateLabel(DateTime.utc(2026, 7, 22)), '22 Tem');
      expect(dailyDateLabel(DateTime.utc(2026, 1, 3)), '3 Oca');
      expect(dailyDateLabel(DateTime.utc(2026, 12, 31)), '31 Ara');
    });

    test('yıldız satırı 3 yuva', () {
      expect(starRow(3), '⭐⭐⭐');
      expect(starRow(2), '⭐⭐☆');
      expect(starRow(0), '☆☆☆');
    });

    test('kart metni yıldız+hamle+seri içerir, kategori sızdırmaz', () {
      final t = dailyShareText(
        date: DateTime.utc(2026, 7, 22),
        stars: 3,
        movesUsed: 24,
        streak: 7,
      );
      expect(t, contains('22 Tem'));
      expect(t, contains('⭐⭐⭐'));
      expect(t, contains('24 hamle'));
      expect(t, contains('🔥 7 gün'));
      expect(t, contains('b3vet.github.io'));
    });

    test('seri 0 ise seri satırı yok', () {
      final t = dailyShareText(
        date: DateTime.utc(2026, 7, 22),
        stars: 1,
        movesUsed: 30,
        streak: 0,
      );
      expect(t, isNot(contains('🔥')));
    });
  });
}
