/// Uygulama tarafı varlık yükleme (rootBundle): bölümler ve içerik havuzu.
library;

import 'package:flutter/services.dart' show rootBundle;

import '../../content/category_pool.dart';
import '../../content/levels_repository.dart';
import '../../content/loader.dart';
import '../../engine/level.dart';

class AssetData {
  const AssetData._();

  static Future<List<LevelDef>> loadLevels() async {
    final str = await rootBundle.loadString('assets/levels/levels.json');
    return LevelsRepository.parse(str);
  }

  static Future<CategoryPool> loadPool() async {
    final str = await rootBundle.loadString('assets/content/categories.json');
    return Loader.parse(str);
  }
}
