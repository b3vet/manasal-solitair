/// Platform-bağımsız, deterministik sözde-rastgele üreteç (xoshiro128**).
///
/// `dart:math`'ın [Random]'ı platformlar arasında (özellikle web'de 32-bit)
/// farklı davranabildiği için üretici ve motor kendi PRNG'sini kullanır.
/// Aynı tohum → web'de ve mobilde bit-bit aynı dizi. (Spec §14.4)
///
/// Bu dosya bilinçli olarak `dart:math`'a bağımlı DEĞİLDİR; mimari koruma
/// testi `lib/engine` içinde `dart:math`'ın `Random` kullanımını yasaklar.
library;

class Prng {
  Prng(int seed) {
    // Tohumu SplitMix64 ile dört 32-bit duruma genişlet.
    // 32-bit xorshift ile dört durum sözcüğü türet. Yalnızca 32-bit güvenli
    // işlemler (kaydırma + xor); büyük çarpma yok → web'de (dart2js) ve mobilde
    // (VM) bit-bit aynı. 64-bit tam sayı literali KULLANILMAZ (dart2js hatası).
    var x = seed & 0xFFFFFFFF;
    if (x == 0) x = 0x9E3779B9;
    for (var i = 0; i < 4; i++) {
      x ^= (x << 13) & 0xFFFFFFFF;
      x ^= x >>> 17;
      x ^= (x << 5) & 0xFFFFFFFF;
      x &= 0xFFFFFFFF;
      _s[i] = x;
    }
    // Sıfır durumdan kaçın.
    if (_s[0] == 0 && _s[1] == 0 && _s[2] == 0 && _s[3] == 0) {
      _s[0] = 0x9E3779B9;
    }
  }

  final List<int> _s = List<int>.filled(4, 0);

  static int _rotl(int x, int k) => ((x << k) | (x >>> (32 - k))) & 0xFFFFFFFF;

  /// Sonraki 32-bit işaretsiz tam sayı.
  int nextUint32() {
    final result = (_rotl((_s[1] * 5) & 0xFFFFFFFF, 7) * 9) & 0xFFFFFFFF;
    final t = (_s[1] << 9) & 0xFFFFFFFF;
    _s[2] ^= _s[0];
    _s[3] ^= _s[1];
    _s[1] ^= _s[2];
    _s[0] ^= _s[3];
    _s[2] ^= t;
    _s[3] = _rotl(_s[3], 11);
    return result;
  }

  /// [0, bound) aralığında, modulo yanlılığı olmadan tam sayı.
  int nextInt(int bound) {
    if (bound <= 0) {
      throw ArgumentError.value(bound, 'bound', 'pozitif olmalı');
    }
    if (bound == 1) return 0;
    // Rejection sampling ile eşit dağılım.
    final threshold = (0x100000000 % bound);
    while (true) {
      final r = nextUint32();
      if (r >= threshold) return r % bound;
    }
  }

  /// [0.0, 1.0) aralığında double (tanılama/ağırlıklandırma için).
  double nextDouble() => nextUint32() / 0x100000000;

  /// Fisher-Yates karıştırma (yerinde).
  void shuffle<T>(List<T> list) {
    for (var i = list.length - 1; i > 0; i--) {
      final j = nextInt(i + 1);
      final tmp = list[i];
      list[i] = list[j];
      list[j] = tmp;
    }
  }

  /// Bir listeden rastgele öğe.
  T pick<T>(List<T> list) => list[nextInt(list.length)];

  /// Bağımsız bir alt-akış üretir (üreticide kategori/kelime/dağıtım
  /// rastgeleliğini birbirinden yalıtmak için). Aynı (seed, streamId) →
  /// aynı akış.
  Prng fork(int streamId) {
    // Mevcut durumu ve streamId'yi karıştırarak yeni 32-bit tohum türet.
    // Yalnızca 32-bit güvenli işlemler (web uyumlu).
    final a = nextUint32();
    final b = nextUint32();
    var s = a ^ b;
    s ^=
        (streamId * 0x9E3779B1) & 0xFFFFFFFF; // streamId küçük → çarpım güvenli
    s ^= (streamId << 16) & 0xFFFFFFFF;
    return Prng(s & 0xFFFFFFFF);
  }
}
