// Ayarlar: "Kullanım verisi" alt metni doğru (anonim iddiası yok), anahtar
// meta'yı günceller; dar (iPhone) ve geniş (iPad) ekranda taşma yok.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manasal_solitaire/app/meta/meta_scope.dart';
import 'package:manasal_solitaire/app/meta/meta_service.dart';
import 'package:manasal_solitaire/app/screens/settings_screen.dart';
import 'package:manasal_solitaire/app/theme/app_theme.dart';
import 'package:manasal_solitaire/persistence/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _usageSubtitle =
    'Oyun istatistikleri ve çökme raporları (Firebase). '
    'Kimliğinle eşleştirilmez.';

Future<MetaService> _fresh() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return MetaService.load(Store(prefs));
}

Future<void> _pump(WidgetTester tester, MetaService meta, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MetaScope(
      service: meta,
      child: MaterialApp(theme: AppTheme.light(), home: const SettingsScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final (name, size) in const [
    ('iPhone SE', Size(320, 568)),
    ('iPhone Pro Max', Size(440, 956)),
    ('iPad', Size(1032, 1376)),
  ]) {
    testWidgets('Kullanım verisi metni doğru ve sığar ($name)', (tester) async {
      final meta = await _fresh();
      await _pump(tester, meta, size);

      expect(find.text('Kullanım verisi'), findsOneWidget);
      expect(find.text(_usageSubtitle), findsOneWidget);
      // "Anonim" iddiası hiçbir yerde kalmadı.
      expect(find.textContaining('nonim'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Kullanım verisi anahtarı meta.analyticsEnabled\'ı çevirir', (
    tester,
  ) async {
    final meta = await _fresh();
    expect(meta.analyticsEnabled, isTrue);
    await _pump(tester, meta, const Size(440, 956));

    final row = find.ancestor(
      of: find.text('Kullanım verisi'),
      matching: find.byType(Row),
    );
    final toggle = find.descendant(
      of: row.first,
      matching: find.byType(Switch),
    );
    expect(toggle, findsOneWidget);

    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(meta.analyticsEnabled, isFalse);

    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(meta.analyticsEnabled, isTrue);
  });
}
