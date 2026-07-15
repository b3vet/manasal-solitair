// Oyun ekranı görüntüsü yakalar (build/screens/*.png). Golden karşılaştırması
// yapmaz; yalnızca görsel doğrulama için PNG üretir. SCREENSHOTS=1 ile çalışır.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manasal_solitaire/app/game/game_screen.dart';
import 'package:manasal_solitaire/app/meta/meta_scope.dart';
import 'package:manasal_solitaire/app/meta/meta_service.dart';
import 'package:manasal_solitaire/app/theme/app_theme.dart';
import 'package:manasal_solitaire/content/levels_repository.dart';
import 'package:manasal_solitaire/persistence/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _loadFonts() async {
  Future<ByteData> read(String p) async =>
      ByteData.view(File(p).readAsBytesSync().buffer);
  final loader = FontLoader('Roboto')
    ..addFont(read('assets/fonts/Roboto-Regular.ttf'))
    ..addFont(read('assets/fonts/Roboto-Medium.ttf'))
    ..addFont(read('assets/fonts/Roboto-Bold.ttf'))
    ..addFont(read('assets/fonts/Roboto-Black.ttf'));
  await loader.load();
}

Future<void> _capture(WidgetTester tester, Widget app, String name) async {
  final key = GlobalKey();
  await tester.pumpWidget(RepaintBoundary(key: key, child: app));
  await tester.pumpAndSettle();
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 2);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  Directory('build/screens').createSync(recursive: true);
  File('build/screens/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  testWidgets('oyun tahtası görüntüsü', (tester) async {
    if (Platform.environment['SCREENSHOTS'] != '1') {
      markTestSkipped('SCREENSHOTS=1 gerekli');
      return;
    }
    await _loadFonts();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final meta = MetaService.load(Store(prefs));

    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    final levels = LevelsRepository.parse(
      File('assets/levels/levels.json').readAsStringSync(),
    );

    Widget app(ThemeData theme, int idx) => MetaScope(
      service: meta,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: GameScreen(levels: levels, startIndex: idx),
      ),
    );

    await _capture(tester, app(AppTheme.light(), 0), 'board_level_1');
    await _capture(tester, app(AppTheme.light(), 11), 'board_level_12');
    await _capture(tester, app(AppTheme.dark(), 11), 'board_dark');
  });
}
