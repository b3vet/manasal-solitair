# Lisans Kararı

**Roadmap:** Faz 3.3 · **Durum:** ⬜ karar onayı bekliyor
**Uyarı:** Bu hukuki tavsiye değildir; ticari kısıtlama içeren lisanslarda bir
hukukçuya danışılması önerilir.

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

## Yapılacaklar (onay sonrası)

1. Lisansı seç (öneri: PolyForm Small Business 1.0.0). **Kullanıcı onayı gerekli.**
2. Kök `LICENSE` dosyasını ekle (seçilen lisansın resmi metni).
3. `NOTICE` / `THIRD_PARTY.md`: Lora + Manrope OFL atıfları.
4. `README`'ye lisans rozeti/kısa not; "source-available" ifadesi (open-source
   demeden, yanlış beyandan kaçın).
5. `pubspec.yaml` zaten `publish_to: none` (pub.dev'e yanlışlıkla yayınlanmaz).

## Karar

- [ ] Lisans onaylandı: **______________** (öneri: PolyForm Small Business 1.0.0)
- [ ] `LICENSE` + `NOTICE` eklendi.
