# Manasal Solitaire — Yol Haritası

> Tek kayıt: nereye gidiyoruz, hangi sırayla, neden. Her madde bir cümlede _ne_,
> _neden_, _yaklaşım/dosyalar_ ve _efor_ (S/M/L) taşır. Ayrıntılı planı olan
> maddeler `docs/features/*.md` dosyalarına bağlanır.
>
> **Durum etiketleri:** ✅ bitti · 🔨 devam · ⬜ planlı
>
> **Öncelik:** Faz 1 (spec eksikleri) → Faz 2 (retention) → Faz 3 (yayın
> hazırlığı) → Faz 4 (his/cila) → Faz 5 (dağıtım & büyüme).

---

## Faz 0 — Bugünkü durum (tamamlandı) ✅

Kayıt için mevcut temel:

- **Motor** (`lib/engine/`): saf Dart, immutable `GameState`, kurallar
  (`rules.dart`), analiz/ipucu (`analysis.dart`), tam test kapsamı.
- **Üretim** (`lib/generator/`, `bin/generate_levels.dart`): deterministik
  bölüm üretimi + DFS çözücü; 150 bölüm `assets/levels/levels.json`.
- **İçerik** (`assets/content/categories.json`): 640 kategori, 13.102 kelime;
  global kelime benzersizliği doğrulanır.
- **Zorluk** (`lib/generator/curve.dart`): ilk 3 bölüm kolay, sonra hızlı
  merdiven; değişken sütun (4–6), merdiven kapalı-kart derinliği.
- **Görsel** (Kilim yönü): tema token'ları, Lora+Manrope, kilim desenleri,
  9 ekran + oyun tahtası + diyaloglar; açık/koyu tema seçici.
- **Platform**: web (gh-pages, yerel canvaskit, sıfır harici ağ), iOS/Android
  paketlenebilir (kilim ikonu, dikey-only, `mixWithOthers` arka plan sesi).
- **Meta** (`lib/app/meta/meta_service.dart`): ilerleme, cüzdan (geri-al
  kredisi), başarımlar, devam etme (resume), ayarlar.

---

## Faz 1 — 1. Öncelik: Spec eksikleri 🔨

Oyunun çekirdeği tamam; bunlar spec ruhunda kalan boşluklar. (Erişilebilirlik
bilinçli olarak kapsam dışı bırakıldı.)

### 1.1 Etkileşimli öğretici ⬜ · efor: M–L
📄 [`docs/features/interactive-tutorial.md`](features/interactive-tutorial.md)

