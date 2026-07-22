# İçerik Belirsizlik Denetimi — Gerekçe Raporu

**Tarih:** 2026-07 · **Havuz sürümü:** categories.json v3 · İlgili özellik:
[`content-ambiguity-protection.md`](content-ambiguity-protection.md)

## Amaç ve yöntem

Oyunun çekirdek mekaniği "kelimeyi okuyup kategorisini düşün" (Spec K7). Bu
ancak eldeki kategoriler birbirine karışmıyorsa adildir. 640 kategorilik havuz,
paralel authoring ajanlarıyla (**8 öbek × 80 kategori**) denetlendi. Her ajan,
tam master listeye karşı geçerli id kullanarak şu iki ilişkiyi önerdi:

- **hardConflicts** — *özünde belirsiz*: gerçek bir kelime iki kategoriye de
  eşit gelir (ör. "Nar" hem meyve hem renk). Bu çiftler **hiçbir bölümde**
  birlikte gelmez. Tutucu ölçüt: şüphedeysen hard'a koyma.
- **softConflicts** — *anlamsal komşu*: karıştırılabilir ama ayırt edilebilir
  (ör. Meyveler ↔ Sebzeler). Yalnız yüksek seviyede (bilinçli zorluk) birlikte
  gelebilir.

Öneriler birleştirildi, çift yönlü simetrikleştirildi, hard∩soft örtüşmesi
hard lehine ayıklandı, kategori başına üst sınır uygulandı (hard ≤3, soft ≤6),
kalan yalnızca karşılıklı (simetrik) kenarlar tutuldu.

## Kapsam (öncesi → sonrası)

| Ölçüt | Önce | Sonra |
|---|---|---|
| Çakışma kenarı olan kategori | 32/640 (%5) | **613/640 (%95)** |
| Hard çakışma olan kategori | 0 | 112 (132 yönlü kenar, 66 benzersiz çift) |
| Soft çakışma olan kategori | 32 | 605 (1642 yönlü kenar) |

Üretilen 150 bölümde **0 hard çakışma**, adil aralıkta (allowSoftConflict=false)
**0 soft çakışma** (bkz. `build/levels_report.md` ve
`test/content/content_test.dart`).

## Öne çıkan bulgu: yinelenen kategoriler

Denetim, havuzda **birebir/yakın-yinelenen kategori adlarını** ortaya çıkardı
(farklı id, aynı tema). Bunlar hard olarak işaretlendi (kelime global-benzersiz
olduğundan bir kelime ikisine de eşit okunur), böylece asla yan yana gelmezler:

- Kaplumbağa türleri (×2), Salata çeşitleri (×2), Fasulye çeşitleri (×2), Soyu
  tükenmiş memeliler (×2), Denizler↔Okyanuslar, Coğrafi Şekiller↔Yer şekilleri,
  Efsanevi↔Mitolojik Yaratıklar, Duygu Durumları↔Duygular, Erdemler↔Karakter
  Erdemleri, Bankacılık ve Para↔Bankacılık terimleri…

_(İleride içerik temizliği için aday: bu yinelenen çiftler birleştirilebilir.)_

Ayrıca **jenerik ↔ alt tür** ilişkileri (Taşıtlar↔{Kara/Hava/Deniz Taşıtları},
Giysiler↔{Alt/Dış giyim}, Müzik Aletleri↔{Telli/Tuşlu çalgılar}, Ülkeler↔bölge
ülkeleri, Kaya türleri↔{Volkanik/Tortul/Metamorfik kayaçlar}) ve **çapraz alan
kelime çakışmaları** (Meyveler↔Renkler [Nar], Gök Cisimleri↔Roma Mitolojisi
[Venüs/Mars], Antik Yunan↔Roma Mitolojisi [Apollon], Kimyasal Elementler↔Metaller
[Demir/Bakır], Elma/Ceviz çeşitleri↔Şehirler [Amasya/Bilecik]) hard olarak
yakalandı.

## Tüm hard çakışma çiftleri (66)

