// Mimari koruma: engine ve generator saf Dart kalmalı.
//
// - `lib/engine` ve `lib/generator` içinde `package:flutter` / `dart:ui` yasak.
// - `lib/engine` içinde `dart:math` içe aktarımı yasak (deterministik PRNG
//   zorunlu — Spec §14.4). Yorumlardaki geçişler sayılmaz; yalnızca gerçek
//   `import` satırları taranır.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Bir dosyadaki gerçek import edilen kütüphaneleri döndürür (yorumları atlar).
Set<String> _imports(String src) {
  final result = <String>{};
  final re = RegExp(
    r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
    multiLine: true,
  );
  for (final m in re.allMatches(src)) {
    result.add(m.group(1)!);
  }
  return result;
}

Iterable<File> _dartFiles(String dir) sync* {
  final d = Directory(dir);
  if (!d.existsSync()) return;
  for (final f in d.listSync(recursive: true).whereType<File>()) {
    if (f.path.endsWith('.dart')) yield f;
  }
}

void main() {
  group('mimari koruma', () {
    test('engine ve generator Flutter içe aktarmaz', () {
      final offenders = <String>[];
      for (final dir in ['lib/engine', 'lib/generator']) {
        for (final f in _dartFiles(dir)) {
          final imports = _imports(f.readAsStringSync());
          if (imports.any(
            (i) => i.startsWith('package:flutter') || i == 'dart:ui',
          )) {
            offenders.add(f.path);
          }
        }
      }
      expect(
        offenders,
        isEmpty,
        reason: 'Bu dosyalar Flutter içe aktarıyor: $offenders',
      );
    });

    test('engine dart:math içe aktarmaz', () {
      final offenders = <String>[];
      for (final f in _dartFiles('lib/engine')) {
        if (_imports(f.readAsStringSync()).contains('dart:math')) {
          offenders.add(f.path);
        }
      }
      expect(
        offenders,
        isEmpty,
        reason: 'engine PRNG yerine dart:math kullanıyor: $offenders',
      );
    });
  });
}
