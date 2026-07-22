// Günlük seri (streak) mantığı + kalıcılık.
import 'package:flutter_test/flutter_test.dart';
import 'package:manasal_solitaire/app/meta/meta_service.dart';
import 'package:manasal_solitaire/persistence/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<MetaService> _fresh() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return MetaService.load(Store(prefs));
}

void main() {
  test('art arda günler seriyi artırır', () async {
    final m = await _fresh();
    expect(m.dailyStreak, 0);
    m.recordDaily(10, 3);
    expect(m.dailyStreak, 1);
    m.recordDaily(11, 2);
    expect(m.dailyStreak, 2);
    m.recordDaily(12, 1);
    expect(m.dailyStreak, 3);
    expect(m.dailyBestStreak, 3);
  });

  test('gün atlamak seriyi sıfırlar (rekor korunur)', () async {
    final m = await _fresh();
    m.recordDaily(10, 3);
    m.recordDaily(11, 3); // seri 2
    m.recordDaily(13, 3); // gün 12 atlandı → seri 1
    expect(m.dailyStreak, 1);
    expect(m.dailyBestStreak, 2);
  });

  test(
    'aynı günü tekrar oynamak seriyi değiştirmez, yıldızı iyileştirir',
    () async {
      final m = await _fresh();
      m.recordDaily(10, 1);
      expect(m.dailyStreak, 1);
      expect(m.dailyStars(10), 1);
      expect(m.isDailyPlayed(10), isTrue);
      m.recordDaily(10, 3); // aynı gün, daha iyi sonuç
      expect(m.dailyStreak, 1); // seri değişmedi
      expect(m.dailyStars(10), 3); // yıldız iyileşti
      m.recordDaily(10, 2); // daha kötü → düşürmez
      expect(m.dailyStars(10), 3);
    },
  );

  test('kalıcılık: yeniden yükleme seri + yıldızı korur', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final m1 = MetaService.load(Store(prefs));
    m1.recordDaily(20, 2);
    m1.recordDaily(21, 3);
    final m2 = MetaService.load(Store(prefs));
    expect(m2.dailyStreak, 2);
    expect(m2.dailyBestStreak, 2);
    expect(m2.dailyStars(21), 3);
    expect(m2.lastDailyDayIndex, 21);
    expect(m2.isDailyPlayed(20), isTrue);
    expect(m2.isDailyPlayed(99), isFalse);
  });
}
