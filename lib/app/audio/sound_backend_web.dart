/// Web ses arka ucu: SFX'leri Web Audio API üzerinden çalar.
///
/// Neden audioplayers değil: audioplayers web'de HTML <audio> öğesi kullanır;
/// bu, mobil tarayıcıda (özellikle iOS) arka planda çalan müziği (Spotify vb.)
/// KESER. Web Audio API'nin AudioContext'i ise "ambient" oturum kullandığından
/// diğer sesle KARIŞIR — arka plan müziği kesilmez.
library;

import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:web/web.dart' as web;

class SoundBackend {
  web.AudioContext? _ctx;
  final Map<String, web.AudioBuffer> _buffers = {};
  static const double _volume = 0.6;

  Future<void> load(Map<String, String> files) async {
    web.AudioContext ctx;
    try {
      ctx = web.AudioContext();
    } catch (e) {
      debugPrint('AudioContext oluşturulamadı: $e');
      return;
    }
    _ctx = ctx;
    for (final entry in files.entries) {
      try {
        final data = await rootBundle.load('assets/${entry.value}');
        // Kopya oluştur (ofsetsiz saf ByteBuffer) → JSArrayBuffer.
        final bytes = Uint8List.fromList(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        );
        final buffer = await ctx.decodeAudioData(bytes.buffer.toJS).toDart;
        _buffers[entry.key] = buffer;
      } catch (e) {
        debugPrint('Ses çözülemedi ${entry.value}: $e');
      }
    }
  }

  void play(String key) {
    final ctx = _ctx;
    final buffer = _buffers[key];
    if (ctx == null || buffer == null) return;
    try {
      // İlk kullanıcı hareketinden sonra bağlam askıdaysa uyandır.
      ctx.resume();
      final source = ctx.createBufferSource();
      source.buffer = buffer;
      final gain = ctx.createGain();
      gain.gain.value = _volume;
      source.connect(gain);
      gain.connect(ctx.destination);
      source.start();
    } catch (_) {}
  }

  void dispose() {
    try {
      _ctx?.close();
    } catch (_) {}
    _ctx = null;
    _buffers.clear();
  }
}
