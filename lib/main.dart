import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/audio/sound_service.dart';
import 'app/meta/meta_scope.dart';
import 'app/meta/meta_service.dart';
import 'app/screens/splash_screen.dart';
import 'app/theme/app_theme.dart';
import 'persistence/store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Telefonlarda yalnızca dikey; tabletlerde (iPad) tüm yönler serbest.
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final shortestSide =
      (view.physicalSize / view.devicePixelRatio).shortestSide;
  final isTablet = shortestSide >= 600;
  await SystemChrome.setPreferredOrientations(
    isTablet
        ? const [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]
        : const [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ],
  );
  final prefs = await SharedPreferences.getInstance();
  final meta = MetaService.load(Store(prefs));
  SoundService.instance.enabled = meta.sound;
  unawaited(SoundService.instance.load());
  runApp(ManasalApp(meta: meta));
}

class ManasalApp extends StatelessWidget {
  const ManasalApp({super.key, required this.meta});
  final MetaService meta;

  @override
  Widget build(BuildContext context) {
    return MetaScope(
      service: meta,
      // Tema seçimi (ayarlar) değişince yeniden çiz.
      child: AnimatedBuilder(
        animation: meta,
        builder: (context, _) => MaterialApp(
          title: 'Manasal Solitaire',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: switch (meta.themeMode) {
            'light' => ThemeMode.light,
            'dark' => ThemeMode.dark,
            _ => ThemeMode.system,
          },
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
