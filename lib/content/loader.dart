/// İçerik havuzu JSON ayrıştırma (saf Dart; platformdan bağımsız).
///
/// Uygulama tarafı asset dizesini `rootBundle` ile okuyup buraya verir;
/// üretici CLI dosyayı `dart:io` ile okuyup verir.
library;

import 'dart:convert';

import 'category_pool.dart';

class Loader {
  const Loader._();

  static CategoryPool parse(String jsonStr) {
    final j = jsonDecode(jsonStr) as Map<String, dynamic>;
    final cats = <Category>[
      for (final c in (j['categories'] as List).cast<Map<String, dynamic>>())
        Category(
          id: c['id'] as String,
          name: c['name'] as String,
          difficulty: c['difficulty'] as int? ?? 1,
          words: (c['words'] as List).cast<String>(),
          softConflicts:
              (c['softConflicts'] as List?)?.cast<String>() ?? const [],
          hardConflicts:
              (c['hardConflicts'] as List?)?.cast<String>() ?? const [],
        ),
    ];
    return CategoryPool(version: j['version'] as int? ?? 1, categories: cats);
  }
}
