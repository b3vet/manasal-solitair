/// İçerik havuzu doğrulama CLI'ı.
///
/// Kullanım: dart run bin/validate_content.dart [assets/content/categories.json]
library;

import 'dart:io';

import 'package:manasal_solitaire/content/loader.dart';
import 'package:manasal_solitaire/content/validator.dart';

void main(List<String> args) {
  final path = args.isNotEmpty ? args[0] : 'assets/content/categories.json';
  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln('İçerik dosyası bulunamadı: $path');
    exit(2);
  }

  final pool = Loader.parse(file.readAsStringSync());
  final issues = ContentValidator.validate(pool);
  final errors = issues.where((i) => i.severity == 'error').toList();
  final warns = issues.where((i) => i.severity == 'warn').toList();

  final totalWords = pool.categories.fold<int>(0, (s, c) => s + c.words.length);
  stdout.writeln('Havuz: ${pool.length} kategori, $totalWords kelime');

  for (final w in warns) {
    stdout.writeln(w);
  }
  for (final e in errors) {
    stdout.writeln(e);
  }

  if (errors.isNotEmpty) {
    stdout.writeln('\n❌ ${errors.length} hata. İçerik geçersiz.');
    exit(1);
  }
  stdout.writeln('\n✅ Geçerli (${warns.length} uyarı).');
}
