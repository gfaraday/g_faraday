import 'package:flutter/foundation.dart';

import '../../g_faraday.dart';

/// FaradayNotification dispatched by native channel
class FaradayNotification {
  ///
  final String name;

  /// must encoding to json
  final dynamic arguments;

  ///
  FaradayNotification(this.name, this.arguments)
      : assert(name != null && name.isNotEmpty),
        super();

  @override
  String toString() {
    if (kDebugMode) {
      return 'notification: $name: ${JSON(arguments).prettyString()}';
    }
    return super.toString();
  }
}
