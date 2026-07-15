# 🃏 Manasal Solitaire

Kelimelerle oynanan, Türkçe, bölüm tabanlı bir mobil solitaire oyunu. Kartlar sayıyla değil
**anlamla** eşleşir: oyuncu, kelime kartlarını ait oldukları kategorilere göre zincirler halinde
toplar ve kategori kartlarıyla birlikte toplama alanında eritir — üstelik **sınırlı hamle hakkıyla**.

Flutter ile geliştirilmiştir; önce web üzerinde test edilir, ardından Android/iOS paketlenir.

## 📱 Telefonda test et (en kolay yol)

`main` dalına her push sonrası oyun otomatik olarak GitHub Pages'e yayınlanır. Telefonunun
tarayıcısında aç, kurulum gerektirmez:

> **https://b3vet.github.io/manasal-solitair/**

### ⚠️ Tek seferlik kurulum (yalnızca ilk yayın için)

Dağıtım workflow'u, derlenen web'i `gh-pages` dalına yayınlar. Depo sahibinin bir kez şunu
seçmesi gerekir:

1. Depo → **Settings → Pages**
2. **Source: "Deploy from a branch"**
3. **Branch: `gh-pages`** · **Folder: `/ (root)`** → **Save**

(gh-pages dalı, `main`'e ilk push'ta workflow tarafından otomatik oluşturulur.) Bundan sonra her
`main` push'unda güncellenir. "Ana ekrana ekle" ile tam ekran PWA olarak da çalışır.

## 🎮 Nasıl oynanır (özet)

- Kelime kartını yalnızca **aynı kategoriden** bir kartın üzerine koyabilirsin — ama kartlarda
  kategori yazmaz, düşünerek bulman gerekir.
- Kategori kartını eşleşen zincirin üzerine veya boş sütuna koy; toplama slotuna çekince
  altındaki eşleşen kelimeler de birlikte toplanır.
- Bir kategorinin tüm kelimelerini topla → kategori biter. Destedeki tüm kategorileri bitir → kazan.
- Her hareket, kart sayısından bağımsız **1 hamle**. Hamlen bitmeden veya çıkmaza düşmeden çöz.
- Geri alma kredisiyle hataları geri sarabilirsin (başarımlarla kazanılır).

## 🗂️ Proje yapısı

```
lib/
├── engine/       Saf Dart oyun motoru (Flutter'dan bağımsız): kurallar, reducer,
│                 legal hamleler, çıkmaz tespiti, undo, serileştirme, PRNG
├── content/      İçerik havuzu modeli, JSON yükleyici, doğrulayıcı, Türkçe metin
├── generator/    Zorluk eğrisi, bölüm üreticisi, çözücü (makro-çekiş DFS)
├── persistence/  SharedPreferences tabanlı kalıcı belge deposu
└── app/          Flutter UI: tema, oyun ekranı (sürükle-bırak + animasyon),
                  meta oyun (ilerleme, cüzdan, başarımlar), ekranlar
assets/
├── content/categories.json   31 kategori, 718 Türkçe kelime
└── levels/levels.json        60 çözülebilirliği kanıtlı bölüm
bin/
├── validate_content.dart     İçerik doğrulama CLI
└── generate_levels.dart      Bölüm üretim hattı CLI
docs/                         Spesifikasyon (v1.1) + faz implementasyon planları
```

## 🛠️ Geliştirme

```bash
# Kurulum (sabit sürümlü Flutter'ı ~/flutter'a kurar)
bash scripts/setup.sh
export PATH="$HOME/flutter/bin:$PATH"

# Çalıştır (web)
flutter run -d chrome

# Testler + analiz
flutter test
flutter analyze

# İçerik doğrula / bölüm üret (dev araçları)
dart run bin/validate_content.dart
dart run bin/generate_levels.dart --count 60

# Web derlemesi (Pages ile aynı: yerel CanvasKit)
flutter build web --release --no-web-resources-cdn --base-href /manasal-solitair/
```

Motor tamamen saf Dart'tır; bir mimari test (`test/architecture_test.dart`) motora Flutter veya
`dart:math` sızmasını engeller. Bölümler determinist (sabit tohum) üretilir ve web/mobilde bit-bit
aynıdır (web-güvenli PRNG).

## 📚 Dokümantasyon

| Doküman | Durum |
|---|---|
| [Doküman Merkezi](docs/index.html) | — |
| [Oyun Spesifikasyonu v1.1](docs/spec.html) | Onaylandı |
| [Genel Plan + Faz 0–6 planları](docs/plan/genel-plan.html) | Uygulandı |

## ✅ Durum

Faz 0–6 tamamlandı: motor, içerik + üretici/çözücü, oyun ekranı, meta oyun, cila ve web dağıtımı.
Sırada (v1 sonrası): ses paketi, iOS/Android mağaza paketleme, rehberli öğretici, daha çok bölüm.
