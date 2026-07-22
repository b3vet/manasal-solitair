# Özellik Planı — Etkileşimli Öğretici

**Roadmap:** Faz 1.1 · **Öncelik:** 1 · **Efor:** M–L · **Durum:** ⬜ planlı

## Amaç

İlk oyunda kuralları _okutmak_ yerine _yaptırarak_ öğretmek. Yeni oyuncuyu 4–5
adımda elinden tutarak bir bölümü kazandırmak; böylece "Nasıl Oynanır" ekranını
okumadan mekanikleri kavratmak. Hedef metrik: `tutorial_complete / install`
oranını yüksek tutmak, erken terk (drop-off) düşürmek.

## Kapsam

- Yalnızca **ilk kez** oynayan oyuncuya gösterilir (`meta.tutorialCompleted`).
- Ayarlar → "Öğreticiyi tekrar oynat" ile elle tetiklenebilir (opsiyonel).
- **Yumuşak yönlendirme**: oyuncu doğru hamleyi yapınca ilerler; yanlış denemede
  nazikçe tekrar yönlendirir (hard-lock yok — sadece ilk adımda hafif kısıtlama
  opsiyonu).

## Tasarım

### Öğretici bölüm(ler)i

Gerçek üretilmiş bölüm yerine **elle kurulmuş küçük, deterministik bir bölüm**
kullan (her adımın "doğru hamlesi" tek ve bariz olsun). Testlerdeki sentetik
bölüm deseniyle aynı (`test/app/stack_move_test.dart` → `LevelDef` elle kurma).

Örn. 3 sütun, 1–2 kategori, kısa kelimeler:

```dart
// lib/app/game/tutorial_level.dart
LevelDef tutorialLevel() => const LevelDef(
  id: 0, seed: 0, columnCount: 3, slotCount: 3, moveLimit: 999,
  categories: [ LevelCategory(categoryId: 'meyveler', name: 'Meyveler', totalWords: 2) ],
  columns: [ /* Kiraz | Nar | boş — obvious diziliş */ ],
  stock: [ CategoryCard(id:'c:meyveler', ...) ],
);
```

### Adım betiği (script)

```dart
// lib/app/game/tutorial.dart
class TutorialStep {
  final String text;              // balon ipucu: "Bu kartı buraya sürükle"
  final TutorialAnchor from;      // kaynak (kart/deste ref → BoardMetrics rect)
  final TutorialAnchor to;        // hedef (slot/sütun ref)
  final bool Function(List<GameEvent>) advanceWhen; // hangi olayda ilerle
  final bool gateInput;           // true → yalnız kaynak bölgesine dokunmaya izin
}
```

Önerilen adımlar:

1. **Kategori kartını slota koy** — desteden "Meyveler" kartını üst slota.
   `advanceWhen`: `SlotActivatedEvent`.
2. **Eşleşen kelimeyi topla** — "Kiraz"i slottaki kategorinin üstüne.
   `advanceWhen`: `WordsCollectedEvent`.
3. **Desteden kart çek** — kalan kelimeyi açığa çıkar. `advanceWhen`: `DrewEvent`.
4. **Son kelimeyi topla** → kategori tamamlanır, bölüm kazanılır.
   `advanceWhen`: `CategoryCompletedEvent` / `state.isWon`.

(Boş sütun & zincir kuralı öğreticide anlatılmaz; "Nasıl Oynanır"da kalır —
ilk deneyimi hafif tut.)

### `TutorialOverlay` widget'ı

`GameBoard`'un üstüne `Stack`'te bindirilir (GameScreen'de tutorial modundayken):

- **Spotlight**: tüm tahtayı hafif karart, yalnız aktif adımın kaynak+hedef
  dikdörtgenlerini aydınlık bırak (`CustomPainter` + `BlendMode.clear` delikli
  overlay).
- **Nabız halkaları**: kaynak ve hedefte — mevcut `game_board.dart`
  `_hintRing` stilini ortak bir `PulseRing` widget'ına çıkar, hem ipucu hem
  öğretici kullansın.
- **Parmak/işaret**: kaynaktan hedefe kayan bir el ikonu (reduce-motion'da
  sabit ok). `TweenAnimationBuilder`.
- **İpucu balonu**: adım metni (Lora başlık değil, Manrope gövde), Kilim yüzey
  kartı.
- **"Geç" butonu**: her an atlanabilir (üst köşe).

### Konum kaynağı

Overlay, dikdörtgenleri `BoardMetrics`'ten alır (mevcut API):
`slotTopLeft(i)`, `columnTopLeft(c)`, `cardTopLeft(c,k)`, `stockTopLeft()`,
`wasteTopLeft()` — hepsi zaten var. Ref → rect eşlemesi ipucu halkalarındaki
(`_hintRings`) mantıkla aynı.

### İlerleme mantığı

`GameController` zaten hamle sonrası `lastEvents` yayıyor ve `notifyListeners`
çağırıyor. Öğretici, controller'ı dinler; `advanceWhen(events)` doğruysa bir
sonraki adıma geçer. Böylece **yumuşak yönlendirme**: oyuncu doğru hamleyi
yapınca ilerler, motoru öğretici için değiştirmeye gerek yok.

## Veri modeli (meta)

`lib/app/meta/meta_service.dart` — `settings` dokümanına bayrak:

```dart
bool tutorialCompleted; // default false
// updateSettings({... , bool? tutorialCompleted})
// load: (settings?['tutorialCompleted'] as bool?) ?? false
```

## Entegrasyon noktaları

- `lib/app/game/game_screen.dart`: `initState`'te
  `if (!meta.tutorialCompleted) → tutorial modunda başla` (öğretici bölümüyle);
  son adımda `meta.updateSettings(tutorialCompleted: true)`.
- Ana ekran akışı: ilk "Oyna" → öğretici; bitince gerçek Bölüm 1.
- `lib/app/game/tutorial.dart` (yeni): script + overlay + controller.
- `lib/app/game/tutorial_level.dart` (yeni): elle kurulu bölüm.
- Ortak `PulseRing` widget'ı: `game_board.dart`'tan çıkar.

## Test

- `test/app/tutorial_test.dart`: öğreticiyi adım adım sür (startGesture →
  moveTo → up, mevcut `stack_move_test` deseni), her adımın ilerlediğini ve
  sonda `meta.tutorialCompleted == true` olduğunu doğrula.
- "Geç" butonunun bayrağı set edip oyuna geçtiğini doğrula.

## Riskler / kararlar

- **Hard-lock vs yumuşak yönlendirme:** Yumuşak öneriliyor (daha az sinir
  bozucu). İlk adımda `gateInput:true` ile yalnız kaynak karta dokunmaya izin
  vererek "ilk hamle şaşkınlığını" önle.
- **Reduce-motion:** parmak animasyonu sabit ok olur; nabız yavaşlar.
- **Öğretici bölüm gerçek ilerlemeye sayılmaz** (id:0, kredi/başarım yok).

## Kabul kriterleri

- [ ] İlk açılışta öğretici otomatik başlar, 4 adımda kazandırır.
- [ ] Her adım doğru hamlede ilerler; yanlış denemede tekrar yönlendirir.
- [ ] "Geç" her an çalışır.
- [ ] Bir daha gösterilmez (`tutorialCompleted`).
- [ ] Analitik: `tutorial_start/step/complete/skip` olayları (Faz 3.1 sonrası).
