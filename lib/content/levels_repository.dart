/// Materyalize bölümlerin (levels.json) ayrıştırılması ve bütünlük kontrolü.
library;

import 'dart:convert';

import '../engine/level.dart';
import '../engine/serde.dart';

class LevelsRepository {
  const LevelsRepository._();

  static List<LevelDef> parse(String jsonStr) {
    final j = jsonDecode(jsonStr) as Map<String, dynamic>;
    final levels = <LevelDef>[
      for (final l in (j['levels'] as List).cast<Map<String, dynamic>>())
        Serde.levelFromJson(l),
    ];
    for (final level in levels) {
      _validate(level);
    }
    return levels;
  }

  static String encode(List<LevelDef> levels, {int schemaVersion = 1}) =>
      const JsonEncoder.withIndent('  ').convert({
        'schemaVersion': schemaVersion,
        'levels': [for (final l in levels) Serde.levelToJson(l)],
      });

  static void _validate(LevelDef level) {
    // Kategori kelime toplamları, kartlardaki gerçek sayılarla uyuşmalı.
    final counts = <String, int>{};
    for (final col in level.columns) {
      for (final c in [...col.faceDown, ...col.faceUp]) {
        if (c.id.startsWith('w:')) {
          counts[c.categoryId] = (counts[c.categoryId] ?? 0) + 1;
        }
      }
    }
    for (final c in level.stock) {
      if (c.id.startsWith('w:')) {
        counts[c.categoryId] = (counts[c.categoryId] ?? 0) + 1;
      }
    }
    for (final cat in level.categories) {
      final actual = counts[cat.categoryId] ?? 0;
      if (actual != cat.totalWords) {
        throw StateError(
          'Bölüm ${level.id}: ${cat.categoryId} için kelime sayısı '
          'uyuşmuyor (beklenen ${cat.totalWords}, bulunan $actual)',
        );
      }
    }
    if (level.moveLimit <= 0) {
      throw StateError('Bölüm ${level.id}: geçersiz moveLimit');
    }
  }
}
