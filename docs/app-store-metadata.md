# App Store / Play Metadata & Sürüm Geçmişi

> **Yaşayan doküman.** Mağaza alanlarının tek kaynağı + her sürümün "neler
> değişti" kaydı. **Kural: her yayında bu dokümanı güncelle** — buradaki
> "What's New" metni birebir mağazaya girer; metadata değişince ilgili alanı
> da güncelle.

---

## 1. Uygulama kimliği (sabit)

| Alan | Değer |
|---|---|
| Uygulama adı | Manasal Solitaire |
| Bundle ID (iOS) | `com.manasal.manasalSolitaire` |
| Package (Android) | `com.manasal.manasalSolitaire` (doğrula) |
| Birincil kategori | Games › Word (ikincil: Puzzle) |
| Yaş sınırı | 4+ |
| Birincil dil | Türkçe (tr) |
| Fiyat | Ücretsiz (para modeli kararı: Roadmap dışı — sonra) |

## 2. Mağaza listeleme metni (güncel: v1.3.1 — App Store Connect'e girildi 2026-11-10, incelemeye gönderilmedi)

**Ad:** Manasal Solitaire

**Alt başlık (subtitle, ≤30 karakter — 30):**
> Anlamı benzer kelimeleri topla

**Tanıtım metni (promotional text, ≤170 — 118):**
> Her gün yeni bir Günlük Bulmaca! Kartlar renkle değil, anlamla eşleşir: oku, düşün, kelimeleri doğru kategoride topla.

**Açıklama (description, ≤4000 — 1195):**
> Manasal Solitaire, solitaire'i kelimelerle yeniden yorumlar. Kartlarda Türkçe kelimeler yazar; onları sayıya ya da renge göre değil, ait oldukları kategoriye göre toplarsın. Kelime kartlarında kategori yazmaz: hangi kelimenin nereye ait olduğunu okuyup düşünerek bulursun.
>
> NASIL OYNANIR
> • Kategori kartını boş bir toplama alanına taşı.
> • O kategoriye ait kelimeleri üstüne sürükleyip topla.
> • Desteye dokunarak sıradaki kartı aç; hamlelerini akıllıca kullan.
> • İlk oyunda adım adım öğretici, kuralları sana oynatarak öğretir.
>
> NELER VAR
> • 150 elle dengelenmiş bölüm, gitgide artan zorluk
> • Günlük Bulmaca: her gün herkese aynı yeni bölüm, günlük seri ve spoiler'sız sonuç paylaşımı
> • Yıldız hedefleri: her bölümde 3 yıldız için kalan hamle hedefi
> • İstatistik ekranı: ilerleme, yıldızlar, günlük seri ve daha fazlası tek bakışta
> • 630 kategori, 13.000'den fazla Türkçe kelime
> • Adil eşleştirme: birbirine karışabilecek kategoriler aynı bölümde karşına çıkmaz
> • Geri alma ve ipucu kredileri, başarımlar
> • Sakin ve zarif "Kilim" tasarımı, açık ve koyu tema
> • İnternetsiz oynanır; oyunun sesi arka planda çalan müziğini kesmez
>
> Hesap gerekmez, reklam yoktur. İlerlemen yalnızca cihazında saklanır.

**Anahtar kelimeler (keywords, ≤100 — 92 karakter / 100 bayt):**
> kelime oyunu,bulmaca,türkçe,pasyans,kategori,zeka,günlük,kelime,beyin,sözcük,kart,eşleştirme

**URL'ler:**
| Alan | Değer |
|---|---|
| Destek URL | https://b3vet.github.io/manasal-solitair-site/ (repo: `b3vet/manasal-solitair-site`, kaynak `docs/site/`) |
| Pazarlama URL | https://b3vet.github.io/manasal-solitair-site/ |
| Gizlilik politikası URL | https://b3vet.github.io/manasal-solitair-site/privacy.html |
| Telif | 2026 Berke Üçvet (App Store "©" önekini kendisi ekler; LS listelemesiyle aynı biçim) |

**Diğer ASC alanları:** kategori Games › Word + Games › Puzzle (Oyunlar birincil kategorisinin iki alt
kategorisi); yaş 4+ (2025 anketi, tümü Yok/Hayır); fiyat Ücretsiz, IAP yok; erişilebilirlik 175 ülke;
içerik hakları "üçüncü taraf içerik kullanmıyor"; yayın seçeneği **elle yayınla** (Manually release).

