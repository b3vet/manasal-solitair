/// Yerel (mobil/masaüstü) ses arka ucu: audioplayers.
///
/// Ses oturumu "diğerleriyle karış" olarak ayarlanır; böylece arka planda çalan
/// müzik (ör. Spotify) kesilmez.
library;

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundBackend {
  final Map<String, AudioPlayer> _players = {};

  Future<void> load(Map<String, String> files) async {
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContextConfig(
          focus: AudioContextConfigFocus.mixWithOthers,
        ).build(),
      );
    } catch (e) {
      debugPrint('Ses bağlamı ayarlanamadı: $e');
    }
    for (final entry in files.entries) {
      try {
        final p = AudioPlayer(playerId: 'sfx_${entry.key}');
        await p.setReleaseMode(ReleaseMode.stop);
        await p.setSource(AssetSource(entry.value));
        await p.setVolume(0.7);
        _players[entry.key] = p;
      } catch (e) {
        debugPrint('Ses yüklenemedi ${entry.value}: $e');
      }
    }
  }

  void play(String key) {
    final p = _players[key];
    if (p == null) return;
    // Ateşle-unut; hataları yut.
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
  }
}
