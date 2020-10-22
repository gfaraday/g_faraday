import 'package:flutter/widgets.dart';

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
      {Object arguments, bool present = false, bool flutterRoute = false}) {
    return FaradayNativeBridge.of(context).push<T>(
      routeName,
      arguments: arguments,
      flutterRoute: flutterRoute,
      present: present,
    );
  }
}
