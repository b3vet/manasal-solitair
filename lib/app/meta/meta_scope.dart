/// MetaService'i widget ağacına taşıyan InheritedNotifier.
library;

import 'package:flutter/widgets.dart';

import 'meta_service.dart';

class MetaScope extends InheritedNotifier<MetaService> {
  const MetaScope({
    super.key,
    required MetaService service,
    required super.child,
  }) : super(notifier: service);

  /// Değişikliklere abone olarak okur (widget yeniden çizilir).
  static MetaService of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MetaScope>();
    assert(scope != null, 'MetaScope ağaçta bulunamadı');
    return scope!.notifier!;
  }

  /// Abone olmadan okur (callback/aksiyon içinden).
  static MetaService read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<MetaScope>();
    assert(scope != null, 'MetaScope ağaçta bulunamadı');
    return scope!.notifier!;
  }
}
