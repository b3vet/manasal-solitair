/// Ses efektleri servisi. Kod-sentezli WAV'ları önyükler ve çalar; ayara bağlı
/// (enabled). Platforma göre arka uç seçilir:
///  - Web: Web Audio API (arka plan müziğini KESMEZ, karışır).
///  - Yerel: audioplayers ("diğerleriyle karış" ayarıyla).
library;

import 'sound_backend_web.dart' if (dart.library.io) 'sound_backend_io.dart';

enum Sfx {
  place,
  collect,
  flip,
  draw,
  invalid,
  sweep,
  complete,
  win,
  lose,
  button,
}

class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  static const Map<Sfx, String> _files = {
    Sfx.place: 'audio/place.wav',
    Sfx.collect: 'audio/collect.wav',
    Sfx.flip: 'audio/flip.wav',
    Sfx.draw: 'audio/draw.wav',
    Sfx.invalid: 'audio/invalid.wav',
    Sfx.sweep: 'audio/sweep.wav',
    Sfx.complete: 'audio/complete.wav',
    Sfx.win: 'audio/win.wav',
    Sfx.lose: 'audio/lose.wav',
    Sfx.button: 'audio/button.wav',
  };

  final SoundBackend _backend = SoundBackend();
  bool enabled = true;
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final files = {for (final e in _files.entries) e.key.name: e.value};
    await _backend.load(files);
    _loaded = true;
  }

  void play(Sfx sfx) {
    if (!enabled || !_loaded) return;
    _backend.play(sfx.name);
  }

  void dispose() {
    _backend.dispose();
    _loaded = false;
  }
}