**App Review notu (EN):**
```
No login or account is required. The app is entirely in Turkish.

How to play: tap "Oyna" (Play) on the home screen. On the first game a 4-step interactive tutorial starts: drag a category card (dark blue) to an empty slot, then drag the word cards that belong to that category onto it. Tap the deck (top-left) to draw the next card. Collect every category within the move limit to win; stars depend on moves left. "Günlük Bulmaca" on the home screen is the daily puzzle; "İstatistik" shows stats.

Data: the app uses only Firebase Analytics (gameplay events such as level start/complete, hint/undo use) and Firebase Crashlytics (crash reports). No ads, no in-app purchases, no tracking, no IDFA, no ATT prompt. Users can turn analytics and crash reporting off in Ayarlar (Settings) > "Kullanım verisi".
```

## 3. Görsel varlıklar (checklist)

- [x] Uygulama ikonu 1024×1024 (hazır — kilim markası, opak).
- [x] iPhone 6.9" (1320×2868, iPhone 17 Pro Max simülatörü) — 6 gerçek ekran:
      oyun, öğretici, günlük bulmaca, kazanma/yıldız, istatistik, ana ekran. ASC'ye yüklendi (v1.3.1).
- [x] iPad 13" (2064×2752, iPad Pro 13" M5 simülatörü) — aynı 6 ekran (uygulama iPad'i destekler:
      `TARGETED_DEVICE_FAMILY = 1,2`). ASC'ye yüklendi.
- [ ] App Preview videosu (opsiyonel, tavsiye): 15–30 sn tatmin edici anlar.
- [ ] Google Play: feature graphic 1024×500, telefon ekran görüntüleri.

## 4. Gizlilik etiketleri (App Store "App Privacy")

Koddan türetildi (2026-11-10, v1.3.1). Kanıt: `lib/app/analytics/` (Firebase yalnız mobilde,
koşullu import), `analytics_service.dart` olayları (`level_start/complete/fail`, `hint_used`,
`undo_used`), `setUserId` yok, `setUserProperty` çağrılmıyor; Crashlytics Flutter + platform
hatalarını kaydeder; `Ayarlar → Kullanım verisi` ikisini birden kapatır. Derlenen ipa'da
`AdSupport`/`AppTrackingTransparency` bağlı değil, `ASIdentifierManager` referansı yok; çalışma
anı log'u: "IDFA will not be accessible", "Analytics collection enabled".

| Veri türü | Amaç | Kullanıcıya bağlı | İzleme |
|---|---|---|---|
| Kullanım Verisi › Ürün Etkileşimi | Analitik | Hayır | Hayır |
| Tanılama › Çökme Verisi | Uygulama İşlevselliği, Analitik | Hayır | Hayır |
| Tanılama › Performans Verisi | Uygulama İşlevselliği, Analitik | Hayır | Hayır |
| Tanılama › Diğer Tanılama Verisi | Uygulama İşlevselliği, Analitik | Hayır | Hayır |
| Tanımlayıcılar › Cihaz Kimliği (uygulama-örneği kimliği / IDFV) | Analitik | Hayır | Hayır |
| Konum › Kaba Konum (IP'den türetilen ülke/bölge — Firebase) | Analitik | Hayır | Hayır |

IDFA yok → ATT gerekmez. Reklam yok. API App Privacy'yi desteklemediği için ASC web arayüzünden
girilir.

---

## 5. Sürüm geçmişi

> Her satır bir mağaza sürümü. "What's New" = mağazadaki kullanıcıya görünen TR
> metin. "Metadata değişikliği" = bu sürümde 1–4. bölümlerde değişen alanlar.

| Sürüm | Build | Tarih | Durum | What's New (TR, kullanıcıya) | Metadata değişikliği |
|---|---|---|---|---|---|
| 1.0.0 | 1 | — | 🔨 hazırlık | İlk sürüm: 150 bölüm, Kilim tasarımı, günlük olmayan klasik mod. | İlk listeleme (bölüm 2 alanları). |
| 1.0.0 | 4 | 2026-07 | ✅ web | iPad/tablet yönlendirme + tahta yerleşimi; Firebase analitik/Crashlytics (mobil). | yok |
| 1.1.0 | 5 | 2026-07 | ✅ web | Yeni: adım adım öğretici, yıldız hedefleri ve kazanma kutlaması, daha adil kategori eşleştirme. | yok |
| 1.2.0 | 6 | 2026-07 | ✅ web | Yeni: Günlük Bulmaca — her gün yeni bir bölüm, günlük seri (🔥) ve spoiler'sız sonuç paylaşımı. | yok |
| 1.3.0 | 7 | 2026-07 | ✅ web | Yeni: İstatistik ekranı — ilerleme, yıldız, günlük seri ve daha fazlası tek bakışta. | yok |
| 1.3.1 | 8 | 2026-07 | ✅ web | İçerik cilası: yinelenen kategoriler birleştirildi, bölümler yeniden dengelendi. | yok |
| 1.3.1 | 9 | 2026-11-10 | 🔨 App Store (ilk mağaza sürümü; build VALID, incelemeye gönderilmedi) | İlk App Store sürümü ("What's New" ilk sürümde gösterilmez). | Bölüm 2 + 3 + 4 baştan: 1.3.1 metni, URL'ler, ekran görüntüleri, gizlilik etiketi. |

<!--
Sonraki sürümler için şablon satırı:
| 1.4.0 | 9 | YYYY-AA-GG | ⬜ | <kullanıcıya görünen değişiklik özeti> | <değişen metadata alanları veya "yok"> |
-->

### Sürüm notları (dahili ayrıntı)

**1.0.0 (build 1) — hazırlık**
- Çekirdek oyun + Kilim yeniden tasarımı + iOS/Android paketleme hazır.
- Bekleyen yayın kapıları: gizlilik politikası URL, ekran görüntüleri, lisans,
  (opsiyonel) analitik.

**1.1.0 (build 5) — Faz 1 spec eksikleri**
- **Etkileşimli öğretici** (1.1): ilk oyunda 4 adımlı, yaparak öğreten anlatım;
  spot ışığı + nabız + parmak yönlendirmesi; Ayarlar'dan tekrar oynatılır.
- **Yıldız hedefi** (1.3): oyun-içi 3-yıldız eşiği, kazanma diyaloğunda yıldız
  animasyonu + dürtü, ana ekran/Bölümler toplam yıldız.
- **İçerik belirsizlik koruması** (1.2): iki katmanlı çakışma (hard/soft);
  üretici hard çakışan kategorileri hiçbir bölümde bir araya getirmez; 640
  kategorinin çakışma haritası denetimle dolduruldu; 150 bölüm yeniden üretildi.
- Firebase analitik/Crashlytics kodu (mobilde config ile aktif; web no-op).

**1.2.0 (build 6) — Faz 2: Günlük Bulmaca**
- **Günlük görev** (2.1): UTC tarihe göre deterministik günlük bölüm (herkese
  aynı), günlük seri (streak) + rekor, ana ekran giriş kartı.
- **Paylaşılabilir sonuç** (2.2): spoiler'sız emoji sonuç kartı (yıldız+hamle+
  seri+link); `share_plus` (web/mobil, panoya kopyala fallback).
