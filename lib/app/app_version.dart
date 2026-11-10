/// Uygulama sürümü ("1.3.1") — çalışma anında platformdan okunur.
///
/// iOS'ta CFBundleShortVersionString = `$(FLUTTER_BUILD_NAME)`, yani pubspec
/// `version` alanının adı; elle yazılmış sürüm metni kaymaz. Yapı numarası
/// gösterilmez. Okunamazsa (ör. test, desteklenmeyen platform) boş kalır.
library;

import 'package:package_info_plus/package_info_plus.dart';

abstract final class AppVersion {
  static String _current = '';

  /// Sürüm adı (ör. "1.3.1"); [load] öncesi ya da okunamazsa boş.
  static String get current => _current;

  /// `main`'de `runApp` öncesi bir kez çağrılır.
  static Future<void> load() async {
    try {
      _current = (await PackageInfo.fromPlatform()).version;
    } catch (_) {
      _current = '';
    }
  }
}

/// Ayarlar → Hakkında kartı alt satırı: "Sürüm 1.3.1 · N kategori tamamlandı".
String aboutSubtitle(String version, int categoriesCompleted) {
  final done = '$categoriesCompleted kategori tamamlandı';
  return version.isEmpty ? done : 'Sürüm $version · $done';
}
