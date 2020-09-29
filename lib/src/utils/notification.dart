import 'package:flutter/widgets.dart';

/// FaradayNotification dispatched by native channel
class FaradayNotification extends Notification {
  ///
  final String name;

  /// must encoding to json
  final dynamic arguments;

  ///
  FaradayNotification(this.name, this.arguments)
      : assert(name != null && name.isNotEmpty),
        super();
}
