/// No-op analitik backend (web ve dart.library.io olmayan hedefler). Firebase
/// içermez; tüm çağrılar sessizce hiçbir şey yapmaz.
library;

Future<bool> analyticsInit() async => false;

Future<void> analyticsSetEnabled(bool enabled) async {}

Future<void> analyticsLog(String name, Map<String, Object>? params) async {}

Future<void> analyticsSetUserProperty(String name, String value) async {}
