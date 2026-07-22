# Lisans Kararı

**Roadmap:** Faz 3.3 · **Durum:** ✅ karar verildi — **FSL-1.1-MIT**
**Uyarı:** Bu hukuki tavsiye değildir; ticari kısıtlama içeren lisanslarda bir
hukukçuya danışılması önerilir.

> **KARAR:** Lisans **Functional Source License 1.1 (MIT Future License)**
> olarak seçildi. Kök [`LICENSE`](../LICENSE) eklendi; font atıfları
> [`THIRD_PARTY_LICENSES.md`](../THIRD_PARTY_LICENSES.md) + gömülü `*-OFL.txt`.
> Kalan tek iş: `LICENSE`'taki `BURAYA_TELIF_SAHIBI` → gerçek ad/şirket.
>
> **FSL neden:** Rekabetçi kullanım dışında her kullanıma (birey, eğitim,
> araştırma, iç kullanım) serbest; yayınlanmadan **2 yıl sonra tam MIT'e
> döner**. "Enterprise dışında herkese açık" hedefine uyar (rakip ürün/servis
> kısıtı) ve zamanla gerçek açık kaynağa dönerek topluluğa açılır.
> Metin: fsl.software (resmî kaynakla doğrula).

## İstenen model

> Bireyler ve küçük kullanıcılar serbestçe erişsin/kullanabilsin; **kurumsal
> (enterprise) kullanım kısıtlı olsun.**

## Önemli gerçek: bu, saf "OSI open-source" ile mümkün değil

OSI Açık Kaynak Tanımı, **kişi/gruplara (§5)** ve **kullanım alanına (§6)**
göre ayrımcılığı yasaklar. Yani MIT/Apache/GPL gibi _gerçek_ açık kaynak
lisansları "enterprise'ı kısıtla" diyemez. İstenen model **"kaynak-görünür /
fair-source"** kategorisidir (kod herkese açık, ama bazı kullanımlar kısıtlı).

## Seçenekler

| Lisans | Model | Enterprise kısıtı | OSI-open? |
|---|---|---|---|
| **PolyForm Small Business 1.0.0** ⭐ | Birey + küçük işletme (≈<100 kişi & <$1M gelir) serbest; büyükler ticari lisans alır | **Evet, net** | Hayır (fair-source) |
| Functional Source License (FSL) | Rekabet dışı her kullanım serbest; 2 yıl sonra Apache/MIT'e döner | Rekabeti kısıtlar | Hayır |
| Business Source License (BSL 1.1) | Üretim kullanımını kısıtlar; "change date"te açık olur | Ayarlanabilir | Hayır |
| Elastic License 2.0 | Yönetilen servis olarak sunmayı yasaklar | Kısmi | Hayır |
| Apache-2.0 / MIT | Herkese tam serbest (patent/atıf) | **Yok** | Evet |

## Öneri

**PolyForm Small Business License 1.0.0** — istenen "enterprise dışında herkese
açık" modeline en temiz uyan, hazır ve okunur metin. (polyformproject.org)

- Bireyler, öğrenciler, küçük işletmeler: serbest kullanım/değiştirme.
- Büyük şirketler: ayrı ticari lisans gerekir (senden).
- Not: Bu **OSI-open değil**; repoyu "open source" diye tanıtırsak teknik
  olarak yanlış olur — "source-available / fair-source" demeliyiz.

_Alternatif:_ gerçek açık kaynak isteniyorsa **Apache-2.0** (patent koruması +
atıf) — ama o zaman enterprise kısıtı olmaz.

## Üçüncü taraf atıfları (her durumda gerekli)

Gömülü fontlar **SIL Open Font License 1.1**:
- **Lora** (Cyreal) — OFL 1.1
- **Manrope** (Mikhail Sharanda) — OFL 1.1

Yapılacak: her fontun `OFL.txt`'ini `assets/fonts/` veya bir `THIRD_PARTY.md`/
`NOTICE` dosyasına ekle; OFL, gömülü kullanımı serbest bırakır ama lisans
metninin dağıtılmasını ister. (Uygulama içi "Lisanslar" ekranı ileride eklenebilir
— Flutter `showLicensePage` bunu otomatik toplar.)

## Yapılacaklar

1. ✅ Lisans seçildi: **FSL-1.1-MIT**.
2. ✅ Kök `LICENSE` eklendi (FSL-1.1-MIT resmi metni).
3. ✅ `THIRD_PARTY_LICENSES.md` + `assets/fonts/{Lora,Manrope}-OFL.txt` (font
   atıfları).
4. ⬜ `README`'de kısa lisans notu; "source-available / fair-source" ifadesi
   (open-source demeden — FSL, 2 yıl sonra MIT'e döner).
5. ✅ `pubspec.yaml` zaten `publish_to: none`.
6. ⬜ **Kullanıcı:** `LICENSE` içindeki `BURAYA_TELIF_SAHIBI` → gerçek ad/şirket.

## Karar

- [x] Lisans onaylandı: **FSL-1.1-MIT** (Functional Source License 1.1, MIT
  Future License). _(PolyForm Small Business değerlendirildi; FSL tercih edildi
  — 2 yılda MIT'e dönmesi + rekabet-dışı serbestlik.)_
- [x] `LICENSE` + `THIRD_PARTY_LICENSES.md` eklendi.
- [ ] Telif sahibi adı dolduruldu.
