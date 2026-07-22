/// Etkileşimli öğretici: adım betiği + ilerleme denetleyicisi + tahta bindirmesi.
///
/// Felsefe (yumuşak yönlendirme): motoru DEĞİŞTİRMEDEN, oyuncu doğru hamleyi
/// yapınca bir sonraki adıma geçilir. Denetleyici `GameController`'ı dinler;
/// adımın `advanceWhen` yordamı son olaylarda eşleşince ilerler. Bindirme
/// yalnızca görsel yönlendirmedir (spot ışığı + nabız halkaları + işaret + balon)
/// ve dokunmayı engellemez.
library;

import 'package:flutter/material.dart';

import '../../engine/engine.dart';
import '../theme/tokens.dart';
import 'board_metrics.dart';
import 'game_controller.dart';
import 'widgets/pulse_ring.dart';

// ---------------------------------------------------------------------------
// Çapa (anchor): tahtadaki bir konumun BoardMetrics ile Rect'e çözülen referansı.
// ---------------------------------------------------------------------------

sealed class TutorialAnchor {
  const TutorialAnchor();
}

/// Toplama slotu i.
class SlotAnchor extends TutorialAnchor {
  const SlotAnchor(this.index);
  final int index;
}

/// Sütun c'deki k'inci kart (alttan; kapalı+açık birlikte sayılır).
class ColumnCardAnchor extends TutorialAnchor {
  const ColumnCardAnchor(this.column, this.index);
  final int column;
  final int index;
}

/// Çekme destesi (üst kart).
class StockAnchor extends TutorialAnchor {
  const StockAnchor();
}

/// Atık yığını (en yeni açılan kart).
class WasteAnchor extends TutorialAnchor {
  const WasteAnchor();
}

Rect resolveAnchor(TutorialAnchor a, BoardMetrics m) => switch (a) {
  SlotAnchor(:final index) => m.slotTopLeft(index) & m.card,
  ColumnCardAnchor(:final column, :final index) =>
    m.cardTopLeft(column, index) & m.card,
  StockAnchor() => m.stockTopLeft() & m.card,
  WasteAnchor() => m.wasteTopLeft() & m.card,
};

// ---------------------------------------------------------------------------
// Adım betiği.
// ---------------------------------------------------------------------------

class TutorialStep {
  const TutorialStep({
    required this.text,
    required this.from,
    required this.advanceWhen,
    this.to,
  });

  /// Balon ipucu metni.
  final String text;

  /// Kaynak vurgu (nereye dokunulacak / neyi sürükleyecek).
  final TutorialAnchor from;

  /// Hedef vurgu (nereye bırakılacak). null → yalnız dokunma (çekme adımı).
  final TutorialAnchor? to;

  /// Hangi olay(lar) gelince bir sonraki adıma geçilir.
  final bool Function(List<GameEvent> events) advanceWhen;
}

bool _has<T extends GameEvent>(List<GameEvent> e) => e.any((x) => x is T);

/// tutorial_level.dart ile eşleşen 4 adımlık varsayılan betik.
List<TutorialStep> defaultTutorialSteps() => const [
  TutorialStep(
    text: 'Kategori kartını boş toplama alanına sürükle.',
    from: ColumnCardAnchor(0, 0), // Meyveler kartı
    to: SlotAnchor(0),
    advanceWhen: _has<SlotActivatedEvent>,
  ),
  TutorialStep(
    text: '"Elma" bir meyve. Kartı kategorinin üstüne sürükleyip topla.',
    from: ColumnCardAnchor(1, 0), // Elma
    to: SlotAnchor(0),
    advanceWhen: _has<WordsCollectedEvent>,
  ),
  TutorialStep(
    text: 'Sıradaki kartı görmek için desteye dokun.',
    from: StockAnchor(),
    advanceWhen: _has<DrewEvent>,
  ),
  TutorialStep(
    text: '"Kiraz"ı da topla — kategoriyi tamamla!',
    from: WasteAnchor(),
    to: SlotAnchor(0),
    advanceWhen: _has<CategoryCompletedEvent>,
  ),
];

// ---------------------------------------------------------------------------
// Denetleyici: GameController'ı dinler, adımları ilerletir.
// ---------------------------------------------------------------------------

class TutorialController extends ChangeNotifier {
  TutorialController({
    required this.game,
    required this.onComplete,
    List<TutorialStep>? steps,
  }) : steps = steps ?? defaultTutorialSteps() {
    game.addListener(_onGame);
  }

  final GameController game;
  final List<TutorialStep> steps;

  /// Tüm adımlar bitince (ya da geçilince) çağrılır.
  final VoidCallback onComplete;

