/// Tahta geometrisi: yığın ve kart konumları, isabet bölgeleri.
///
/// Tek kaynak: hem çizim hem sürükleme isabet testi buradan okur.
///
/// Yerleşim (yukarıdan aşağı):
///   1) Bilgi + deste satırı: deste + atık (sol) ve kalan hamle / kategori
///      sayaçları (sağ).
///   2) Toplama slotları (5). — sürükleme hedefleri en üstte.
///   3) Oyun alanı (tableau), ekranın altına kadar uzanır.
/// Menü/bölüm/geri al/ipucu kontrolleri tahtanın DIŞINDA (altta) durur.
library;

import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';

class BoardMetrics {
  BoardMetrics({
    required this.size,
    required this.columnCount,
    required this.slotCount,
    required List<int> columnCounts,
  }) {
    const pad = Dim.pagePad;
    final usableW = size.width - 2 * pad;
    final cardW = (usableW - Dim.gap * (columnCount - 1)) / columnCount;
    final cardH = cardW / Dim.cardAspect;
    card = Size(cardW, cardH);
    _pad = pad;

    infoTop = pad;
    foundationTop = infoTop + cardH + Dim.gap;
    tableauTop = foundationTop + cardH + Dim.gap * 1.5;
    final tableauBottom = size.height - pad;
    final tableauH = tableauBottom - tableauTop;

    final maxCount = columnCounts.isEmpty
        ? 1
        : columnCounts.reduce((a, b) => a > b ? a : b);
    final defaultStep = cardH * Dim.overlapFaceUp;
    if (maxCount > 1) {
      final avail = tableauH - cardH;
      final needed = (maxCount - 1) * defaultStep;
      step = needed > avail
          ? (avail / (maxCount - 1)).clamp(cardH * 0.11, defaultStep)
          : defaultStep;
    } else {
      step = defaultStep;
    }
  }

  final Size size;
  final int columnCount;
  final int slotCount;

  late final Size card;
  late final double _pad;
  late final double infoTop;
  late final double foundationTop;
  late final double tableauTop;
  late final double step;

  double _colX(int c) => _pad + c * (card.width + Dim.gap);

  /// Atık yelpazesinde gösterilecek en fazla kart (en yeni + 2 eski kenar).
  static const int wasteFanMax = 3;

  /// Arkadaki eski atık kartlarının görünen dikey şerit genişliği.
  double get wasteStripWidth => card.width * 0.22;

  // Deste: en üst satırın en solunda.
  Offset stockTopLeft() => Offset(_colX(0), infoTop);

  // En yeni (etkileşimli) atık kartı: solunda eski kartların kenarlarına yer
  // bırakmak için sabit biçimde sağa kaydırılmıştır.
  Offset wasteTopLeft() =>
      Offset(_colX(1) + (wasteFanMax - 1) * wasteStripWidth, infoTop);

  // Arkadaki eski atık kartının kenar konumu (back=1 en yeniye komşu).
  Offset wasteEdgeTopLeft(int back) =>
      Offset(wasteTopLeft().dx - back * wasteStripWidth, infoTop);

  // Sayaç bölgesi: atık yelpazesinin sağında kalan alan.
  Rect get statArea => Rect.fromLTRB(
    wasteTopLeft().dx + card.width + Dim.gap,
    infoTop,
    size.width - _pad,
    infoTop + card.height,
  );

  Offset slotTopLeft(int i) => Offset(_colX(i), foundationTop);
  Offset columnTopLeft(int c) => Offset(_colX(c), tableauTop);
  Offset cardTopLeft(int c, int indexInColumn) =>
      Offset(_colX(c), tableauTop + indexInColumn * step);

  /// Bir bırakma noktasına en yakın slot (toplama satırındaysa).
  int? slotAt(Offset p) {
    if (p.dy < foundationTop - Dim.gap ||
        p.dy > foundationTop + card.height + Dim.gap) {
      return null;
    }
    var best = -1;
    var bestDist = double.infinity;
    for (var i = 0; i < slotCount; i++) {
      final cx = _colX(i) + card.width / 2;
      final d = (p.dx - cx).abs();
      if (d < bestDist) {
        bestDist = d;
        best = i;
      }
    }
    if (best < 0 || bestDist > card.width * 0.9) return null;
    return best;
  }

  /// Bir bırakma noktasına en yakın sütun (oyun alanındaysa).
  int? columnAt(Offset p) {
    if (p.dy < tableauTop - card.height * 0.5) return null;
    var best = -1;
    var bestDist = double.infinity;
    for (var c = 0; c < columnCount; c++) {
      final cx = _colX(c) + card.width / 2;
      final d = (p.dx - cx).abs();
      if (d < bestDist) {
        bestDist = d;
        best = c;
      }
    }
    if (best < 0 || bestDist > card.width * 0.9) return null;
    return best;
  }
}
