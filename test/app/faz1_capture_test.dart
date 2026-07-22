// Faz 1 görsel doğrulama: kazanma diyaloğu (1/2/3 yıldız), etkileşimli öğretici
// bindirmesi ve oyun-içi 3-yıldız HUD hedefi. Golden karşılaştırması yapmaz;
// build/screens/*.png üretir. SCREENSHOTS=1 ile çalışır.
//
// toImage/toByteData GERÇEK async'tir → mutlaka `tester.runAsync` içinde.
// MaterialIcons yüklenmezse ikonlar "tofu" kutusu çıkar; yerel Flutter
// önbelleğinden yüklenir (bu test zaten yalnız yerelde, SCREENSHOTS=1 ile koşar).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manasal_solitaire/app/game/game_board.dart';
import 'package:manasal_solitaire/app/game/game_controller.dart';
import 'package:manasal_solitaire/app/game/tutorial.dart';
import 'package:manasal_solitaire/app/game/tutorial_level.dart';
import 'package:manasal_solitaire/app/game/widgets/dialogs.dart';
import 'package:manasal_solitaire/app/theme/app_theme.dart';
import 'package:manasal_solitaire/engine/engine.dart';

Future<void> _loadFonts() async {
  Future<ByteData> read(String p) async =>
      ByteData.view(File(p).readAsBytesSync().buffer);
  await (FontLoader('Lora')..addFont(read('assets/fonts/Lora.ttf'))).load();
  await (FontLoader(
    'Manrope',
  )..addFont(read('assets/fonts/Manrope.ttf'))).load();
  // MaterialIcons — yerel Flutter önbelleğinden (varsa).
  for (final p in const [
    '/root/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ]) {
    if (File(p).existsSync()) {
      await (FontLoader('MaterialIcons')..addFont(read(p))).load();
      break;
    }
  }
}

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    Directory('build/screens').createSync(recursive: true);
    File(
      'build/screens/$name.png',
    ).writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

Widget _wrap(Widget child) => RepaintBoundary(
  key: _rootKey,
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    home: child,
  ),
);

final _rootKey = GlobalKey();

/// HUD'daki 3-yıldız hedefini göstermek için küçük, hamle limitli sentetik bölüm.
LevelDef _hudLevel() => const LevelDef(
  id: 7,
  seed: 0,
  columnCount: 4,
  slotCount: 4,
  moveLimit: 20,
  categories: [
    LevelCategory(categoryId: 'meyveler', name: 'Meyveler', totalWords: 3),
    LevelCategory(categoryId: 'renkler', name: 'Renkler', totalWords: 3),
  ],
  columns: [
    ColumnDeal(
      faceDown: [],
      faceUp: [
        WordCard(id: 'w:meyveler:0', word: 'Elma', categoryId: 'meyveler'),
      ],
    ),
    ColumnDeal(
      faceDown: [],
      faceUp: [
        WordCard(id: 'w:renkler:0', word: 'Mavi', categoryId: 'renkler'),
      ],
    ),
    ColumnDeal(
      faceDown: [],
      faceUp: [
        WordCard(id: 'w:meyveler:1', word: 'Kiraz', categoryId: 'meyveler'),
      ],
    ),
    ColumnDeal(faceDown: [], faceUp: []),
  ],
  stock: [
    CategoryCard(
      id: 'c:meyveler',
      categoryId: 'meyveler',
      name: 'Meyveler',
      totalInLevel: 3,
    ),
    CategoryCard(
      id: 'c:renkler',
      categoryId: 'renkler',
      name: 'Renkler',
      totalInLevel: 3,
    ),
  ],
);

void main() {
  final skip = Platform.environment['SCREENSHOTS'] != '1';

  testWidgets('Faz 1 görselleri', (tester) async {
    if (skip) return markTestSkipped('SCREENSHOTS=1 gerekli');
    await _loadFonts();
    tester.view.physicalSize = const Size(840, 1500);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    // --- Kazanma diyaloğu: 3 / 2 / 1 yıldız ---
    final wins = <String, List<int>>{
      'win_3star': [9, 20],
      'win_2star': [5, 20],
      'win_1star': [2, 20],
    };
    for (final e in wins.entries) {
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
              body: Align(
                alignment: Alignment.bottomCenter,
                child: KilimSheet(
                  child: WinDialogContent(
                    movesLeft: e.value[0],
                    moveLimit: e.value[1],
                    creditsAwarded: 2,
                    hasNext: true,
                    levelId: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
      await _capture(tester, _rootKey, e.key);
    }

    // --- Etkileşimli öğretici bindirmesi (ilk adım) ---
    final tutGame = GameController(tutorialLevel());
    final tut = TutorialController(game: tutGame, onComplete: () {});
    addTearDown(tut.dispose);
    await tester.pumpWidget(
      _wrap(
        Scaffold(
          backgroundColor: AppTheme.light().colorScheme.surface,
          body: SafeArea(
            child: GameBoard(controller: tutGame, tutorial: tut),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await _capture(tester, _rootKey, 'tutorial_overlay');

    // --- Oyun-içi 3-yıldız HUD hedefi ---
    final hud = GameController(_hudLevel());
    await tester.pumpWidget(
      _wrap(
        Scaffold(
          backgroundColor: AppTheme.light().colorScheme.surface,
          body: SafeArea(child: GameBoard(controller: hud)),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await _capture(tester, _rootKey, 'hud_star_goal');
  });
}
