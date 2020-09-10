import 'package:flutter/widgets.dart';

import 'navigator.dart';
import 'native_bridge.dart';

extension NavigatorStateX on NavigatorState {
  Future<void> popUntilNative<T>(BuildContext context, [T result]) {
    return FaradayNativeBridge.of(context).pop(FaradayNavigator.of(context).widget.arg.key, result);
  }

  Future<T> pushNamedFromNative<T extends Object>(String routeName, {Object arguments, bool present = false, bool flutterRoute = true}) {
    return FaradayNativeBridge.of(context).push(
      routeName,
      arguments: arguments,
      flutterRoute: flutterRoute,
      present: present,
    );
  }
}
