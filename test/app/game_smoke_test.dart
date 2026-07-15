import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manasal_solitaire/app/game/game_board.dart';
import 'package:manasal_solitaire/app/game/game_controller.dart';
import 'package:manasal_solitaire/app/game/game_screen.dart';
import 'package:manasal_solitaire/app/meta/meta_scope.dart';
import 'package:manasal_solitaire/app/meta/meta_service.dart';
import 'package:manasal_solitaire/app/theme/app_theme.dart';
import 'package:manasal_solitaire/content/levels_repository.dart';
import 'package:manasal_solitaire/engine/engine.dart';
import 'package:manasal_solitaire/generator/solver.dart';
import 'package:manasal_solitaire/persistence/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<MetaService> _meta() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return MetaService.load(Store(prefs));
}

List<LevelDef> _levels() => LevelsRepository.parse(
  File('assets/levels/levels.json').readAsStringSync(),
);

void main() {
  testWidgets('oyun ekranı hata olmadan render olur ve hamle kabul eder', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2280);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final meta = await _meta();
    final levels = _levels();

    await tester.pumpWidget(
      MetaScope(
        service: meta,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: GameScreen(levels: levels, startIndex: 0),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(GameBoard), findsOneWidget);

    final board = tester.getRect(find.byType(GameBoard));
    await tester.tapAt(Offset(board.left + 40, board.bottom - 40));
    await tester.pumpAndSettle();
  });

  testWidgets('bir bölüm çözümü UI üzerinden oynanıp kazanılır (motor+board)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2280);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final levels = _levels();
    final level = levels[0];
    final solution = Solver.solve(level).solution!;
    final controller = GameController(level);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: GameBoard(controller: controller)),
      ),
    );
    await tester.pump();

    for (final m in solution) {
      final ok = switch (m) {
        DrawMove() => controller.draw(),
        RecycleMove() => controller.recycle(),
        PlaceMove(:final unit, :final target) => controller.place(unit, target),
      };
      expect(ok, isTrue, reason: 'çözüm hamlesi UI üzerinden uygulanmalı');
      await tester.pump(const Duration(milliseconds: 300));
    }

    expect(controller.state.status, GameStatus.won);
  });

  testWidgets('kazanınca ilerleme ve kredi kaydedilir (meta entegrasyon)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2280);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final meta = await _meta();
    final startCredits = meta.credits; // ilk açılış: 3
    final levels = _levels();
    final solution = Solver.solve(levels[0]).solution!;

    // recordWin'i doğrudan çağırarak meta akışını doğrula (UI diyaloğu beklemeden).
    final awarded = meta.recordWin(
      levelId: levels[0].id,
      movesLeft: levels[0].moveLimit,
      moveLimit: levels[0].moveLimit,
      categoriesInLevel: levels[0].totalCategories,
      firstTry: true,
    );
    expect(meta.isCompleted(1), isTrue);
    expect(meta.unlockedUpTo, greaterThanOrEqualTo(2));
    expect(meta.credits, startCredits + awarded);
    expect(awarded, greaterThan(0)); // en az "İlk zafer" +2
    expect(solution, isNotEmpty);
  });
}
