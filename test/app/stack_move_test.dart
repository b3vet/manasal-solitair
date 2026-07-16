// Üst üste (aynı kategori) açık kartlar tek birim taşınır: en üstteki kartı
// sürüklesen bile altındaki(ler) beraber gider; ayrı ayrı koparılamaz.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manasal_solitaire/app/game/board_metrics.dart';
import 'package:manasal_solitaire/app/game/game_board.dart';
import 'package:manasal_solitaire/app/game/game_controller.dart';
import 'package:manasal_solitaire/app/theme/app_theme.dart';
import 'package:manasal_solitaire/content/levels_repository.dart';
import 'package:manasal_solitaire/engine/engine.dart';

void main() {
  testWidgets(
    'aynı kategori yığını en üstten sürüklenince beraber hareket eder',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2280);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      final levels = LevelsRepository.parse(
        File('assets/levels/levels.json').readAsStringSync(),
      );
      // L1: kolon 0 (Gemi) ve kolon 1 (Tramvay) ikisi de 'tasitlar'.
      final controller = GameController(levels[0]);

      // Kolon 1'in kartını kolon 0'a koy → kolon 0 açık: [Gemi, Tramvay].
      final ok = controller.place(
        const ColumnUnitRef(column: 1, startIndex: 0),
        const ColumnTargetRef(0),
      );
      expect(ok, isTrue);
      expect(controller.state.columns[0].faceUp.length, 2);
      expect(controller.state.columns[1].isEmpty, isTrue);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(body: GameBoard(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      final rect = tester.getRect(find.byType(GameBoard));
      final counts = [
        for (final c in controller.state.columns)
          c.faceDown.length + c.faceUp.length,
      ];
      final faceDown = [
        for (final c in controller.state.columns) c.faceDown.length,
      ];
      final m = BoardMetrics(
        size: rect.size,
        columnCount: 5,
        slotCount: 5,
        columnCounts: counts,
        columnFaceDown: faceDown,
      );
      // En ÜSTTEKİ görünür kart = Tramvay (kolon 0, açık index 1).
      final topCardCenter =
          rect.topLeft +
          m.cardTopLeft(0, 1) +
          Offset(m.card.width / 2, m.card.height / 2);
      // Hedef: artık boş olan kolon 1.
      final col1Center =
          rect.topLeft +
          m.columnTopLeft(1) +
          Offset(m.card.width / 2, m.card.height / 2);

      final g = await tester.startGesture(topCardCenter);
      await tester.pump();
      await g.moveBy(const Offset(0, -24)); // sürüklemeyi başlat
      await tester.pump();
      await g.moveTo(col1Center);
      await tester.pump();
      await g.up();
      await tester.pumpAndSettle();

      // Tüm yığın taşındı: kolon 0 boşaldı, kolon 1'de HER İKİ kart var.
      expect(
        controller.state.columns[0].faceUp,
        isEmpty,
        reason: 'en üstteki kart sürüklenince alttaki de gitmeli (koparılamaz)',
      );
      final moved = controller.state.columns[1].faceUp;
      expect(moved.length, 2, reason: 'Gemi + Tramvay beraber taşınmalı');
      expect(
        moved.whereType<WordCard>().map((w) => w.word),
        containsAll(<String>['Gemi', 'Tramvay']),
      );
    },
  );
}
