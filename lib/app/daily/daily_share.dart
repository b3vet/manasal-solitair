/// Günlük sonuç → paylaşılabilir metin (spoiler'sız).
///
/// Yalnız yıldız + hamle + seri + link paylaşılır; kategori/kelime ASLA
/// sızdırılmaz (başkasının bulmacasını bozmamak için). Saf fonksiyon — testli.
library;

const List<String> _trMonthsShort = [
  'Oca',
  'Şub',
  'Mar',
  'Nis',
  'May',
  'Haz',
  'Tem',
  'Ağu',
  'Eyl',
  'Eki',
  'Kas',
  'Ara',
];

/// "22 Tem" biçiminde kısa Türkçe tarih.
String dailyDateLabel(DateTime date) =>
    '${date.day} ${_trMonthsShort[date.month - 1]}';

/// 3 yuvalı yıldız satırı: kazanılan ⭐, kalan ☆.
String starRow(int stars) {
  final s = stars.clamp(0, 3);
  return '⭐' * s + '☆' * (3 - s);
}

/// Paylaşım kartı metni (spoiler'sız).
///
/// ```
/// Manasal Solitaire — 22 Tem
/// ⭐⭐⭐ · 24 hamle · 🔥 7 gün
/// https://b3vet.github.io/manasal-solitair/
/// ```
String dailyShareText({
  required DateTime date,
  required int stars,
  required int movesUsed,
  required int streak,
  String url = 'https://b3vet.github.io/manasal-solitair/',
}) {
  final parts = <String>[
    starRow(stars),
    '$movesUsed hamle',
    if (streak >= 1) '🔥 $streak gün',
  ];
  return 'Manasal Solitaire — ${dailyDateLabel(date)}\n'
      '${parts.join(' · ')}\n'
      '$url';
}