- Günlük mod kampanya kredi/ilerlemesinden bağımsız; undo/ipucu yok (adil).

**1.3.0 (build 7) — Faz 2.3: İstatistik ekranı**
- Kampanya (bölüm/yıldız/kategori/verimli), günlük (seri/en iyi/oynanan/3-yıldız)
  ve cüzdan özetleri; mevcut meta verisinden türetilir (yeni durum yok).
- Ana ekran "İstatistik" bağlantısı.

**1.3.1 (build 8) — İçerik cilası: dedup**
- Denetimin bulduğu 10 yinelenen kategori çifti birleştirildi (categories.json
  v4, havuz 640 → 630); kelimeler tek kategoride toplandı, çakışma kenarları
  yönlendirildi. 150 bölüm yeniden üretildi (0 hard / adil aralıkta 0 soft).

**1.3.1 (build 9) — ilk App Store gönderimi hazırlığı (2026-11-10)**
- Kod değişikliği yok; build numarası 9 (ASC'deki en yüksek: 4). `ios/ExportOptions-appstore.plist`
  eklendi (imzalı arşiv, `manageAppVersionAndBuildNumber=false`).
- Destek/gizlilik sitesi ayrı repoda yayında; gizlilik metni koda göre düzeltildi ("anonim" yerine
  kimlikle ilişkilendirilmeyen; IDFV/uygulama-örneği kimliği, IP'den kaba konum, IDFA yok).
- ASC: metin, URL'ler, kategori, yaş 4+, fiyat, 175 ülke, inceleme notu, build 9, 6+6 ekran
  görüntüsü. Kalan: App Privacy (web arayüzü) + "Submit for Review" (Berke).

---

## Bakım kuralı

1. Kod sürümünü `pubspec.yaml` `version:` alanında artır (`X.Y.Z+build`).
   Build numarası her mağaza yüklemesinde **benzersiz** olmalı.
2. Buraya yeni sürüm satırı ekle; "What's New" metnini yaz.
3. Metadata (açıklama/anahtar kelime/görsel) değiştiyse 2–3. bölümü güncelle ve
   satırın "Metadata değişikliği" hücresine yaz.
4. Değişiklikleri commit'le (bu doküman sürüm geçmişimizdir).
