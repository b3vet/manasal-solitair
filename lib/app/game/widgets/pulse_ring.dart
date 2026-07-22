/// Nabız atan vurgu halkası — ipucu ve öğreticinin ortak vurgu öğesi.
///
/// Belirli bir dikdörtgenin çevresine, verilen `pulse` animasyonuna göre
/// kalınlaşıp saydamlığı değişen bir çerçeve çizer. Tahta koordinat uzayında
/// bir `Stack` içine doğrudan düşer (Positioned döndürür). Hareket azaltıldıysa
/// sabit orta değerde durur.
library;

import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

class PulseRing extends StatelessWidget {
  const PulseRing({
    super.key,
    required this.rect,
    required this.color,
    required this.pulse,
    this.reduceMotion = false,
    this.inflate = 3,
    this.radius,
  });

  /// Vurgulanacak alan (tahta koordinatlarında).
  final Rect rect;
  final Color color;

  /// 0→1 arası ilerleyen nabız fazı (genelde reverse:true repeat).
  final Animation<double> pulse;
  final bool reduceMotion;
  final double inflate;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final r = rect.inflate(inflate);
    return Positioned(
      left: r.left,
      top: r.top,
      width: r.width,
      height: r.height,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: pulse,
          builder: (context, child) {
            final t = reduceMotion ? 0.5 : pulse.value;
            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  radius ?? Dim.cardRadius + 2,
                ),
                border: Border.all(
                  color: color.withValues(alpha: 0.45 + 0.55 * t),
                  width: 2.5 + 1.5 * t,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
