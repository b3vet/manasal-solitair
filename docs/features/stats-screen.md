# Özellik Planı — İstatistik Ekranı

**Roadmap:** Faz 2.3 · **Öncelik:** 2 · **Efor:** S–M · **Durum:** ✅ bitti

## Amaç

Oyuncuya ilerleme hissi + kendini ölçme. Var olan meta verisinden türetilir;
yeni bir oyun döngüsü eklemez, mevcut kazanımları görünür kılar (retention'a
dolaylı katkı — "neredeyim?" sorusuna cevap).

## Gösterilecekler (mevcut veriden)

**Kampanya**
- Tamamlanan bölüm: `highestCompleted / toplam`.
- Toplam yıldız: `Σ starRating(bestMovesLeft, moveLimit)` (levels gerekir).
- Toplanan kategori: `totalCategoriesCompleted`.
- Verimli bölüm (≥%40 kalan): `efficientCount()`.
- İlk-deneme serisi (güncel): `streak`.

**Günlük**
- Güncel seri / en iyi seri: `dailyStreak` / `dailyBestStreak`.
- Oynanan günlük: `dailyPlayedCount`.
- 3-yıldız günlük: `dailyThreeStarCount`.

**Cüzdan**
- Kredi: `credits`.

## Tasarım

- Yeni `lib/app/screens/stats_screen.dart` — Kilim stili: `kilimAppBar`,
  bölümlü (Kampanya / Günlük / Cüzdan) istatistik kartları ızgarası. Her hücre:
  büyük sayı (Manrope w800) + küçük etiket; ikon vurgusu (altın/terrakotta).
- Levels, ana ekrandan geçirilir (`StatsScreen(levels: levels)`) — toplam yıldız
  için gerekli.
- Giriş: ana ekran alt bağlantı satırına "İstatistik" (satır `Wrap`'e çevrilir,
  4 bağlantı taşarsa ikinci satıra akar).

## Veri modeli (küçük eklemeler)

`meta_service.dart` — yalnız türetme getter'ları (yeni kalıcı alan yok):

```dart
int get dailyPlayedCount => _dailyStars.length;
int get dailyThreeStarCount => _dailyStars.values.where((s) => s == 3).length;
```

_(Kazanma oranı için oynanan/kazanılan bölüm sayacı ileride eklenebilir; v1
mevcut veriyle yetinir — yeni durum tutmaz.)_

## Test

- `meta` getter'ları (`dailyPlayedCount`, `dailyThreeStarCount`).
- StatsScreen smoke: örnek meta + levels ile pump, çökme yok, birkaç sayı
  görünür.
- Görsel: `stats` yakalaması (isteğe bağlı).

## Kabul kriterleri

- [x] Kampanya + günlük + cüzdan istatistikleri doğru türetilir
  (`test/app/stats_test.dart`).
- [x] Ana ekrandan erişilir ("İstatistik" bağlantısı; bağlantı satırı `Wrap`).
- [x] Kilim stili; boş durumda (yeni oyuncu) makul sıfırlar gösterir. Görsel:
  `stats` yakalaması.
