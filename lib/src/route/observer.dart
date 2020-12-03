import 'package:flutter/widgets.dart';

// ignore_for_file: public_member_api_docs
class FaradayNavigatorObserver extends NavigatorObserver {
  int _pageNumInStack = 0;

  bool get onlyOnePage => _pageNumInStack == 1;

  ValueNotifier<bool> get disableHorizontalSwipePopGesture =>
      _disableHorizontalSwipePopGesture;
  final _disableHorizontalSwipePopGesture = ValueNotifier<bool>(false);

  @override
  void didPush(Route route, Route? previousRoute) {
    _increment(route);
  }

  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _update(page: _pageNumInStack, route: newRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _decrement(previousRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    _decrement(previousRoute);
  }

  void _increment(Route route) {
    _update(page: _pageNumInStack + 1, route: route);
  }

  void _decrement(Route? route) {
    _update(page: _pageNumInStack - 1, route: route);
  }

  void _update({required int page, Route? route}) {
    _pageNumInStack = page;
    Future.delayed(Duration(milliseconds: 200)).then((_) {
      if (route is ModalRoute) {
        _disableHorizontalSwipePopGesture.value =
            // ignore: invalid_use_of_protected_member
            route.hasScopedWillPopCallback || !onlyOnePage;
      } else {
        _disableHorizontalSwipePopGesture.value = !onlyOnePage;
      }
    });
  }
}
