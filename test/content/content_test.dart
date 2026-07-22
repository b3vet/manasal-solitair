import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:manasal_solitaire/content/levels_repository.dart';
import 'package:manasal_solitaire/content/loader.dart';
import 'package:manasal_solitaire/content/validator.dart';
import 'package:manasal_solitaire/generator/curve.dart';
import 'package:manasal_solitaire/generator/solver.dart';

void main() {
  test('categories.json geçerli (sıfır hata)', () {
    final pool = Loader.parse(
      File('assets/content/categories.json').readAsStringSync(),
    );
    final errors = ContentValidator.validate(
      pool,
    ).where((i) => i.severity == 'error').toList();
    expect(errors, isEmpty, reason: errors.join('\n'));
    expect(pool.length, greaterThanOrEqualTo(28));
  });

  test('levels.json bütünlük + örneklem çözülebilirlik', () {
    final levels = LevelsRepository.parse(
      File('assets/levels/levels.json').readAsStringSync(),
    );
    expect(levels.length, greaterThanOrEqualTo(60));

    // Bölüm numaraları 1..N sıralı ve limit pozitif.
    for (var i = 0; i < levels.length; i++) {
      expect(levels[i].id, i + 1);
      expect(levels[i].moveLimit, greaterThan(0));
    }

    // Örneklem: her 12 bölümden biri çözücüden yeniden geçsin.
    // Düğüm bütçesi üreticiyle aynı (kabul edilen her bölüm bu bütçede çözüldü).
    for (var i = 0; i < levels.length; i += 12) {
      final res = Solver.solve(levels[i], maxNodes: 400000);
      expect(res.solved, isTrue, reason: 'Bölüm ${levels[i].id} çözülemedi');
      // Çözüm, bölümün hamle limiti içinde mi?
      expect(
        res.moveCount,
        lessThanOrEqualTo(levels[i].moveLimit),
        reason: 'Bölüm ${levels[i].id}: çözüm limiti aşıyor',
      );
    }
  });

  group('belirsizlik koruması (iki katman)', () {
    final pool = Loader.parse(
      File('assets/content/categories.json').readAsStringSync(),
    );
    final levels = LevelsRepository.parse(
      File('assets/levels/levels.json').readAsStringSync(),
    );
    final hardMap = ContentValidator.symmetricHardConflicts(pool);
    final softMap = ContentValidator.symmetricSoftConflicts(pool);

    test('hiçbir bölümde HARD çakışan kategori çifti yok', () {
      final bad = <String>[];
      for (final lvl in levels) {
        final ids = lvl.categories.map((c) => c.categoryId).toList();
        for (var i = 0; i < ids.length; i++) {
          for (var j = i + 1; j < ids.length; j++) {
            if ((hardMap[ids[i]] ?? const {}).contains(ids[j])) {
              bad.add('Bölüm ${lvl.id}: ${ids[i]} ↔ ${ids[j]}');
            }
          }
        }
      }
      expect(bad, isEmpty, reason: bad.join('\n'));
    });

    test(
      'adil aralık bölümlerinde (allowSoftConflict=false) SOFT çakışma yok',
      () {
        final bad = <String>[];
        for (final lvl in levels) {
          // Yüksek seviye (allowSoftConflict) soft çakışmaya serbest.
          if (curveFor(lvl.id).allowSoftConflict) continue;
          final ids = lvl.categories.map((c) => c.categoryId).toList();
          for (var i = 0; i < ids.length; i++) {
            for (var j = i + 1; j < ids.length; j++) {
              if ((softMap[ids[i]] ?? const {}).contains(ids[j])) {
                bad.add('Bölüm ${lvl.id}: ${ids[i]} ↔ ${ids[j]}');
              }
            }
          }
        }
        expect(bad, isEmpty, reason: bad.join('\n'));
      },
    );

    test('bir çift hem hard hem soft değil (hard baskın)', () {
      final bad = <String>[];
      for (final c in pool.categories) {
        final both = c.softConflicts.toSet().intersection(
          c.hardConflicts.toSet(),
        );
        for (final b in both) {
          bad.add('${c.id} ↔ $b');
        }
      }
      expect(bad, isEmpty, reason: bad.join('\n'));
    });

    test('çakışma kapsamı anlamlı (denetim sonrası)', () {
      final withEdge = pool.categories
          .where(
            (c) => c.softConflicts.isNotEmpty || c.hardConflicts.isNotEmpty,
          )
          .length;
      // Denetim öncesi 32/640 idi; sonrası belirgin biçimde yüksek olmalı.
      expect(
        withEdge,
        greaterThanOrEqualTo(80),
        reason: 'yalnızca $withEdge kategoride çakışma kenarı var',
      );
    });
  });
}
