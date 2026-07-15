import 'package:flutter_test/flutter_test.dart';
import 'package:manasal_solitaire/content/tr_text.dart';

void main() {
  group('TrText', () {
    test('lower Türkçe İ/I kurallarına uyar', () {
      expect(TrText.lower('İNCİR'), 'incir');
      expect(TrText.lower('ISPANAK'), 'ıspanak');
      expect(TrText.lower('İstanbul'), 'istanbul');
      expect(TrText.lower('IĞDIR'), 'ığdır');
    });

    test('upper Türkçe i/ı kurallarına uyar', () {
      expect(TrText.upper('incir'), 'İNCİR');
      expect(TrText.upper('ıspanak'), 'ISPANAK');
      expect(TrText.upper('istanbul'), 'İSTANBUL');
    });

    test('capitalize ilk harfi büyütür', () {
      expect(TrText.capitalize('istanbul'), 'İstanbul');
      expect(TrText.capitalize('ısparta'), 'Isparta');
      expect(TrText.capitalize('elma'), 'Elma');
      expect(TrText.capitalize(''), '');
    });

    test('equalsNormalized kırpar ve normalize eder', () {
      expect(TrText.equalsNormalized(' Elma ', 'elma'), isTrue);
      expect(TrText.equalsNormalized('İncir', 'incir'), isTrue);
      expect(TrText.equalsNormalized('Elma', 'Armut'), isFalse);
    });

    test('normalizeKey tutarlı anahtar üretir', () {
      expect(TrText.normalizeKey('  KİRAZ '), TrText.normalizeKey('kiraz'));
    });
  });
}
