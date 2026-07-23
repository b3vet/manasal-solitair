// İstatistik: meta türetme getter'ları + StatsScreen dumanı (çökme yok).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manasal_solitaire/app/meta/meta_scope.dart';
import 'package:manasal_solitaire/app/meta/meta_service.dart';
import 'package:manasal_solitaire/app/screens/stats_screen.dart';
import 'package:manasal_solitaire/app/theme/app_theme.dart';
import 'package:manasal_solitaire/engine/engine.dart';
import 'package:manasal_solitaire/persistence/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<MetaService> _fresh() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return MetaService.load(Store(prefs));
}

List<LevelDef> _levels() => const [
  LevelDef(
    id: 1,
    seed: 0,
    columns: [],
    stock: [],
    categories: [LevelCategory(categoryId: 'a', name: 'A', totalWords: 2)],
    moveLimit: 20,
  ),
  LevelDef(
    id: 2,
    seed: 0,
    columns: [],
    stock: [],
    categories: [LevelCategory(categoryId: 'b', name: 'B', totalWords: 2)],
    moveLimit: 20,
  ),
];

void main() {
  test('günlük istatistik getter\'ları', () async {
    final m = await _fresh();
    expect(m.dailyPlayedCount, 0);
    expect(m.dailyThreeStarCount, 0);
    m.recordDaily(1, 3);
    m.recordDaily(2, 2);
    m.recordDaily(3, 3);
    expect(m.dailyPlayedCount, 3);
    expect(m.dailyThreeStarCount, 2);
  });

  testWidgets('StatsScreen render olur, temel sayılar görünür', (tester) async {
    final meta = await _fresh();
    meta.recordWin(
      levelId: 1,
      movesLeft: 18,
      moveLimit: 20,
      categoriesInLevel: 2,
      firstTry: true,
    );
    meta.recordDaily(5, 3);

    await tester.pumpWidget(
      MetaScope(
        service: meta,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: StatsScreen(levels: _levels()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('İstatistik'), findsOneWidget);
    expect(find.text('KAMPANYA'), findsOneWidget);
    expect(find.text('GÜNLÜK BULMACA'), findsOneWidget);
    expect(find.text('Bölüm'), findsOneWidget);
    expect(find.text('Güncel seri'), findsOneWidget);
    // 1 bölüm tamamlandı → "1/2".
    expect(find.text('1/2'), findsOneWidget);
  });
}
