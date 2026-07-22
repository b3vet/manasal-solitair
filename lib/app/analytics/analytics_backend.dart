/// Analitik backend seçimi (koşullu import). Web / dart.library.io olmayan
/// hedeflerde no-op stub; mobil/masaüstünde Firebase. `sound_backend.dart` ile
/// aynı desen — web derlemesi Firebase içermez.
library;

export 'analytics_backend_stub.dart'
    if (dart.library.io) 'analytics_backend_firebase.dart';
