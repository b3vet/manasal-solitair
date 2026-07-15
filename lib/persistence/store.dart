/// Basit kalıcı belge deposu (SharedPreferences üstünde JSON).
///
/// Her belge şema sürümlüdür; bozuk/eski veri güvenle yedeklenip varsayılana
/// dönülür. (Spec §14.1, Faz 4 §3)
library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Store {
  Store(this._prefs);
  final SharedPreferences _prefs;

  Map<String, dynamic>? readDoc(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      // Bozuk veri: yedekle ve null dön (çağıran varsayılan kurar).
      _prefs.setString('${key}_corrupt', raw);
      _prefs.remove(key);
      return null;
    }
  }

  Future<void> writeDoc(String key, Map<String, dynamic> data) =>
      _prefs.setString(key, jsonEncode(data));

  Future<void> remove(String key) => _prefs.remove(key);
}
