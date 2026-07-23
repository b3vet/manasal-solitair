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

## Faz 1 — 1. Öncelik: Spec eksikleri ✅

Oyunun çekirdeği tamam; bunlar spec ruhunda kalan boşluklardı — üçü de bitti
(öğretici, belirsizlik koruması, yıldız hedefi). (Erişilebilirlik bilinçli
olarak kapsam dışı bırakıldı.)

### 1.1 Etkileşimli öğretici ✅ · efor: M–L
📄 [`docs/features/interactive-tutorial.md`](features/interactive-tutorial.md)

- **Ne:** İlk oyunda eli tutan, adım adım yönlendiren öğretici (statik "Nasıl
  Oynanır" yeterli değil).
- **Neden:** İlk-oyun terk oranı (onboarding drop-off) en büyük kullanıcı
  kaybıdır; kurallar okunarak değil yaparak öğrenilir.
- **Yapıldı:** Elle kurulmuş 4 adımlık öğretici bölüm (`tutorial_level.dart`) +
  `TutorialController`/`TutorialOverlay` (`tutorial.dart`: spot ışığı + nabız
  halkaları + parmak işareti + balon), yumuşak yönlendirme (motor değişmedi).
  Meta bayrağı `tutorialCompleted`; ilk "Oyna"da otomatik, Ayarlar'dan tekrar
  oynatılabilir. Ortak `PulseRing` ipucu ile paylaşılır. Testler:
  `test/app/tutorial_test.dart`.

### 1.2 İçerik belirsizlik koruması ✅ · efor: M + L (içerik)
📄 [`docs/features/content-ambiguity-protection.md`](features/content-ambiguity-protection.md)
· 📄 [denetim raporu](features/content-ambiguity-audit-report.md)

- **Ne:** Bir kelimenin iki kategoriye makul gelmesini (haksız yanılma)
  önlemek.
- **Neden:** "Okuyarak eşleştir" mekaniği ancak eldeki kategoriler birbirine
  karışmıyorsa adildir.
- **Yapıldı (kod):** İki katman — `hardConflicts` (özünde belirsiz; hiçbir
  bölümde birlikte gelmez) + `softConflicts` (yalnız yüksek seviyede). Üretici
  hard'ı DAİMA eler (`level_generator.dart`), doğrulayıcı simetrikleştirir +
  denetler, `bin/generate_levels.dart` hard çakışmada HATA verir + rapora yazar.
- **Yapıldı (içerik):** Paralel denetimle (8 öbek) çakışma kapsamı **32/640
  (%5) → 613/640 (%95)** (112 hard, 605 soft kategori). 150 bölüm yeniden
  üretildi; 0 hard çakışma. Testler: `test/content/content_test.dart`.

### 1.3 Yıldız hedefi ✅ · efor: S–M
📄 [`docs/features/star-goals.md`](features/star-goals.md)

- **Ne:** Yıldızları oyuncuya hedef olarak göstermek ("3 yıldız için ≤X
  hamle") ve tek doğruluk kaynağına almak.
- **Neden:** Yıldızlar şu an yalnızca Bölümler ekranında türetiliyor; oyuncu
  neyi hedefleyeceğini bilmiyor, tekrar oynama motivasyonu zayıf.
- **Yapıldı:** Ortak `starRating`/`movesForStars` (`lib/engine/scoring.dart`);
  oyun HUD'unda 3-yıldız hedef göstergesi (`≥N`); kazanma diyaloğunda kazanılan
  yıldızların sırayla parlama animasyonu + "sonraki yıldız" dürtüsü; Bölümler ve
  ana ekranda toplam yıldız. Testler: `test/engine/scoring_test.dart`; görsel:
  `test/app/faz1_capture_test.dart`. (4.2 kazanma yıldız animasyonu da kapsandı.)

---

## Faz 2 — 2. Öncelik: Retention & organik büyüme 🔨

Oyuncuyu geri getiren ve kendiliğinden yayan özellikler.

### 2.1 Günlük görev (daily puzzle) ✅ · efor: M
📄 [`docs/features/daily-puzzle.md`](features/daily-puzzle.md)

- **Ne:** Herkese aynı, güne özel tek bölüm + günlük seri (streak).
- **Neden:** Geri gelme sebebi #1; alışkanlık oluşturur.
- **Yapıldı:** `DailyService` (UTC tarih → deterministik tohum → çözülebilir
  bölüm, önbellekli; `lib/app/daily/`), meta `daily` dokümanı (streak/bestStreak/
  lastDayIndex/stars) + `recordDaily` seri mantığı, `GameScreen.daily` (kredi/
  ilerlemeden bağımsız), ana ekran günlük kartı + seri rozeti. Testler:
  `daily_test`, `daily_meta_test`.

### 2.2 Paylaşılabilir sonuç (Wordle etkisi) ✅ · efor: S–M
📄 [`docs/features/daily-puzzle.md`](features/daily-puzzle.md)

- **Ne:** "Bugünkü Manasal'ı 24 hamlede ⭐⭐⭐ bitirdim" emoji/metin kartı
  paylaşımı (spoiler'sız).
- **Neden:** Sıfır maliyetli organik büyüme döngüsü.
- **Yapıldı:** `daily_share.dart` (spoiler'sız yıldız+hamle+seri+link metni),
  `share_plus` (Web Share API / mobil sistem sayfası, panoya kopyala fallback),
  günlük kazanma diyaloğunda "Paylaş" butonu. (Analitik `share` olayı: Faz 3.1
  sonrası.)

### 2.3 İstatistik ekranı ✅ · efor: S–M
📄 [`docs/features/stats-screen.md`](features/stats-screen.md)

- **Ne:** Tamamlanan bölüm, toplam yıldız, kategori, verimli bölüm; günlük seri/
  en iyi seri/oynanan gün/3-yıldız; kredi.
- **Neden:** İlerleme hissi + oyuncunun kendini ölçmesi.
- **Yapıldı:** `StatsScreen` (Kilim, bölümlü ızgara) mevcut meta verisinden
  türetir (yeni kalıcı durum yok; yalnız 2 getter). Ana ekran "İstatistik"
  bağlantısı. Test: `stats_test` + görsel `stats`.
- **Not:** Kazanma oranı için oynanan/kazanılan sayacı ileride eklenebilir.

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

### 3.1 Analitik + Crash reporting 🔨 · efor: M — kod tarafı bitti, config bekliyor
📄 [`docs/features/analytics-crashlytics.md`](features/analytics-crashlytics.md)

- **Yapıldı:** `Analytics` cephesi + koşullu backend (web no-op / mobil
  Firebase), `main.dart` init, `analyticsEnabled` ayarı + opt-out anahtarı,
  `level_start/complete/fail` + `hint_used/undo_used` olayları. Web build
  firebase içermez; mobilde config eklenince aktifleşir.
- **Bekleyen (kullanıcı):** Firebase projesi + `GoogleService-Info.plist` /
  `google-services.json` + Gradle eklentisi (bkz. özellik dokümanı).

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

### 3.3 Lisans ✅ — FSL-1.1-MIT seçildi ve eklendi
📄 [`docs/licensing.md`](licensing.md)

- **Karar:** **Functional Source License 1.1 (MIT Future)** — rekabet-dışı her
  kullanıma serbest, 2 yıl sonra tam MIT'e döner.
- **Yapıldı:** kök `LICENSE` (FSL-1.1-MIT), `THIRD_PARTY_LICENSES.md` +
  `assets/fonts/{Lora,Manrope}-OFL.txt`.
- **Bekleyen (kullanıcı):** `LICENSE` içindeki `BURAYA_TELIF_SAHIBI` → gerçek
  ad/şirket.

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
- **4.2 Kazanma yıldız animasyonu** ✅ · S — diyalogda yıldızların sırayla
  parlaması (1.3 ile birlikte yapıldı; `dialogs.dart` `_Stars`).
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
