# Özellik Planı — Günlük Bulmaca + Paylaşılabilir Sonuç

**Roadmap:** Faz 2.1 + 2.2 · **Öncelik:** 2 · **Efor:** M · **Durum:** 🔨 devam

## Amaç

Geri gelme sebebi #1 ve sıfır maliyetli organik büyüme döngüsü:

- **Günlük bulmaca:** Herkese aynı, güne özel tek bölüm + günlük seri (streak).
  Alışkanlık oluşturur (Wordle etkisi).
- **Paylaşılabilir sonuç:** "Bugünkü Manasal'ı 24 hamlede ⭐⭐⭐ bitirdim" emoji
  kartı (spoiler'sız). Her paylaşım yeni oyuncu kapısı.

Hedef metrik: D1/D7 retention ↑, `daily_share_tapped` ↑.

## Tasarım

### Günün tohumu (deterministik)

UTC tarih → sabit epoch'tan gün indeksi → tohum. Herkes aynı günde aynı
bulmacayı görür; motor/PRNG zaten platformdan bağımsız deterministik
(`lib/engine/prng.dart`, Spec §14.4).

```dart
// epoch: 2026-01-01 UTC = gün 0
int dayIndexUtc(DateTime nowUtc) =>
    DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day)
        .difference(DateTime.utc(2026, 1, 1)).inDays;
int dailySeed(int dayIndex) => 0x0DA1 * 1000003 + dayIndex; // ayrık uzay
```

### Bölüm üretimi (runtime)

Var olan hat yeniden kullanılır: `LevelGenerator.generate(pool, N, seed)` +
`Solver.solve` ile çözülebilirlik doğrulanır. Günlük için:

- **Zorluk:** sabit, orta bir eğri noktası (ör. `curveFor(20)` benzeri) — günlük
  herkese aynı ve "ısınmış oyuncu" seviyesinde olsun; kampanya ilerlemesinden
  bağımsız.
- **Çözülebilirlik:** küçük düğüm bütçesiyle (ör. 60k) birkaç alt-tohum dene; ilk
  çözülebilir dağıtımı al. Bütçede çözülemezse alt-tohumu artır (nadiren).
- **Performans:** tek bölüm; senkron üretim + kısa "Hazırlanıyor…" durumu. Web'de
  (dart2js) birkaç saniyeyi geçerse `compute`/isolate'a taşınır (sonraki adım).
- Günün bölümü bellekte önbelleklenir (aynı gün tekrar açılışta yeniden
  üretilmez).

### Meta veri

`lib/app/meta/meta_service.dart` — yeni alanlar (settings/progress ayrı bir
`daily` dokümanı):

```dart
int dailyStreak;            // art arda gün
int dailyBestStreak;        // rekor
int? lastDailyDayIndex;     // en son OYNANAN günün indeksi (streak mantığı)
Map<int, int> dailyStars;   // günIndex → yıldız (paylaşım + takvim için)
```

Streak kuralı: bugünü tamamla → dün de tamamlandıysa streak++ (bugün =
lastDaily+1), değilse streak=1. Aynı günü tekrar oynamak streak'i artırmaz.

### Akış / UI

- **Ana ekran giriş kartı:** "Günlük Bulmaca" — bugünün durumu (oynanmadı /
  ⭐ sonucu), seri rozeti (🔥 N). En üstte, dikkat çekici (Kilim yüzeyi).
- **Günlük oyun:** `GameScreen`'i yeniden kullan (`daily: true` bayrağı):
  kredi/başarım/ilerleme SAYMAZ (kampanyadan ayrı), resume ayrı anahtar.
  Kazanınca `meta.recordDaily(dayIndex, stars, moves)` + paylaşım butonlu özel
  kazanma diyaloğu.
- **Paylaşım:** `share_plus`. Spoiler'sız emoji kartı:

  ```
  Manasal Solitaire — 22 Tem
  ⭐⭐⭐  ·  24 hamle  ·  🔥 7 gün
  https://b3vet.github.io/manasal-solitair/
  ```

  Kategori/kelime SIZDIRMAZ (yalnız yıldız + hamle + seri + link).

### Dosyalar

- `lib/app/daily/daily_service.dart` (yeni): tarih→tohum→bölüm (önbellekli).
- `lib/app/daily/daily_share.dart` (yeni): sonuç → emoji metni (saf, testli).
- `lib/app/meta/meta_service.dart`: `daily` dokümanı + `recordDaily` + streak.
- `lib/app/game/game_screen.dart`: `daily` bayrağı (kredi/ilerleme baypas).
- `lib/app/game/widgets/dialogs.dart`: günlük kazanma diyaloğu (paylaş butonu).
- `lib/app/screens/home_screen.dart`: günlük giriş kartı + seri rozeti.
- `pubspec.yaml`: `share_plus` bağımlılığı.
- `test/`: tohum determinizmi, streak mantığı, paylaşım metni, günlük bölüm
  çözülebilirliği (örneklem).

## Riskler / kararlar

- **Runtime çözücü hızı (web):** tek bölüm + küçük bütçe → kabul edilebilir;
  gerekirse isolate. Ölçüp karar ver.
- **Saat dilimi:** UTC tabanlı gün indeksi (herkes aynı bulmaca). Yerel gece
  yarısı kayması bilinçli olarak yok sayılır (basitlik + adalet).
- **Paylaşım spoiler'ı:** yalnız yıldız/hamle/seri; kategori adı ASLA.
- **share_plus web:** Web Share API destekli tarayıcılarda çalışır; değilse
  panoya kopyala fallback.

## Kabul kriterleri

- [ ] Aynı gün → herkese aynı bulmaca (deterministik, testli).
- [ ] Günlük tamamlanınca seri güncellenir; aynı günü tekrar oynamak artırmaz.
- [ ] Ana ekranda günlük kartı + seri rozeti; oynandıysa sonuç görünür.
- [ ] Kazanma diyaloğunda "Paylaş" → spoiler'sız emoji kartı.
- [ ] Günlük, kampanya kredisi/ilerlemesi/başarımından bağımsız.
- [ ] Analitik: `daily_start/complete/share` (Faz 3.1 sonrası).
