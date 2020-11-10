import 'package:flutter/widgets.dart';
import 'package:g_json/g_json.dart';

import 'native_bridge.dart';
import 'navigator.dart';

///
extension NavigatorStateX on NavigatorState {
  /// pop native flutter container
  Future<void> nativePop<T extends Object>([T result]) {
    return FaradayNativeBridge.of(context)
        .pop(FaradayNavigator.of(context).widget.arg.key, result);
  }

  /// push native flutter container
  Future<T> nativePushNamed<T extends Object>(String routeName,
      {Object arguments, Map<String, dynamic> options}) {
    return FaradayNativeBridge.of(context)
        .push<T>(routeName, arguments: arguments, options: options);
  }
}

/// extension route settings
extension FaradayRouteSettings on RouteSettings {
  ///
  /// eg:
  /// final arg = settings.toJson;
  /// final id = arg.id;
  /// final name = arg.name;
  /// final types = arg.types;
  ///
  dynamic get toJson => JSON(arguments);
}
