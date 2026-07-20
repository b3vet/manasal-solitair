/// Kilim görsel dili: dokunmuş desenler ve motifler (CustomPainter + widget).
///
/// Tekrar eden motifler:
///  - Crosshatch kart sırtı (dokuma dokusu + merkez elması),
///  - Altın kilim elması (kategori işareti, bölüm düğümü, yükleme noktası),
///  - Kilim bordürü (terrakotta+indigo blok bandı — alt kenar, modal üstü),
///  - Kesikli çerçeve (boş slot / boş sütun).
///
/// Renk hiçbir yerde kategori anlamı taşımaz; bu desenler yalnızca dokudur.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'tokens.dart';

// ─────────────────────────────────────────────────────────────────────────
// Kart sırtı — dokuma crosshatch + merkez elması.
// ─────────────────────────────────────────────────────────────────────────

/// Kilim dokuma deseni: 45° döndürülmüş dama (iki terrakotta tonu) + merkez
/// altın elması. Kapalı/gömülü kartların sırtında kullanılır.
class KilimCardBack extends StatelessWidget {
  const KilimCardBack({
    super.key,
    required this.size,
    required this.colors,
    this.radius = Dim.cardRadius,
  });

  final Size size;
  final GameColors colors;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CustomPaint(
          painter: _KilimBackPainter(
            base: colors.accentDeep,
            weave: colors.accent,
            gold: colors.gold,
            // Dokuma highlight/hâle her iki temada da açık krem kalır
            // (terrakotta zemin üstünde).
            cream: const Color(0xFFF7ECD8),
          ),
        ),
      ),
    );
  }
}

class _KilimBackPainter extends CustomPainter {
  _KilimBackPainter({
    required this.base,
    required this.weave,
    required this.gold,
    required this.cream,
  });

  final Color base;
  final Color weave;
  final Color gold;
  final Color cream;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = base);

    // 45° döndürülmüş dama: bir hücre grubu açık (weave) tonla dolar.
    // İnce dokuma için küçük hücre.
    final cell = size.shortestSide / 5.5;
    final cellPaint = Paint()..color = weave;
    canvas.save();
    canvas.clipRect(rect);
    final center = rect.center;
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi / 4);
    // Döndürülmüş alanı kaplayacak yeterli menzil.
    final reach = size.longestSide;
    for (double y = -reach; y < reach; y += cell) {
      for (double x = -reach; x < reach; x += cell) {
        final i = (x / cell).round();
        final j = (y / cell).round();
        if ((i + j) % 2 == 0) {
          canvas.drawRect(Rect.fromLTWH(x, y, cell, cell), cellPaint);
        }
      }
    }
    canvas.restore();

    // Merkez elması: krem hâle + altın elmas.
    final d = size.shortestSide * 0.30;
    _diamond(
      canvas,
      center,
      d * 1.32,
      Paint()..color = cream.withValues(alpha: 0.9),
    );
    _diamond(canvas, center, d, Paint()..color = gold);
    _diamond(
      canvas,
      center,
      d * 0.5,
      Paint()..color = cream.withValues(alpha: 0.55),
    );
  }

  void _diamond(Canvas canvas, Offset c, double diag, Paint p) {
    final r = diag / 2;
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..lineTo(c.dx + r, c.dy)
      ..lineTo(c.dx, c.dy + r)
      ..lineTo(c.dx - r, c.dy)
      ..close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_KilimBackPainter old) =>
      old.base != base || old.weave != weave || old.gold != gold;
}

// ─────────────────────────────────────────────────────────────────────────
// Altın kilim elması — kategori işareti / genel motif.
// ─────────────────────────────────────────────────────────────────────────

/// Altın elmas motifi (opsiyonel iç halka). Kategori kartı köşesinde, bölüm
/// düğümünde, yükleme göstergesinde kullanılır.
class KilimDiamond extends StatelessWidget {
  const KilimDiamond({
    super.key,
    required this.size,
    required this.color,
    this.filled = true,
    this.stroke,
  });

