# CLAUDE.md — Manasal Solitaire çalışma rehberi

Bu dosya, bu depoda çalışan her Claude oturumu için **uyulması gereken
akışları** ve projenin haritasını içerir. Yeni bir işe başlamadan önce oku.

## Oyun nedir (değişmez kurallar)

Türkçe, bölüm bazlı **kelime-solitaire**. Kartlarda Türkçe kelimeler yazar;
sayı/renkle değil **anlamsal kategoriyle** eşleşir.

- **K7 (kutsal):** Renk HİÇBİR yerde kategori anlamı taşımaz. Kelime
  kartlarında kategori rengi/simgesi YOK. Tüm kategori kartları aynı kilim
  indigosudur. Eşleştirme okumayla yapılır.
- Tamamen **Türkçe** (UI + yorumlar + içerik). 150 bölüm, sınırlı hamle,
  geri-al/ipucu kredisi.
- Görsel dil: **Kilim** (çağdaş Anadolu) — `docs/spec.html` + tema token'ları.

## Doküman disiplini (ZORUNLU akış)

Dokümanlar tek doğruluk kaynağıdır; kodla senkron tutulur.

1. **Bir işe başlamadan önce OKU:** [`docs/roadmap.md`](docs/roadmap.md) + ilgili
   [`docs/features/*.md`](docs/features). Plan varsa ona uy; yoksa önce yaz.
2. **Uygularken/bitince GÜNCELLE:**
   - Roadmap durum etiketi: ⬜ planlı → 🔨 devam → ✅ bitti.
   - İlgili özellik dokümanındaki "Kabul kriterleri" / durum satırı.
3. **Her mağaza sürümünde:** [`docs/app-store-metadata.md`](docs/app-store-metadata.md)
   sürüm geçmişi tablosunu + değişen metadatayı güncelle. Bu bizim sürüm
   geçmişimizdir.
4. **Yeni büyük özellik:** `docs/features/` altına concrete plan + roadmap'e satır.
5. Doküman merkezi: [`docs/index.html`](docs/index.html) (indeks:
   [`docs/README.md`](docs/README.md)).

## Mimari haritası

```
lib/
  engine/      Saf Dart, immutable oyun motoru (GameState, rules, analysis, prng, serde)
  generator/   Bölüm üretimi (curve, level_generator, solver)
  content/     Kategori havuzu, yükleyici, doğrulayıcı, tr_text
  app/
    game/      Oyun ekranı, tahta (BoardMetrics), controller, widgets/ (cards, hud, dialogs)
    screens/   splash, home, levels, achievements, settings, how_to_play
    meta/      MetaService (ilerleme, cüzdan, başarım, ayar, resume) + MetaScope
    theme/     tokens (GameColors/Dim/Fonts), app_theme, kilim (desenler/logo/appbar)
    audio/     SoundService + koşullu backend (web/io)
    analytics/ Analytics cephesi + koşullu backend (stub/firebase)
  main.dart    Giriş: prefs → MetaService → Sound/Analytics init → ManasalApp
assets/        content/ (categories.json), levels/ (levels.json), fonts/, audio/
bin/           generate_levels.dart (bölüm üretimi CLI)
test/          engine/generator/content/app testleri
docs/          spec, plan, roadmap, features, app-store-metadata, licensing, site
```

## Komutlar

Flutter yolu: `export PATH="$HOME/flutter/bin:$PATH"` (sürüm sabit:
`scripts/flutter-version.txt` = 3.44.6).

```bash
flutter analyze                      # info-level lint = CI'da FATAL
dart format --set-exit-if-changed .  # CI biçim kapısı
flutter test                         # 70 test
dart run bin/generate_levels.dart    # 150 bölümü yeniden üret (içerik/eğri değişince)
flutter build web --release --no-web-resources-cdn   # yerel canvaskit, sıfır harici ağ
```

## CI kapıları (birleştirmeden önce hepsi geçmeli)

`.github/workflows/ci.yml`: `dart format --set-exit-if-changed .` · `flutter
analyze` · `flutter test` · `flutter build web`. **Yeni Dart yazınca dördünü de
yerelde çalıştır.** `flutter build web` firebase içermemeli (koşullu backend
sağlar) — kontrol et.

## Git & dağıtım akışı

- Geliştirme dalı: **`claude/word-solitaire-flutter-3ru19g`**. İşi buraya
  commit + push et.
- **`main` = default + dağıtım tetikleyici.** `main`'e push → `.github/workflows/
  deploy.yml` web'i derleyip `gh-pages`'e basar (canlı:
  https://b3vet.github.io/manasal-solitair/).
- Yayınlarken: dalı `main`'e **ff-merge** et, `main`'i push et; gh-pages
  otomatik. Dağıtımı `git ls-remote --heads origin gh-pages` sha değişimiyle
  doğrula.
- İzin olmadan doğrudan `main`'e itme (kullanıcı onayıyla dağıtım yapılır).

## Kodlama kuralları

- **Türkçe** yorum/metin; mevcut idiomlara uy.
- **Kilim token'ları:** renk/ölçü/font için `lib/app/theme/tokens.dart`
  (GameColors/Dim/Fonts) + `kilim.dart` (desenler, logo, `kilimAppBar`). Sabit
  renk/punto gömme.
- **Platforma özel kod = koşullu import** (`sound_backend`, `analytics_backend`
  deseni). Web derlemesini kirletme.
- Motor **immutable**; kurallar `rules.dart`, öneri/ipucu `analysis.dart`.
- İçerik: kelimeler **global benzersiz** (validator sert hata); kategori
  karışıklığı için `softConflict` (bkz.
  [content-ambiguity-protection](docs/features/content-ambiguity-protection.md)).

## Platform notları

- **Web:** kendine yeter (`--no-web-resources-cdn`, harici ağ yok); fontlar
  gömülü.
- **iOS/Android:** paketlenebilir; ikon (kilim), dikey-only, arka plan sesi
  `mixWithOthers` (Spotify'ı kesmez). Bundle id `com.manasal.manasalSolitaire`.
- **Analitik/Crashlytics:** yalnız mobilde + config dosyaları eklenince aktif;
  aksi halde no-op. Opt-out Ayarlar'da.

## Sırada ne var

Güncel öncelikler ve durum: **[docs/roadmap.md](docs/roadmap.md)**. Özetle
Faz 1 (öğretici, içerik belirsizlik koruması, yıldız hedefi) → Faz 2
(retention) → yayın.
