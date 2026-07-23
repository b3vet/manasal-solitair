# Manasal Solitaire — Tanıtım + Gizlilik Sitesi

Statik, kendine yeten iki sayfa (gömülü CSS, harici bağımlılık yok, Kilim teması,
açık/koyu):

- `index.html` — tanıtım/landing.
- `privacy.html` — gizlilik politikası (App Store/Play için zorunlu URL).

## Yayınlama (ayrı bir gh-pages)

Bu dosyalar **ana uygulama deposundan ayrı** yayımlanmak üzere hazırdır. Adımlar:

1. Yeni/boş bir GitHub reposu oluştur (ör. `manasal-site`).
2. Bu klasördeki `index.html` ve `privacy.html` dosyalarını reponun **köküne**
   kopyala.
3. Repo ayarları → **Pages** → Source: `main` (veya `gh-pages`), klasör `/root`.
4. Yayınlanan URL'ler:
   - Tanıtım: `https://<kullanıcı>.github.io/<repo>/`
   - Gizlilik: `https://<kullanıcı>.github.io/<repo>/privacy.html`
5. Gizlilik URL'sini App Store Connect / Play Console'a ve
   `docs/app-store-metadata.md` içine yaz.

## Yayından önce yapılacaklar

- **Ekran görüntüleri:** `index.html` içindeki `.shot-note` bloğunu gerçek
  `<img>`'lerle değiştir (ana ekran, oyun tahtası, günlük bulmaca).
- **Mağaza linkleri:** yayınlanınca App Store/Play rozetlerini/linklerini ekle.
- İçerik güncel: sahip **Berke Üçvet**, iletişim **berkeucvet@gmail.com**,
  gizlilik son güncelleme **23 Temmuz 2026**.

> Not: Oynanabilir web sürümü ana repoda (`gh-pages`) —
> https://b3vet.github.io/manasal-solitair/ — tanıtımdaki "Tarayıcıda Oyna"
> butonu oraya bağlanır.