- **Ne:** İlk oyunda eli tutan, adım adım yönlendiren öğretici (statik "Nasıl
  Oynanır" yeterli değil).
- **Neden:** İlk-oyun terk oranı (onboarding drop-off) en büyük kullanıcı
  kaybıdır; kurallar okunarak değil yaparak öğrenilir.
- **Yaklaşım:** Elle kurulmuş küçük öğretici bölüm(ler) + `TutorialOverlay`
  (nabız halkası + parmak + balon ipucu), yumuşak yönlendirme. Meta bayrağı
  `tutorialCompleted`.

### 1.2 İçerik belirsizlik koruması ⬜ · efor: M + L (içerik)
📄 [`docs/features/content-ambiguity-protection.md`](features/content-ambiguity-protection.md)

- **Ne:** Bir kelimenin iki kategoriye makul gelmesini (haksız yanılma)
  önlemek. Şu an 640 kategoriden yalnızca 32'sinde `softConflict` tanımlı.
- **Neden:** "Okuyarak eşleştir" mekaniği ancak eldeki kategoriler birbirine
  karışmıyorsa adildir.
- **Yaklaşım:** softConflict havuzunu genişlet (offline içerik geçişi) +
  üreticinin aynı elde çakışan kategori çifti seçmesini engelle
  (`lib/generator/level_generator.dart`); doğrulayıcıya sert kontrol ekle.

### 1.3 Yıldız hedefi ⬜ · efor: S–M
📄 [`docs/features/star-goals.md`](features/star-goals.md)

- **Ne:** Yıldızları oyuncuya hedef olarak göstermek ("3 yıldız için ≤X
  hamle") ve tek doğruluk kaynağına almak.
- **Neden:** Yıldızlar şu an yalnızca Bölümler ekranında türetiliyor; oyuncu
  neyi hedefleyeceğini bilmiyor, tekrar oynama motivasyonu zayıf.
- **Yaklaşım:** Ortak `starRating(movesLeft, moveLimit)` yardımcı fonksiyonu;
  oyun ekranında hedef göstergesi; kazanma diyaloğunda kazanılan yıldız
  animasyonu; ana ekranda toplam yıldız.

---

## Faz 2 — 2. Öncelik: Retention & organik büyüme ⬜

Oyuncuyu geri getiren ve kendiliğinden yayan özellikler.

### 2.1 Günlük görev (daily puzzle) ⬜ · efor: M
- **Ne:** Herkese aynı, güne özel tek bölüm + günlük seri (streak).
- **Neden:** Geri gelme sebebi #1; alışkanlık oluşturur.
- **Yaklaşım:** Deterministik günlük seed (tarih → PRNG; `lib/engine/prng.dart`
  zaten var), günlük bölümü çalışma anında üret veya önceden üret. Meta'ya
  `dailyStreak`, `lastDailyDate`. Ana ekrana giriş kartı.
- **Not:** Günlük seed için tarih gerekir; üretim tohumla deterministik
  kalmalı (kaydedilebilirlik/replay bozulmasın).

### 2.2 Paylaşılabilir sonuç (Wordle etkisi) ⬜ · efor: S–M
- **Ne:** "Bugünkü Manasal'ı 24 hamlede ⭐⭐⭐ bitirdim" emoji/metin kartı
  paylaşımı (spoiler'sız).
- **Neden:** Sıfır maliyetli organik büyüme döngüsü.
- **Yaklaşım:** `share_plus` paketi; sonucu emoji ızgarası + link olarak biçimle;
  kazanma diyaloğuna "Paylaş" butonu. Analitikte `share_tapped`.

### 2.3 İstatistik ekranı ⬜ · efor: S–M
- **Ne:** Kazanma oranı, ortalama hamle, en uzun seri, tamamlanan kategori,
  toplam yıldız.
- **Neden:** İlerleme hissi + oyuncunun kendini ölçmesi.
- **Yaklaşım:** Meta'da zaten var olan verilerden türet; gerekirse birkaç sayaç
  ekle (oynanan/kazanılan bölüm). Yeni `StatsScreen` (Kilim stili).

### 2.4 Oyun modları ⬜ · efor: M
- **Ne:** Rahat/sonsuz mod (hamle limitsiz, öğrenmek/dinlenmek için), zorlu mod.
- **Neden:** Farklı oyuncu profillerini tutar; baskı sevmeyenleri kaybetmezsin.
- **Yaklaşım:** `LevelDef.moveLimit` opsiyonel/serbest; motor limitsiz durumu
  zaten kaldırabilir (kontrol et). Mod seçimi ana ekran/bölüm başı.

---

## Faz 3 — Yayın hazırlığı ⬜

Halka açılmadan önce zorunlu kapılar + ölçüm altyapısı.
_(Not: Analitik teknik olarak burada ama öğretici etkisini ölçmek için erken —
Faz 1 ile paralel — devreye alınması önerilir.)_

### 3.1 Analitik + Crash reporting ⬜ · efor: M
📄 [`docs/features/analytics-crashlytics.md`](features/analytics-crashlytics.md)

- **Ne:** Firebase Analytics + Crashlytics.
- **Neden:** Hangi bölümde bırakıyorlar, hangi bölüm çok zor, D1/D7 retention —
  ölçemezsen geliştiremezsin. Çökmeleri görürsün.
- **Yaklaşım:** FlutterFire; `analytics_service.dart` sarmalayıcı; ayarlarda
  opt-out; gizlilik politikasında ifşa. **Firebase hesabı/anahtarı senden.**

### 3.2 Gizlilik politikası + tanıtım sitesi ⬜ · efor: S
📄 `docs/site/privacy.html`, `docs/site/index.html`

- **Ne:** App Store'un istediği gizlilik politikası URL'si + basit tanıtım
  sayfası.
- **Neden:** Politika olmadan App Store reddeder; tanıtım sayfası "arkadaşına
  link at" için en düşük sürtünme.
- **Yaklaşım:** Statik HTML (bu repoda `docs/site/`), ayrı boş repoda gh-pages.

### 3.3 Lisans ⬜ · efor: S (karar) — onay bekliyor
📄 [`docs/licensing.md`](licensing.md)

- **Ne:** Kaynak-görünür lisans; bireyler/küçük işletmeler serbest,
  kurumsal/enterprise kısıtlı. Öneri: **PolyForm Small Business 1.0.0**.
- **Neden:** İstenen "enterprise dışında herkese açık" modeli gerçek OSI
  open-source'la mümkün değil (ayrımcılık yasağı); fair-source gerekir.
- **Yaklaşım:** Karar onaylanınca `LICENSE` + `NOTICE` (Lora/Manrope OFL atıfı).

### 3.4 App Store metadata + sürüm geçmişi ⬜ · efor: S (yaşayan)
📄 [`docs/app-store-metadata.md`](app-store-metadata.md)

- **Ne:** Uygulama metadatası (açıklama, anahtar kelime, ekran görüntüleri, yaş)
  + her sürümde "neler değişti" ve metadata değişiklikleri.
- **Neden:** App Store/Play alanlarının tek kaynağı + sürüm geçmişi kaydı.
- **Yaklaşım:** Her yayında bu dokümanı güncelle; "What's New" metni birebir
  mağazaya girer.

### 3.5 Çoklu cihaz QA + CI sağlamlaştırma ⬜ · efor: M
- **Ne:** iPhone SE→Pro Max safe-area/çentik, koyu tema; CI'a golden test
  (redesign kilidi) + otomatik build-number artışı.
- **Neden:** Farklı ekranlarda kırılma; sürüm sürtünmesi.

---

## Faz 4 — His & cila (juice) ⬜

- **4.1 Kutlama/konfeti** ⬜ · S — kategori tamamlama ve kazanmada tasarımdaki
  konfeti/afiş (şu an `_CelebrationBanner` var, parçacık yok).
- **4.2 Kazanma yıldız animasyonu** ⬜ · S — diyalogda yıldızların sırayla
  parlaması (1.3 ile bağlantılı).
- **4.3 Ses/haptik ince ayar** ⬜ · S — kart yerleşme/çekme/tamamlama
  ritmini cihazda kalibre et.

---

## Faz 5 — Dağıtım & büyüme (en son) ⬜

- **5.1 Mağaza yayını** ⬜ · M — App Store (TestFlight→prod) + Google Play
  (Android hazır, test lazım) + Web'i **PWA** yap (yüklenebilir manifest).
- **5.2 Soft-launch** ⬜ · M — TestFlight public link ile sınırlı kitle,
  veriyle bölüm zorluğunu ayarla, sonra tam lansman.
- **5.3 ASO** ⬜ · S — Türkçe anahtar kelimeler, Kilim temalı ekran
  görüntüleri, önizleme videosu.
- **5.4 Video pazarlama** ⬜ · S — TikTok/Reels/Shorts tatmin edici anlar;
  Türk kelime-oyunu topluluğu.
- **5.5 Yerelleştirme (uzun vade)** ⬜ · L — motor dilden bağımsız; İngilizce
  içerik havuzuyla ayrı SKU (Türkçe kimliği bozmadan). Büyük pazar.

---

## Bağımlılıklar & sıra notları

- **Analitik (3.1)** öğretici (1.1) ve içerik (1.2) etkisini ölçmek için erken
  gelmeli — takvimde Faz 1 ile paralel tut.
- **Yıldız hedefi (1.3)** ↔ **kazanma yıldız animasyonu (4.2)** aynı çekirdeği
  paylaşır; 1.3 önce.
- **Günlük görev (2.1)** ↔ **paylaşılabilir sonuç (2.2)** birlikte en güçlü
  (paylaşımın çoğu günlükten gelir).
- **Gizlilik (3.2)** ↔ **analitik (3.1)**: politika, toplanan veriyi anlatmalı;
  analitik netleşince politika kesinleşir.
