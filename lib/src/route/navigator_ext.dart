import 'package:flutter/widgets.dart';
import 'package:g_json/g_json.dart';

import 'native_bridge.dart';
import 'navigator.dart';
import 'options.dart';

///
extension NavigatorStateX on NavigatorState {
  /// pop native flutter container
  Future<void> nativePop<T extends Object>([T result]) {
    final bridge = FaradayNativeBridge.of(context);
    if (bridge != null) {
      final key = FaradayNavigator.of(context).widget.arg.key;
      return bridge.pop(key, result);
    }
    throw 'FaradayNativeBridge not found !! $context';
  }

  /// push native flutter container
  Future<T> nativePushNamed<T extends Object>(String routeName,
      {Object arguments, Options options}) {
    final bridge = FaradayNativeBridge.of(context);
    if (bridge != null) {
      return bridge.pushNamed<T>(routeName,
          arguments: arguments, options: options);
    }

    throw 'FaradayNativeBridge not found !! $context';
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
