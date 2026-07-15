/// Uygulama teması (aydınlık + karanlık), kağıt/kitap yönü.
library;

import 'package:flutter/material.dart';

import 'tokens.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(Brightness.light, GameColors.light);
  static ThemeData dark() => _build(Brightness.dark, GameColors.dark);

  static ThemeData _build(Brightness brightness, GameColors g) {
    final base = ThemeData(
      brightness: brightness,
      useMaterial3: true,
      fontFamily: 'Roboto',
    );
    return base.copyWith(
      scaffoldBackgroundColor: g.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: g.accent,
        brightness: brightness,
      ).copyWith(surface: g.surface),
      extensions: [g],
      textTheme: base.textTheme.apply(
        bodyColor: g.ink,
        displayColor: g.ink,
        fontFamily: 'Roboto',
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: g.bg,
        foregroundColor: g.ink,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}

extension GameColorsX on BuildContext {
  GameColors get colors => Theme.of(this).extension<GameColors>()!;
}
