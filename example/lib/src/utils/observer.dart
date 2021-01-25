import 'package:flutter/material.dart';

class DemoObserver extends NavigatorObserver {
  // 请使用 route.navigator 这个navigator永远为null
  @override
  NavigatorState? get navigator => null;

  @override
  void didPop(Route route, Route? previousRoute) {
    debugPrint(
        // ignore: lines_longer_than_80_chars
        'observer: didPop ${route.settings.name} navigator: ${route.navigator}');
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    debugPrint(
        // ignore: lines_longer_than_80_chars
        'observer: didPush ${route.settings.name} navigator: ${route.navigator}');
    super.didPush(route, previousRoute);
  }
}