  int _index = 0;
  bool _finished = false;

  int get index => _index;
  int get total => steps.length;
  bool get isActive => !_finished;
  TutorialStep? get current => _finished ? null : steps[_index];

  void _onGame() {
    if (_finished) return;
    if (steps[_index].advanceWhen(game.lastEvents)) {
      _index += 1;
      if (_index >= steps.length) {
        _finish();
      } else {
        notifyListeners();
      }
    }
  }

  /// Öğreticiyi atla (her an).
  void skip() {
    if (_finished) return;
    _finish();
  }

  void _finish() {
    _finished = true;
    notifyListeners();
    onComplete();
  }

  @override
  void dispose() {
    game.removeListener(_onGame);
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Bindirme (overlay): spot ışığı + nabız halkaları + işaret + balon.
// `Positioned.fill` içine konur; tahta koordinat uzayında çizer.
// ---------------------------------------------------------------------------

class TutorialOverlay extends StatelessWidget {
  const TutorialOverlay({
    super.key,
    required this.controller,
    required this.metrics,
    required this.colors,
    required this.pulse,
    this.reduceMotion = false,
  });

  final TutorialController controller;
  final BoardMetrics metrics;
  final GameColors colors;
  final Animation<double> pulse;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final step = controller.current;
    if (step == null) return const SizedBox.shrink();

    final fromRect = resolveAnchor(step.from, metrics);
    final toRect = step.to == null ? null : resolveAnchor(step.to!, metrics);
    final holes = <Rect>[fromRect, ?toRect];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Spot ışığı: tahtayı karart, vurgulanan alanları aç.
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _SpotlightPainter(
                holes: holes,
                scrim: colors.ink.withValues(alpha: 0.42),
                radius: Dim.cardRadius + 4,
              ),
            ),
          ),
        ),
        // Nabız halkaları.
        PulseRing(
          rect: fromRect,
          color: colors.gold,
          pulse: pulse,
          reduceMotion: reduceMotion,
        ),
        if (toRect != null)
          PulseRing(
            rect: toRect,
            color: colors.accent,
            pulse: pulse,
            reduceMotion: reduceMotion,
          ),
        // Kaynaktan hedefe kayan işaret (el).
        if (toRect != null)
          _Pointer(
            from: fromRect.center,
            to: toRect.center,
            pulse: pulse,
            reduceMotion: reduceMotion,
            colors: colors,
          ),
        // İpucu balonu — tahtanın altında ortalı.
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: _Bubble(
            text: step.text,
            index: controller.index,
            total: controller.total,
            colors: colors,
          ),
        ),
      ],
    );
  }
}

/// Yarı saydam koyu örtü; vurgulanan dikdörtgenleri "deler" (BlendMode.clear).
class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({
    required this.holes,
    required this.scrim,
    required this.radius,
  });
  final List<Rect> holes;
  final Color scrim;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final full = Offset.zero & size;
    canvas.saveLayer(full, Paint());
    canvas.drawRect(full, Paint()..color = scrim);
    final clear = Paint()..blendMode = BlendMode.clear;
    for (final h in holes) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(h.inflate(4), Radius.circular(radius)),
        clear,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) =>
      old.scrim != scrim || !_sameRects(old.holes, holes);

  static bool _sameRects(List<Rect> a, List<Rect> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Kaynaktan hedefe gidip gelen el işareti. Hareket azaltıldıysa orta noktada
/// sabit ok.
class _Pointer extends StatelessWidget {
  const _Pointer({
    required this.from,
    required this.to,
    required this.pulse,
    required this.reduceMotion,
    required this.colors,
  });
  final Offset from;
  final Offset to;
  final Animation<double> pulse;
  final bool reduceMotion;
  final GameColors colors;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        final t = reduceMotion ? 0.5 : Curves.easeInOut.transform(pulse.value);
        final p = Offset.lerp(from, to, t)!;
        return Positioned(
          left: p.dx - 14,
          top: p.dy - 8,
          child: IgnorePointer(
            child: Icon(
              Icons.touch_app_rounded,
              size: 34,
              color: colors.ink,
              shadows: [
                Shadow(color: colors.surface, blurRadius: 6),
                Shadow(color: colors.surface, blurRadius: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Adım metni balonu + adım sayacı noktaları.
class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.text,
    required this.index,
    required this.total,
    required this.colors,
  });
  final String text;
  final int index;
  final int total;
  final GameColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Dim.panelRadius),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: colors.accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.ink,
              fontFamily: Fonts.sans,
              fontSize: 15,
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < total; i++)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == index ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == index
                        ? colors.accent
                        : colors.inkSoft.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(Dim.pill),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
