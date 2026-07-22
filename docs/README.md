# Manasal Solitaire — Dokümanlar

Bu klasör projenin tasarım, plan, yol haritası ve operasyon dokümanlarını
tutar. Görsel doküman merkezi: [`index.html`](index.html).

## Yol haritası & uygulama planları

- **[roadmap.md](roadmap.md)** — Ana yol haritası (fazlar, öncelik, durum). Her
  şeyin girişi burası.

### Faz 1 — Spec eksikleri (1. öncelik)
- [features/interactive-tutorial.md](features/interactive-tutorial.md) — Etkileşimli öğretici
- [features/content-ambiguity-protection.md](features/content-ambiguity-protection.md) — İçerik belirsizlik koruması
- [features/star-goals.md](features/star-goals.md) — Yıldız hedefi

### Faz 3 — Yayın hazırlığı
- [features/analytics-crashlytics.md](features/analytics-crashlytics.md) — Firebase Analytics + Crashlytics
- [app-store-metadata.md](app-store-metadata.md) — Mağaza metadatası + **sürüm geçmişi** (yaşayan)
- [licensing.md](licensing.md) — Lisans kararı (onay bekliyor)
- [site/](site/) — Statik tanıtım + gizlilik sayfaları (ayrı repoda gh-pages)

## Mevcut tasarım dokümanları (HTML)

- [spec.html](spec.html) — Oyun spesifikasyonu v1.1 (tek doğruluk kaynağı)
- [plan/](plan/) — Faz 0–6 orijinal uygulama planları

## Kurallar

- **Roadmap** ilerledikçe durum etiketlerini (✅/🔨/⬜) güncelle.
- **app-store-metadata.md** her mağaza sürümünde güncellenir (sürüm geçmişimiz).
- Yeni büyük özellik → `features/` altına concrete plan + roadmap'e satır.
