/// Açılış ekranı (Kilim yönü): kısa marka anı — logo, başlık, yükleme.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../meta/meta_scope.dart';
import '../theme/app_theme.dart';
import '../theme/kilim.dart';
import '../theme/tokens.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dots;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _dots = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    )..repeat();
    _timer = Timer(const Duration(milliseconds: 1500), _goHome);
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, _, _) => const HomeScreen(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dots.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reduce = MetaScope.read(context).reducedMotion == 'off';
    return Scaffold(
      backgroundColor: colors.bg,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: KilimBand(colors: colors, height: 12),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                KilimLogo(width: 104, colors: colors),
                const SizedBox(height: 26),
                Text(
                  'Manasal\nSolitaire',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.ink,
                    fontFamily: Fonts.serif,
                    fontSize: 44,
                    height: 1.02,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Anlamı benzer kelimeleri topla',
                  style: TextStyle(color: colors.inkSoft, fontSize: 15),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 60,
            child: Column(
              children: [
                _dotsRow(colors, reduce),
                const SizedBox(height: 12),
                Text(
                  'YÜKLENİYOR',
                  style: TextStyle(
                    color: colors.inkSoft,
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dotsRow(GameColors colors, bool reduce) {
    if (reduce) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: KilimDiamond(size: 10, color: colors.accent),
            ),
        ],
      );
    }
    return AnimatedBuilder(
      animation: _dots,
      builder: (context, _) {
        final active = (_dots.value * 3).floor() % 3;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: KilimDiamond(
                  size: 10,
                  color: i == active
                      ? colors.accent
                      : colors.inkSoft.withValues(alpha: 0.4),
                ),
              ),
          ],
        );
      },
    );
  }
}
