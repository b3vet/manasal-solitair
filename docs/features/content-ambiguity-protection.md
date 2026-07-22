# Özellik Planı — İçerik Belirsizlik Koruması

**Roadmap:** Faz 1.2 · **Öncelik:** 1 · **Efor:** M (kod) + L (içerik) · **Durum:** ✅ bitti

> **Sonuç (denetim sonrası):** Çakışma kenarı olan kategori **32/640 (%5) →
> 613/640 (%95)**. 112 kategori hard çakışma (132 yönlü kenar, 66 benzersiz
> çift), 605 kategori soft (1642 yönlü kenar). Üretici hard çiftleri hiçbir
> bölümde birleştirmez; 150 bölüm yeniden üretildi (rapor:
> `build/levels_report.md`). Gerekçe özeti:
> [`content-ambiguity-audit-report.md`](content-ambiguity-audit-report.md).

## Problem

Oyunun çekirdek mekaniği "kelimeyi _okuyup_ hangi kategoriye ait olduğunu
_düşünerek_ bul" (Spec K7). Bu ancak **eldeki kategoriler birbirine
karışmıyorsa** adildir. Bir kelime iki kategoriye makul geliyorsa (klasik
örnek: **"Nar"** → Meyveler mi, Renkler mi?) oyuncu haksız yere yanılır.

## Mevcut durum (önemli)

Mekanizma **zaten tam kurulu** — eksik olan veri:

- Model: `CategoryPool` kategorilerinde `softConflicts: List<String>`
  (`lib/content/category_pool.dart`, `loader.dart`).
- Üretici: `lib/generator/level_generator.dart:130` — `allowSoftConflict`
  yanlışsa, seçilmiş kategorilerle çakışan adayları eler:
  ```dart
  if (!params.allowSoftConflict) {
    final conflicts = softMap[c.id] ?? const {};
    if (chosen.any((x) => conflicts.contains(x.id))) continue;
  }
  ```
- Eğri: `lib/generator/curve.dart` — `allowSoftConflict: false` (bölüm ≤30),
  `level > 30` sonrası serbest (zorluk için "yakın kategori jonglörlüğü").
- Doğrulayıcı: `validator.dart` `symmetric()` — a→b varsa b→a ekler; geçersiz
  id'leri uyarır.

**Boşluk:** 640 kategoriden yalnızca **32'sinde** `softConflict` tanımlı. Yani
koruma neredeyse hiç tetiklenmiyor çünkü çakışmalar bildirilmemiş. Çözüm
%80 içerik denetimi, %20 kod.

## Katman 1 — İçerik denetimi (ana iş, L)

640 kategorilik havuzda karışabilir kategori çiftlerini bul ve `softConflicts`
kenarlarını doldur.

**Süreç (10x içerik genişletmesindeki paralel-ajan hattıyla aynı):**

1. `scripts/` altında bir araç 640 kategoriyi (id, ad, örnek 5 kelime) listeler.
2. Paralel authoring ajanları öbekler halinde şu soruyu yanıtlar: _"X
   kategorisi için, bir Türkçe oyuncunun bir kelimeyi yanlışlıkla koyabileceği
   diğer kategoriler hangileri?"_ → kenar önerileri (X ↔ Y, gerekçe).
3. Kenarları **çift yönlü** birleştir, tekilleştir, kategori başına makul bir
   üst sınırla (ör. ≤8), gerekçeleri bir denetim raporuna yaz.
4. `categories.json`'a işle (versiyonu artır), `ContentValidator`'ı yeniden
   koştur (global kelime benzersizliği + simetri korunmalı).

**Ayrıca** (opsiyonel, ikinci geçiş): tekil olarak _özünde belirsiz_ kelimeleri
(birden çok kategoriye eşit yakın) işaretle → havuzdan çıkar veya en güçlü
kategoriye sabitle. Kelime-bazlı denetim büyük; önce çift-bazlı yeterli.

