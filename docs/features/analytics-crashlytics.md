# Özellik Planı — Analitik + Crash Reporting (Firebase)

**Roadmap:** Faz 3.1 · **Öncelik:** yayın hazırlığı (Faz 1 ile paralel önerilir)
· **Efor:** M · **Durum:** ⬜ planlı — **Firebase hesabı/anahtarı kullanıcıdan**

## Amaç

Neyi geliştireceğimizi _görmek_: hangi bölümde bırakıyorlar, hangi bölüm çok
zor, D1/D7 retention, öğretici tamamlama oranı; ve çökmeleri (crash) yakalamak.
Ölçüm olmadan büyüme körlemesine olur.

## Stack

- **Firebase Analytics** — olay/funnel/retention (iOS + Android + Web).
- **Firebase Crashlytics** — çökme raporu (iOS + Android; **web desteklemez** →
  web'de atlanır).
- Ücretsiz, Flutter'da standart (FlutterFire).

## Kurulum adımları

1. Firebase konsolunda proje oluştur; iOS + Android (+ Web) uygulaması ekle.
2. `dart pub global activate flutterfire_cli` → `flutterfire configure`
   (bundle id `com.manasal.manasalSolitaire`). Üretir:
   `lib/firebase_options.dart`, `ios/Runner/GoogleService-Info.plist`,
   `android/app/google-services.json`.
3. Bağımlılıklar: `firebase_core`, `firebase_analytics`, `firebase_crashlytics`.
4. Android: `google-services` Gradle eklentisi (`android/settings.gradle` +
   `android/app/build.gradle`).
5. iOS: `GoogleService-Info.plist` Runner hedefine ekli (flutterfire ekler).
6. `main.dart`:
   ```dart
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   if (!kIsWeb) {
     FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
     PlatformDispatcher.instance.onError = (e, s) {
       FirebaseCrashlytics.instance.recordError(e, s, fatal: true);
       return true;
     };
   }
   ```
   (Zone hataları için `runZonedGuarded` de sarılabilir.)

## Sarmalayıcı (tek çağrı noktası)

`lib/app/analytics/analytics_service.dart` — kapalıyken/desteklenmezken no-op:

```dart
class Analytics {
  static final instance = Analytics._();
  bool enabled = true; // meta.analyticsEnabled'dan beslenir

  Future<void> log(String name, [Map<String, Object>? params]) async {
    if (!enabled) return;
    await FirebaseAnalytics.instance.logEvent(name: name, parameters: params);
  }
  Future<void> setProp(String k, String v) { ... }
  // Crashlytics: özel anahtar (mevcut bölüm/durum) bağlamı
}
```

Tüm oyun/meta kodu yalnız bu sınıfı çağırır (Firebase'e doğrudan bağlanma).

## İzlenecek olaylar (concrete)

| Olay | Parametreler | Amaç |
|---|---|---|
| `level_start` | level, mode | funnel girişi |
| `level_complete` | level, moves_used, stars, first_try | ilerleme/zorluk |
| `level_fail` | level, reason (out_of_moves/deadlock) | zorluk zirveleri |
| `hint_used` / `undo_used` | level | takılma noktaları |
| `tutorial_start/step/complete/skip` | step | onboarding funnel |
| `daily_played` | date, stars | retention (Faz 2.1) |
| `share_tapped` | source | organik büyüme (Faz 2.2) |
| `theme_changed` | mode | ayar kullanımı |

**Kullanıcı özellikleri:** `highest_level`, `total_categories`, `total_stars`.
**Funnel:** install → tutorial_complete → level_3 → level_10.
**Zorluk paneli:** bölüm başına `fail/complete` oranı → zirveleri düzelt.

## Gizlilik & rıza

- **Opt-out:** `meta.analyticsEnabled` (Ayarlar'da anahtar). Kapalıysa hiç
  gönderme (`Analytics.enabled=false`, `setAnalyticsCollectionEnabled(false)`).
- **PII yok:** kimlik/konum toplama; yalnız anonim kullanım + cihaz türü.
- **İfşa:** `docs/site/privacy.html` toplanan veriyi anlatmalı; App Store/Play
  "gizlilik etiketleri" (nutrition labels) doldurulmalı (Usage Data, Crash Data).
- **KVKK/COPPA (4+):** çocuk kitlesi olasılığı → reklam kimliği kullanma,
  varsayılanı konservatif tut. (Gerekirse ilk açılışta rıza sorusu.)

## Dosyalar

- `lib/main.dart` — Firebase init + Crashlytics kancaları.
- `lib/firebase_options.dart` — flutterfire üretir.
- `lib/app/analytics/analytics_service.dart` (yeni) — sarmalayıcı.
- `lib/app/meta/meta_service.dart` — `analyticsEnabled` ayarı.
- `lib/app/screens/settings_screen.dart` — analitik anahtarı.
- Olay çağrıları: `game_screen.dart`, `game_controller.dart`, `tutorial.dart`,
  `dialogs.dart` (paylaşım), `home_screen.dart` (günlük).

## Sırlar / commit notu

- `google-services.json` ve `GoogleService-Info.plist` **istemci yapılandırması**
  (gerçek sır değil); commit'lemek yaygın ve kabul edilebilir. İstenirse
  `.gitignore`'a alınıp CI/secret ile enjekte edilebilir.
- `firebase_options.dart` içindeki API anahtarları istemci taraflıdır; Firebase
  güvenlik kuralları/kotayla korunur.

## Kabul kriterleri

- [ ] Uygulama iOS/Android'de Firebase'e bağlanır; web'de Crashlytics atlanır.
- [ ] Yukarıdaki olaylar Firebase konsolunda görünür.
- [ ] Ayarlardaki opt-out gerçekten toplamayı durdurur.
- [ ] Gizlilik politikası toplanan veriyle bire bir uyumlu.
- [ ] Crashlytics test çökmesi (`FirebaseCrashlytics.instance.crash()`) konsolda.