  final double size;
  final Color color;

  /// false → yalnızca dış hat (kilitli/pasif düğümler için).
  final bool filled;
  final Color? stroke;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _DiamondPainter(color: color, filled: filled, stroke: stroke),
    );
  }
}

class _DiamondPainter extends CustomPainter {
  _DiamondPainter({required this.color, required this.filled, this.stroke});

  final Color color;
  final bool filled;
  final Color? stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..lineTo(c.dx + r, c.dy)
      ..lineTo(c.dx, c.dy + r)
      ..lineTo(c.dx - r, c.dy)
      ..close();
    if (filled) {
      canvas.drawPath(path, Paint()..color = color);
      // İnce iç highlight — dokunmuş his.
      final ir = r * 0.46;
      final inner = Path()
        ..moveTo(c.dx, c.dy - ir)
        ..lineTo(c.dx + ir, c.dy)
        ..lineTo(c.dx, c.dy + ir)
        ..lineTo(c.dx - ir, c.dy)
        ..close();
      canvas.drawPath(
        inner,
        Paint()..color = (stroke ?? Colors.white).withValues(alpha: 0.22),
      );
    } else {
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.12
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(_DiamondPainter old) =>
      old.color != color || old.filled != filled || old.stroke != stroke;
}

// ─────────────────────────────────────────────────────────────────────────
// Kilim bordürü — terrakotta+indigo blok bandı.
// ─────────────────────────────────────────────────────────────────────────

/// Yatay kilim bandı: dönüşümlü terrakotta/indigo bloklar + ara altın elmaslar.
/// Splash/ana ekran alt kenarı, modal üst kenarı, banner üstü için.
class KilimBand extends StatelessWidget {
  const KilimBand({super.key, required this.colors, this.height = 12});

  final GameColors colors;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _KilimBandPainter(
          a: colors.accent,
          b: colors.categoryFace,
          gold: colors.gold,
        ),
      ),
    );
  }
}

class _KilimBandPainter extends CustomPainter {
  _KilimBandPainter({required this.a, required this.b, required this.gold});

  final Color a;
  final Color b;
  final Color gold;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.height; // kare bloklar
    final gap = unit * 0.34;
    final step = unit + gap;
    var i = 0;
    for (double x = 0; x < size.width; x += step) {
      final slot = i % 4;
      final w = math.min(unit, size.width - x);
      if (slot == 3) {
        // Altın elmas aksanı.
        final c = Offset(x + unit / 2, size.height / 2);
        final r = unit * 0.42;
        final path = Path()
          ..moveTo(c.dx, c.dy - r)
          ..lineTo(c.dx + r, c.dy)
          ..lineTo(c.dx, c.dy + r)
          ..lineTo(c.dx - r, c.dy)
          ..close();
        canvas.drawPath(path, Paint()..color = gold);
      } else {
        canvas.drawRect(
          Rect.fromLTWH(x, 0, w, size.height),
          Paint()..color = slot == 1 ? b : a,
        );
      }
      i++;
    }
  }

  @override
  bool shouldRepaint(_KilimBandPainter old) =>
      old.a != a || old.b != b || old.gold != gold;
}

// ─────────────────────────────────────────────────────────────────────────
// Kesikli çerçeve — boş slot / boş sütun.
// ─────────────────────────────────────────────────────────────────────────

/// Yuvarlatılmış köşeli kesikli kenarlık boyar (boş slot hedef çerçevesi).
class DashedRRectPainter extends CustomPainter {
  DashedRRectPainter({
    required this.color,
    this.radius = Dim.cardRadius,
    this.dash = 6,
    this.gap = 5,
    this.strokeWidth = 1.4,
  });

  final Color color;
  final double radius;
  final double dash;
  final double gap;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final next = math.min(dist + dash, metric.length);
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(DashedRRectPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.dash != dash ||
      old.gap != gap;
}
