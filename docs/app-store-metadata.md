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

## 2. Mağaza listeleme metni (güncel: v1.0.0 — TASLAK, yayınlanmadı)

**Alt başlık (subtitle, ≤30 karakter):**
> Anlamı benzer kelimeleri topla

**Tanıtım metni (promotional text, ≤170):**
> Klondike solitaire'in Türkçe kelime hâli. Kartlar renkle değil, _anlamla_
> eşleşir — okur, düşünür, toplarsın.

**Açıklama (description):**
> Manasal Solitaire, solitaire'i kelimelerle yeniden yorumlar. Kartlarda Türkçe
> kelimeler yazar; onları sayı ya da renge göre değil, ait oldukları
> **kategoriye** göre toplarsın. Kartlarda kategori yazmaz — hangi kelimenin
> nereye ait olduğunu okuyup düşünerek bulursun.
>
> • 150 elle dengelenmiş bölüm, gitgide artan zorluk
> • 640+ kategori, 13.000+ kelime
> • Sınırlı hamle: her hamle önemli
> • Geri alma & ipucu kredileri, başarımlar
> • Tamamen Türkçe, sakin ve zarif "Kilim" tasarımı
> • Çevrimdışı oynanır; arka planda müziğin çalmaya devam eder

**Anahtar kelimeler (keywords, ≤100 karakter, virgülle):**
> kelime oyunu,bulmaca,solitaire,türkçe,kelime,zeka,pasyans,kategori,beyin,sözcük

**URL'ler:**
| Alan | Değer |
|---|---|
| Destek URL | _(gh-pages site)_ |
| Pazarlama URL | _(gh-pages `index.html`)_ |
| Gizlilik politikası URL | _(gh-pages `privacy.html`)_ · **App Store zorunlu** |
| Telif | © 2026 _(sahip adı)_ |

## 3. Görsel varlıklar (checklist)

- [ ] Uygulama ikonu 1024×1024 (hazır — kilim markası, opak).
- [ ] iPhone 6.7" ekran görüntüleri (≥3): ana ekran, oyun tahtası, bölümler
      patikası, kazanma. Kilim teması iyi durur.
- [ ] iPhone 6.5" ve 5.5" (gerekirse) + iPad.
- [ ] App Preview videosu (opsiyonel, tavsiye): 15–30 sn tatmin edici anlar.
- [ ] Google Play: feature graphic 1024×500, telefon ekran görüntüleri.

## 4. Gizlilik etiketleri (App Store / Play Data Safety)

Analitik (Faz 3.1) eklendiğinde doldur:
- Usage Data (analytics) — anonim, uygulama işlevi/analitik.
- Crash Data — Crashlytics.
- PII / konum / reklam kimliği: **yok** (hedef).

---

## 5. Sürüm geçmişi

> Her satır bir mağaza sürümü. "What's New" = mağazadaki kullanıcıya görünen TR
> metin. "Metadata değişikliği" = bu sürümde 1–4. bölümlerde değişen alanlar.

| Sürüm | Build | Tarih | Durum | What's New (TR, kullanıcıya) | Metadata değişikliği |
|---|---|---|---|---|---|
| 1.0.0 | 1 | — | 🔨 hazırlık | İlk sürüm: 150 bölüm, Kilim tasarımı, günlük olmayan klasik mod. | İlk listeleme (bölüm 2 alanları). |
| 1.0.0 | 4 | 2026-07 | ✅ web | iPad/tablet yönlendirme + tahta yerleşimi; Firebase analitik/Crashlytics (mobil). | yok |
| 1.1.0 | 5 | 2026-07 | ✅ web | Yeni: adım adım öğretici, yıldız hedefleri ve kazanma kutlaması, daha adil kategori eşleştirme. | yok |

<!--
Sonraki sürümler için şablon satırı:
| 1.2.0 | 6 | YYYY-AA-GG | ⬜ | <kullanıcıya görünen değişiklik özeti> | <değişen metadata alanları veya "yok"> |
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

---

## Bakım kuralı

1. Kod sürümünü `pubspec.yaml` `version:` alanında artır (`X.Y.Z+build`).
   Build numarası her mağaza yüklemesinde **benzersiz** olmalı.
2. Buraya yeni sürüm satırı ekle; "What's New" metnini yaz.
3. Metadata (açıklama/anahtar kelime/görsel) değiştiyse 2–3. bölümü güncelle ve
   satırın "Metadata değişikliği" hücresine yaz.
4. Değişiklikleri commit'le (bu doküman sürüm geçmişimizdir).
