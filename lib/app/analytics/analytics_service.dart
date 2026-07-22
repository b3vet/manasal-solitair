/// Analitik + çökme raporu — platformdan bağımsız cephe (facade).
///
/// Uygulamanın geri kalanı YALNIZ bu sınıfı çağırır; Firebase'e doğrudan
/// bağlanmaz. Gerçek uygulama `analytics_backend.dart` üzerinden koşullu
/// seçilir: web'de no-op stub, mobilde (dart.library.io) Firebase. Böylece
/// web derlemesi hiç Firebase kodu içermez.
///
/// Firebase yalnız yapılandırma dosyaları (GoogleService-Info.plist /
/// google-services.json) eklendiğinde başlar; aksi halde `init` sessizce
/// başarısız olur ve tüm çağrılar no-op kalır.
library;

import 'dart:async';

import 'analytics_backend.dart' as backend;

class Analytics {
  Analytics._();
  static final Analytics instance = Analytics._();

  bool _available = false; // Firebase başarıyla başlatıldı mı
  bool enabled = true; // kullanıcı opt-out (meta.analyticsEnabled)

  bool get active => _available && enabled;

  /// main() içinde bir kez. Firebase'i başlatmayı dener; başarılıysa toplama
  /// durumunu kullanıcı ayarına göre kurar.
  Future<void> init({required bool enabledSetting}) async {
    enabled = enabledSetting;
    _available = await backend.analyticsInit();
    if (_available) await backend.analyticsSetEnabled(enabled);
  }

  /// Ayarlar'daki anahtar değişince.
  Future<void> setEnabled(bool value) async {
    enabled = value;
    if (_available) await backend.analyticsSetEnabled(value);
  }

  Future<void> log(String name, [Map<String, Object>? params]) async {
    if (active) await backend.analyticsLog(name, params);
  }

  Future<void> setUserProperty(String name, String value) async {
    if (active) await backend.analyticsSetUserProperty(name, value);
  }

  // --- Kısayollar (ateşle-unut; olaylar docs/features/analytics-crashlytics.md) ---

  void levelStart(int level, {String mode = 'classic'}) =>
      unawaited(log('level_start', {'level': level, 'mode': mode}));

  void levelComplete(
    int level, {
    required int movesUsed,
    required int stars,
    required bool firstTry,
  }) => unawaited(
    log('level_complete', {
      'level': level,
      'moves_used': movesUsed,
      'stars': stars,
      'first_try': firstTry ? 1 : 0,
    }),
  );

  void levelFail(int level, {required String reason}) =>
      unawaited(log('level_fail', {'level': level, 'reason': reason}));

  void hintUsed(int level) => unawaited(log('hint_used', {'level': level}));

  void undoUsed(int level) => unawaited(log('undo_used', {'level': level}));
}
