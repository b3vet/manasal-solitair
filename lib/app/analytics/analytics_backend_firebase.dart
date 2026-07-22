/// Firebase analitik + Crashlytics backend (mobil/masaüstü — dart.library.io).
///
/// `analyticsInit`, `Firebase.initializeApp()`'i dener. Yapılandırma dosyaları
/// (GoogleService-Info.plist / google-services.json + Gradle eklentisi)
/// eklenmemişse başlatma başarısız olur ve `false` döner — uygulama analitik
/// kapalı çalışmaya devam eder.
library;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

Future<bool> analyticsInit() async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Yapılandırma yok / başlatılamadı — sessizce devre dışı.
    return false;
  }
  // Flutter ve platform hatalarını Crashlytics'e yönlendir.
  final prevOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    prevOnError?.call(details);
    FirebaseCrashlytics.instance.recordFlutterError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  return true;
}

Future<void> analyticsSetEnabled(bool enabled) async {
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(enabled);
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);
}

Future<void> analyticsLog(String name, Map<String, Object>? params) async {
  await FirebaseAnalytics.instance.logEvent(name: name, parameters: params);
}

Future<void> analyticsSetUserProperty(String name, String value) async {
  await FirebaseAnalytics.instance.setUserProperty(name: name, value: value);
}
