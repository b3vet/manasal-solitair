/// Ses efektleri servisi (audioplayers). Kod-sentezli WAV'ları önyükler ve
/// çalar. Ayara bağlı (enabled). Web'de ilk kullanıcı hareketiyle kilit açılır.
library;

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

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

  final Map<Sfx, AudioPlayer> _players = {};
  bool enabled = true;
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    for (final entry in _files.entries) {
      try {
        final p = AudioPlayer(playerId: 'sfx_${entry.key.name}');
        await p.setReleaseMode(ReleaseMode.stop);
        await p.setSource(AssetSource(entry.value));
        await p.setVolume(0.7);
        _players[entry.key] = p;
      } catch (e) {
        debugPrint('Ses yüklenemedi ${entry.value}: $e');
      }
    }
    _loaded = true;
  }

  void play(Sfx sfx) {
    if (!enabled || !_loaded) return;
    final p = _players[sfx];
    if (p == null) return;
    // Ateşle-unut; hataları yut (web autoplay vb.).
    unawaited(() async {
      try {
        await p.stop();
        await p.resume();
      } catch (_) {}
    }());
  }

  void dispose() {
    for (final p in _players.values) {
      p.dispose();
    }
    _players.clear();
    _loaded = false;
  }
}