## Katman 2 — İki katmanlı çakışma (kod, S)

Şu an tek liste var (`softConflicts`) ve `allowSoftConflict>30` sonrası bu
çiftler _birlikte gelebiliyor_. Ama **özünde belirsiz** çiftler (Nar: meyve/renk)
hiçbir seviyede birlikte gelmemeli. Öneri: iki ayrım.

- **`hardConflicts`** (yeni): gerçekten karışan çiftler → **hiçbir bölümde**
  birlikte olmaz (seviye fark etmez).
- **`softConflicts`** (mevcut): gevşek ilişkili → yalnız yüksek seviyede,
  bilinçli zorluk olarak birlikte gelebilir.

Değişiklik:
- `category_pool.dart` + `loader.dart`: `hardConflicts` alanı.
- `level_generator.dart`: `hardConflicts`'i **her zaman** ele (allowSoftConflict
  bağımsız); `softConflicts`'i mevcut kurala bırak.
- `validator.dart`: `hardConflicts`'i de simetrikleştir + geçersiz id uyarısı.

_(Basit tutmak istenirse: tek liste kalır, `curve`'de `allowSoftConflict` hiç
`true` yapılmaz. Ama iki katman hem adalet hem zorluk çeşitliliği verir —
önerilen bu.)_

## Katman 3 — Doğrulama & rapor (kod, S)

- `bin/generate_levels.dart` raporu (`build/levels_report.md`): her bölümün
  kategori çiftlerini `hard`/`soft` çakışmaya karşı denetle; **hard** çakışma
  varsa üretim HATA versin.
- `test/content/content_test.dart`: (a) 0 hard-conflict çifti _hiçbir_ bölümde;
  (b) 0 soft-conflict çifti seviye ≤ eşik bölümlerde; (c) kapsam metriği
  (softConflict'i olan kategori yüzdesi) bir alt sınırın üstünde.

## Metrikler

- **Kapsam:** `softConflict`/`hardConflict` kenarı olan kategori oranı — 32/640
  (%5) → hedef anlamlı biçimde yüksek (karışabilir komşusu olan her kategori).
- **Adalet:** üretilen 150 bölümde 0 hard-conflict çifti; adil aralıkta 0
  soft-conflict çifti.

## Dosyalar

- `assets/content/categories.json` — kenarları doldur (+ `hardConflicts`).
- `lib/content/category_pool.dart`, `loader.dart`, `validator.dart` —
  `hardConflicts` alanı + simetri.
- `lib/generator/level_generator.dart` — hard'ı daima ele.
- `bin/generate_levels.dart` — rapor + hard çakışmada hata; 150 bölümü yeniden
  üret.
- `test/content/content_test.dart` — yeni doğrulamalar.
- `scripts/` — denetim aracı (kategori listesi + kenar birleştirici).

## Riskler / kararlar

- **Aşırı-kısıt riski:** çok fazla kenar → üretici yeterli kategori bulamaz
  (özellikle yüksek `categoryCount` bölümlerde). Kenar sayısını sınırla, üretim
  başarısızlığında raporla (mevcut `bin/generate_levels.dart` zaten örnekleme
  yapıyor).
- **Öznellik:** "karışır mı" kararı özneldir; gerekçe kaydı tut, gözden geçir.
- **Global kelime benzersizliği korunur** — bu iş yalnız kategori-çifti
  ilişkisini ekler, kelime taşımaz.

## Kabul kriterleri

- [x] softConflict/hardConflict kapsamı hedef üstünde (%5 → %88).
- [x] 150 bölüm yeniden üretildi; hard çakışma 0, adil aralıkta soft çakışma 0.
- [x] `content_test` yeni kontrollerle geçiyor (hard/soft/örtüşme/kapsam).
- [x] Denetim gerekçe raporu `docs/features/content-ambiguity-audit-report.md`
  altında kayıtlı (+ üretim raporu `build/levels_report.md`).