- Ada ülkeleri ↔ Adalar ve takımadalar  (`ada_ulkeleri` ↔ `adalar_takimadalar`)
- Ada ülkeleri ↔ Ülkeler  (`ada_ulkeleri` ↔ `ulkeler`)
- Afrika ülkeleri ↔ Ülkeler  (`afrika_ulkeleri` ↔ `ulkeler`)
- Akvaryum balıkları ↔ Süs balıkları  (`akvaryum_baliklari` ↔ `sus_baliklari`)
- Alt giyim ↔ Giysiler  (`alt_giyim` ↔ `giysiler`)
- Antik Yunan Mitolojisi ↔ Roma Mitolojisi ve Tanrıları  (`antik_yunan_mitolojisi` ↔ `roma_mitolojisi`)
- Aperatif/atıştırmalık ↔ Atıştırmalıklar ve cips  (`aperatif` ↔ `atistirmaliklar_cips`)
- Asya ülkeleri ↔ Ülkeler  (`asya_ulkeleri` ↔ `ulkeler`)
- Baharatlar ↔ Kuru baharatlar  (`baharatlar` ↔ `kuru_baharatlar`)
- Baharatlı soslar ↔ Sos çeşitleri  (`baharatli_soslar` ↔ `sos_cesitleri`)
- Bankacılık ve Para ↔ Bankacılık terimleri  (`bankacilik_para` ↔ `bankacilik_terimleri`)
- Barbekü ve ızgara ↔ Izgara çeşitleri  (`barbeku_izgara` ↔ `izgara_cesitleri`)
- Ceviz çeşitleri ↔ Şehirler (Türkiye)  (`ceviz_cesitleri` ↔ `sehirler`)
- Çizim araçları ↔ Okul Eşyaları  (`cizim_araclari` ↔ `okul_esyalari`)
- Coğrafi Şekiller ↔ Yer şekilleri  (`cografi_sekiller` ↔ `yer_sekilleri`)
- Çorba çeşitleri ↔ Dünya çorbaları  (`corba_cesitleri` ↔ `dunya_corbalari`)
- Dağlar ↔ Türkiye dağları ve zirveleri  (`daglar` ↔ `turkiye_daglari_zirveleri`)
- Deniz sürüngenleri ↔ Kaplumbağa türleri  (`deniz_surungenleri` ↔ `kaplumbaga_turleri`)
- Deniz sürüngenleri ↔ Kaplumbağa türleri  (`deniz_surungenleri` ↔ `kaplumbaga_turleri_2`)
- Deniz Taşıtları ↔ Taşıtlar  (`deniz_tasitlari` ↔ `tasitlar`)
- Denizler ve Okyanuslar ↔ Okyanuslar ve denizler  (`denizler_okyanuslar` ↔ `okyanuslar_denizler`)
- Dış giyim ve paltolar ↔ Giysiler  (`dis_giyim_paltolar` ↔ `giysiler`)
- Doğa Olayları ve Afetler ↔ Doğal afet türleri  (`doga_olaylari_afetler` ↔ `dogal_afet_turleri`)
- Dünya Nehirleri ↔ Türkiye nehirleri  (`dunya_nehirleri` ↔ `turkiye_nehirleri`)
- Dünya Nehirleri ↔ Ünlü nehirler  (`dunya_nehirleri` ↔ `unlu_nehirler`)
- Duygu Durumları ↔ Duygular  (`duygu_durumlari` ↔ `duygular`)
- Edebî sanatlar ↔ Söz sanatları  (`edebi_sanatlar` ↔ `soz_sanatlari`)
- Efsanevi Yaratıklar ↔ Mitolojik Yaratıklar  (`efsanevi_yaratiklar` ↔ `mitolojik_yaratiklar`)
- Ege kıyı kasabaları ↔ İzmir ilçeleri  (`ege_kiyi_kasabalari` ↔ `izmir_ilceleri`)
- El sanatları ↔ Hobiler ve el sanatları  (`el_sanatlari` ↔ `hobiler_el_sanatlari`)
- Elma çeşitleri ↔ Şehirler (Türkiye)  (`elma_cesitleri` ↔ `sehirler`)
- Emlak ve tapu terimleri ↔ Gayrimenkul terimleri  (`emlak_tapu_terimleri` ↔ `gayrimenkul_terimleri`)
- Erdemler ↔ Karakter Erdemleri  (`erdemler` ↔ `karakter_erdemleri`)
- Fasulye çeşitleri ↔ Fasulye çeşitleri  (`fasulye_cesitleri` ↔ `fasulye_cesitleri_2`)
- Fosil canlılar ↔ Fosil türleri  (`fosil_canlilar` ↔ `fosil_turleri`)
- Giysiler ↔ Örgü ve triko ürünleri  (`giysiler` ↔ `orgu_triko`)
- Gök Cisimleri ↔ Roma Mitolojisi ve Tanrıları  (`gok_cisimleri` ↔ `roma_mitolojisi`)
- Güveç/fırın yemekleri ↔ Güveç yemekleri  (`guvec_firin` ↔ `guvec_yemekleri`)
- Hava Taşıtları ↔ Taşıtlar  (`hava_tasitlari` ↔ `tasitlar`)
- İçli ve dolma yemekler ↔ Köfte çeşitleri  (`icli_dolma` ↔ `kofte_cesitleri`)
- İguana benzeri kertenkeleler ↔ Kertenkele türleri  (`iguana_benzeri` ↔ `kertenkele_turleri`)
- Jeoloji dönemleri ↔ Tarih Öncesi Çağlar  (`jeoloji_donemleri` ↔ `tarih_oncesi_caglar`)
- Kahvaltı yemekleri ↔ Kahvaltı ürünleri  (`kahvalti` ↔ `kahvalti_urunleri`)
- Kanatlı avcılar ↔ Yırtıcı kuşlar  (`kanatli_avcilar` ↔ `yirtici_kuslar`)
- Kaplumbağa türleri ↔ Kaplumbağa türleri  (`kaplumbaga_turleri` ↔ `kaplumbaga_turleri_2`)
- Kara Taşıtları ↔ Taşıtlar  (`kara_tasitlari` ↔ `tasitlar`)
- Kart oyunları ↔ Masa ve Kart Oyunları  (`kart_oyunlari` ↔ `masa_kart_oyunlari`)
- Kaya türleri ↔ Metamorfik kayaçlar  (`kaya_turleri` ↔ `metamorfik_kayaclar`)
- Kaya türleri ↔ Tortul kayaçlar  (`kaya_turleri` ↔ `tortul_kayaclar`)
- Kaya türleri ↔ Volkanik kayaçlar  (`kaya_turleri` ↔ `volkanik_kayaclar`)
- Kıkırdaklı balıklar ↔ Köpekbalığı türleri  (`kikirdakli_baliklar` ↔ `kopekbaligi_turleri`)
- Kıkırdaklı balıklar ↔ Vatoz türleri  (`kikirdakli_baliklar` ↔ `vatoz_turleri`)
- Kimyasal Elementler ↔ Metaller ve Elementler  (`kimyasal_elementler` ↔ `metaller`)
- Masa ve Kart Oyunları ↔ Masa oyunları  (`masa_kart_oyunlari` ↔ `masa_oyunlari`)
- Meyveler ↔ Renkler  (`meyveler` ↔ `renkler`)
- Mutfak Eşyaları ↔ Yeme İçme Takımları  (`mutfak_esyalari` ↔ `yeme_icme_takimlari`)
- Müzik Aletleri ↔ Telli çalgılar  (`muzik_aletleri` ↔ `telli_calgilar`)
- Müzik Aletleri ↔ Türk halk çalgıları  (`muzik_aletleri` ↔ `turk_halk_calgilari`)
- Müzik Aletleri ↔ Tuşlu çalgılar  (`muzik_aletleri` ↔ `tuslu_calgilar`)
- Nazım biçimleri ↔ Şiir ve nazım türleri  (`nazim_bicimleri` ↔ `siir_nazim_turleri`)
- Peynir Çeşitleri ↔ Peynirli yiyecekler  (`peynir_cesitleri` ↔ `peynirli_yiyecekler`)
- Salata çeşitleri ↔ Salata çeşitleri  (`salata_cesitleri` ↔ `salata_cesitleri_2`)
- Şehirler (Türkiye) ↔ Türkiye gölleri  (`sehirler` ↔ `turkiye_golleri`)
- Sokak lezzetleri ↔ Sokak yemekleri  (`sokak_lezzetleri` ↔ `sokak_yemekleri`)
- Soyu tükenmiş memeliler ↔ Soyu tükenmiş memeliler  (`soyu_tukenmis_memeliler` ↔ `soyu_tukenmis_memeliler_2`)
- Yılan türleri ↔ Zehirli yılanlar  (`yilan_turleri` ↔ `zehirli_yilanlar`)
