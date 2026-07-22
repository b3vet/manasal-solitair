# Özellik Planı — Yıldız Hedefi

**Roadmap:** Faz 1.3 · **Öncelik:** 1 · **Efor:** S–M · **Durum:** ✅ bitti

## Amaç

Yıldızları oyuncuya **hedef** olarak göstermek ve tek doğruluk kaynağına almak.
Şu an yıldızlar yalnız Bölümler ekranında sessizce türetiliyor; oyuncu neyi
hedefleyeceğini bilmiyor, "3 yıldız için tekrar oyna" motivasyonu yok.

## Mevcut durum

- `lib/app/screens/levels_screen.dart` → `_starsFor(level, done)`:
  `ratio = bestMovesLeft / moveLimit`; `≥0.4 → 3`, `≥0.2 → 2`, aksi `1`.
- Kaynak veri: `meta.bestMovesLeft(levelId)` (progress dokümanı, `recordWin`'de
  güncellenir). **Yeni depolama gerekmez** — yıldız `bestMovesLeft` +
  `moveLimit`'ten türetilebilir.
- `dialogs.dart` `showWinDialog`: şu an **dekoratif** 3 yıldız (`_Stars` daima
  altın) gösteriyor; kazanılan yıldızı hesaplamıyor ve `moveLimit` almıyor.

## Plan

### 1) Tek doğruluk kaynağı (S)

Yeni saf yardımcı — `lib/engine/scoring.dart`:

```dart
/// Kalan hamle / limit oranından yıldız (1–3). Eşikler tuning verisidir.
int starRating(int movesLeft, int moveLimit) {
  if (moveLimit <= 0) return 1;
  final r = movesLeft / moveLimit;
  if (r >= 0.40) return 3;
  if (r >= 0.20) return 2;
  return 1;
}

/// 3 yıldız için gereken en az kalan hamle (hedef göstergesi için).
int movesForThreeStars(int moveLimit) => (moveLimit * 0.40).ceil();
int movesForTwoStars(int moveLimit) => (moveLimit * 0.20).ceil();
```

`levels_screen._starsFor`, kazanma diyaloğu ve hedef göstergesi hep bunu
kullanır. `test/engine/scoring_test.dart` ile kilitle.

### 2) Kazanma diyaloğunda kazanılan yıldız (S)

`showWinDialog`'a `moveLimit` parametresi ekle (çağrı yeri `game_screen.dart`
zaten `s.level.moveLimit`'e sahip). `_Stars`'ı kazanılan sayıya göre çiz:
dolu (altın) vs boş (dış hat), sırayla parlama animasyonu (reduce-motion'da
sabit). 3'ten azsa dürtü: **"3. yıldız için ≤X hamle"**.

### 3) Oyun sırasında hedef göstergesi (S–M)

Üst sayaç bölgesine (`game_board.dart` `_StatRow` yanı) küçük, göze batmayan
bir çip: sıradaki yıldız eşiği — ör. **"⭐⭐⭐ ≤14"** veya kalan hamle bu eşiğin
altına düşünce renk uyarısı. Alternatif: bölüm başında 1.2 sn beliren
"Hedef: 14 hamlede 3 yıldız" afişi. (Tasarım bunu göstermiyordu; hafif ekle,
Kilim stili.)

### 4) Toplam yıldız (S)

Ana ekran ve Bölümler başlığında toplam yıldız: **"142 / 450 ⭐"**. `meta`'ya
bölüm listesi alan bir yardımcı:

```dart
int totalStars(List<LevelDef> levels) => levels
    .where((l) => isCompleted(l.id))
    .fold(0, (s, l) => s + starRating(bestMovesLeft(l.id), l.moveLimit));
```

(Bölüm listesi gerektiği için `meta_service`'e `LevelDef` bağımlılığı sokmak
istemezsek yardımcıyı `lib/app/game/scoring_meta.dart` gibi ayrı tut.)

## Dosyalar

- `lib/engine/scoring.dart` (yeni) — `starRating`, eşik yardımcıları.
- `lib/app/game/widgets/dialogs.dart` — kazanma diyaloğu gerçek yıldız + dürtü;
  `moveLimit` parametresi.
- `lib/app/game/game_screen.dart` — `showWinDialog(..., moveLimit: s.level.moveLimit)`.
- `lib/app/screens/levels_screen.dart` — `_starsFor` yerine ortak `starRating`.
- `lib/app/game/game_board.dart` (veya `hud.dart`) — hedef çipi.
- `lib/app/screens/home_screen.dart` / `levels_screen.dart` — toplam yıldız.
- `test/engine/scoring_test.dart` (yeni).

## Kararlar

- **Depolama yok:** yıldız türetilir (`bestMovesLeft` + `moveLimit`). Göç
  (migration) gerektirmez; geri uyumlu.
- **Eşikler** (0.40 / 0.20) mevcut "Verimli" başarımıyla (%40 kalan) hizalı —
  tutarlı kalsın.
- **Hedef göstergesi hafif olmalı** — ipucu sızdırmaz (yalnız hamle eşiği,
  hangi hamle olduğu değil).

## Kabul kriterleri

- [x] Yıldız mantığı tek yerde (`lib/engine/scoring.dart`), testli
  (`test/engine/scoring_test.dart`).
- [x] Kazanma diyaloğu kazanılan yıldızı sırayla parlama animasyonuyla gösterir +
  "sonraki yıldız" dürtüsü (reduce-motion'da statik).
- [x] Oyun HUD'unda 3-yıldız eşiği görünür (`≥N`, ipucu sızdırmaz — yalnız sayı).
- [x] Ana ekran ve Bölümler toplam yıldızı gösterir.
- [x] Bölümler ekranı ortak `starRating`'i kullanır (kopya mantık yok).

Eşik: `movesLeft/moveLimit ≥ %40 → 3★, ≥ %20 → 2★, aksi → 1★` ("Verimli"
başarımıyla hizalı). Görsel doğrulama: `test/app/faz1_capture_test.dart`.
