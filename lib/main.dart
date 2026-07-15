import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/audio/sound_service.dart';
import 'app/meta/meta_scope.dart';
import 'app/meta/meta_service.dart';
import 'app/screens/home_screen.dart';
import 'app/theme/app_theme.dart';
import 'persistence/store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
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
      child: MaterialApp(
        title: 'Manasal Solitaire',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
