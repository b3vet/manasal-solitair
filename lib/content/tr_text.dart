/// Türkçe'ye duyarlı metin yardımcıları.
///
/// Dart'ın varsayılan `toLowerCase`/`toUpperCase`'i Türkçe'nin noktalı/noktasız
/// İ kurallarını bilmez (I↔ı, İ↔i). İçerikteki tüm karşılaştırmalar ve görsel
/// büyük/küçük dönüşümleri bu katmandan geçer. (Spec §12.2, risk R5)
library;

class TrText {
  const TrText._();

  static String lower(String s) {
    final buf = StringBuffer();
    for (final ch in s.split('')) {
      switch (ch) {
        case 'I':
          buf.write('ı');
        case 'İ':
          buf.write('i');
        default:
          buf.write(ch.toLowerCase());
      }
    }
    return buf.toString();
  }

  static String upper(String s) {
    final buf = StringBuffer();
    for (final ch in s.split('')) {
      switch (ch) {
        case 'i':
          buf.write('İ');
        case 'ı':
          buf.write('I');
        default:
          buf.write(ch.toUpperCase());
      }
    }
    return buf.toString();
  }

  /// İlk harf büyük, kalanı olduğu gibi (kart üzerindeki gösterim için).
  static String capitalize(String s) {
    if (s.isEmpty) return s;
    final first = upper(s.substring(0, 1));
    return '$first${s.substring(1)}';
  }

  /// Normalize edilmiş (Türkçe küçük harf + kırpılmış) karşılaştırma.
  static bool equalsNormalized(String a, String b) =>
      lower(a.trim()) == lower(b.trim());

  /// Karşılaştırma/deduplikasyon anahtarı.
  static String normalizeKey(String s) => lower(s.trim());
}
