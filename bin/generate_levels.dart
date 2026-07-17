/// Bölüm üretim hattı CLI'ı (Spec §11.2).
///
/// Kullanım:
///   dart run bin/generate_levels.dart --count 60 \
///       --out assets/levels/levels.json --report build/levels_report.md
library;

import 'dart:io';
import 'dart:math' as math;

import 'package:manasal_solitaire/content/levels_repository.dart';
import 'package:manasal_solitaire/content/loader.dart';
import 'package:manasal_solitaire/engine/engine.dart';
import 'package:manasal_solitaire/generator/curve.dart';
import 'package:manasal_solitaire/generator/level_generator.dart';
import 'package:manasal_solitaire/generator/solver.dart';

void main(List<String> args) {
  final opts = _parseArgs(args);
  final count = int.parse(opts['count'] ?? '60');
  final contentPath = opts['content'] ?? 'assets/content/categories.json';
  final outPath = opts['out'] ?? 'assets/levels/levels.json';
  final reportPath = opts['report'] ?? 'build/levels_report.md';
  final maxTries = int.parse(opts['tries'] ?? '40');
  final maxNodes = int.parse(opts['nodes'] ?? '400000');

  final pool = Loader.parse(File(contentPath).readAsStringSync());
  stdout.writeln('Havuz: ${pool.length} kategori. $count bölüm üretiliyor...');

  final levels = <LevelDef>[];
  final report = StringBuffer()
    ..writeln('# Bölüm Üretim Raporu')
    ..writeln()
    ..writeln('Havuz: ${pool.length} kategori. Üretilen: $count bölüm.')
    ..writeln()
    ..writeln(
      '| Bölüm | Tohum | Kategoriler | Kart | Çözüm | Limit | Düğüm | Deneme |',
    )
    ..writeln('|---|---|---|---|---|---|---|---|');

  final recentWindow = <String>[];
  var totalTries = 0;
  var totalNodes = 0;

  for (var lvl = 1; lvl <= count; lvl++) {
    final params = curveFor(lvl);
    LevelDef? accepted;
    SolveResult? acceptedResult;
    var usedSeed = 0;
    var tries = 0;

    // Dar hamle limiti için: birkaç çözülebilir tohum örnekle ve EN KISA
    // çözümü (optimuma en yakın) seç. Böylece limit = kısa_çözüm * marj gerçekten
    // dar olur. Aşırı uzun/dolambaçlı çözümler (limiti şişiren) elenir.
    const optimizeSamples = 3;
    LevelDef? best; // sınır içindeki en kısa
    SolveResult? bestResult;
    var bestSeed = 0;
    LevelDef? anyBest; // sınır dışı da olsa en kısa (yedek)
    SolveResult? anyBestResult;
    var anyBestSeed = 0;
    var samples = 0;
    for (var t = 0; t < maxTries; t++) {
      tries++;
      final seed = _seedFor(lvl, t);
      final level = LevelGenerator.generate(
        pool,
        lvl,
        seed,
        recentCategoryIds: recentWindow,
      );
      final res = Solver.solve(level, maxNodes: maxNodes);
      totalNodes += res.nodes;
      if (!res.solved) continue;
      if (anyBestResult == null || res.moveCount < anyBestResult.moveCount) {
        anyBest = level;
        anyBestResult = res;
        anyBestSeed = seed;
      }
      if (res.moveCount > level.totalCards * 2.2) continue; // dolambaçlı: ele
      samples++;
      if (bestResult == null || res.moveCount < bestResult.moveCount) {
        best = level;
        bestResult = res;
        bestSeed = seed;
      }
      if (samples >= optimizeSamples) break; // yeterli örnek → en kısasını al
    }
    if (best != null) {
      accepted = best;
      acceptedResult = bestResult;
      usedSeed = bestSeed;
    } else if (anyBest != null) {
      accepted = anyBest;
      acceptedResult = anyBestResult;
      usedSeed = anyBestSeed;
    }
    totalTries += tries;

    if (accepted == null || acceptedResult == null) {
      stderr.writeln(
        '⚠️  Bölüm $lvl $maxTries denemede çözülemedi, atlanıyor.',
      );
      continue;
    }

    final solLen = acceptedResult.moveCount;
    final limit = math.max(
      solLen + 5,
      (solLen * params.marginMultiplier).ceil(),
    );
    final finalLevel = accepted.copyWith(moveLimit: limit);
    levels.add(finalLevel);

    // Rotasyon penceresini güncelle.
    for (final c in finalLevel.categories) {
      recentWindow.add(c.categoryId);
    }
    while (recentWindow.length > params.rotationWindow * params.categoryCount) {
      recentWindow.removeAt(0);
    }

    final cats = finalLevel.categories
        .map((c) => '${c.name}(${c.totalWords})')
        .join(', ');
    report.writeln(
      '| $lvl | $usedSeed | $cats | ${finalLevel.totalCards} | '
      '$solLen | $limit | ${acceptedResult.nodes} | $tries |',
    );
    stdout.writeln(
      'Bölüm $lvl: ${finalLevel.totalCategories} kat, '
      '${finalLevel.totalCards} kart, çözüm $solLen, limit $limit '
      '($tries deneme)',
    );
  }

  // Yaz.
  File(outPath)
    ..createSync(recursive: true)
    ..writeAsStringSync(LevelsRepository.encode(levels));

  report
    ..writeln()
    ..writeln('Toplam deneme: $totalTries, toplam düğüm: $totalNodes.')
    ..writeln('Başarılı: ${levels.length}/$count.');
  File(reportPath)
    ..createSync(recursive: true)
    ..writeAsStringSync(report.toString());

  // Sağlama: yazılan dosya yeniden ayrıştırılabilmeli.
  LevelsRepository.parse(File(outPath).readAsStringSync());

  stdout.writeln('\n✅ ${levels.length} bölüm yazıldı → $outPath');
  stdout.writeln('   Rapor → $reportPath');
}

int _seedFor(int level, int tryIndex) => level * 1000003 + tryIndex * 97 + 7;

Map<String, String> _parseArgs(List<String> args) {
  final map = <String, String>{};
  for (var i = 0; i < args.length; i++) {
    if (args[i].startsWith('--')) {
      final key = args[i].substring(2);
      if (i + 1 < args.length && !args[i + 1].startsWith('--')) {
        map[key] = args[++i];
      } else {
        map[key] = 'true';
      }
    }
  }
  return map;
}
