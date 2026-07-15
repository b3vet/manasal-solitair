/// Tahta geometrisi: yığın ve kart konumları, isabet bölgeleri.
///
/// Tek kaynak: hem çizim hem sürükleme isabet testi buradan okur. Oyun
/// alanının (HUD altındaki) boyutuna ve sütun/kart sayılarına göre hesaplar.
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
    final pad = Dim.pagePad;
    final usableW = size.width - 2 * pad;
    final cardW =
        (usableW - Dim.gap * (columnCount - 1)) / columnCount;
    final cardH = cardW / Dim.cardAspect;
    card = Size(cardW, cardH);
    _pad = pad;

    foundationTop = pad;
    tableauTop = foundationTop + cardH + Dim.gap * 1.5;
    bottomTop = size.height - cardH - pad;
    final tableauH = bottomTop - tableauTop - Dim.gap;

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
  late final double foundationTop;
  late final double tableauTop;
  late final double bottomTop;
  late final double step;

  double _colX(int c) => _pad + c * (card.width + Dim.gap);

  Offset slotTopLeft(int i) => Offset(_colX(i), foundationTop);
  Offset columnTopLeft(int c) => Offset(_colX(c), tableauTop);
  Offset cardTopLeft(int c, int indexInColumn) =>
      Offset(_colX(c), tableauTop + indexInColumn * step);
  Offset stockTopLeft() => Offset(_colX(0), bottomTop);
  Offset wasteTopLeft() => Offset(_colX(1), bottomTop);

  Rect rectAt(Offset topLeft) =>
      topLeft & card;

  /// Bir sütunun tüm isabet bölgesi (drop hedefleme için).
  Rect columnHitRect(int c, int cardCount) {
    final top = tableauTop;
    final height = (cardCount <= 1 ? card.height : (cardCount - 1) * step + card.height)
        .clamp(card.height, bottomTop - tableauTop);
    return Rect.fromLTWH(_colX(c), top, card.width, height);
  }

  /// Bir bırakma noktasına en yakın slot (foundation bölgesindeyse).
  int? slotAt(Offset p) {
    if (p.dy > foundationTop + card.height + Dim.gap) return null;
    for (var i = 0; i < slotCount; i++) {
      final r = slotTopLeft(i) & card;
      if (_expand(r).contains(p)) return i;
    }
    return null;
  }

  /// Bir bırakma noktasına en yakın sütun (tableau bölgesinde).
  int? columnAt(Offset p) {
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
    // Yatay tolerans: yarım kart genişliği + boşluk.
    if (best < 0 || bestDist > card.width * 0.9) return null;
    return best;
  }

  Rect _expand(Rect r) => r.inflate(Dim.gap);
}
