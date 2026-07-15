import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:manasal_solitaire/content/levels_repository.dart';
import 'package:manasal_solitaire/content/loader.dart';
import 'package:manasal_solitaire/content/validator.dart';
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
    for (var i = 0; i < levels.length; i += 12) {
      final res = Solver.solve(levels[i], maxNodes: 300000);
      expect(res.solved, isTrue, reason: 'Bölüm ${levels[i].id} çözülemedi');
      // Çözüm, bölümün hamle limiti içinde mi?
      expect(
        res.moveCount,
        lessThanOrEqualTo(levels[i].moveLimit),
        reason: 'Bölüm ${levels[i].id}: çözüm limiti aşıyor',
      );
    }
  });
}
