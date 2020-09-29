import 'package:flutter/widgets.dart';

import 'arg.dart';
import 'native_bridge.dart';
import 'observer.dart';

/// FaradayNavigator is a root widget for each native container
class FaradayNavigator extends Navigator {
  ///
  final FaradayArguments arg;

  ///
  FaradayNavigator(
      {Key key,
      List pages = const <Page<dynamic>>[],
      PopPageCallback onPopPage,
      String initialRoute,
      RouteListFactory onGenerateInitialRoutes,
      RouteFactory onGenerateRoute,
      RouteFactory onUnknownRoute,
      DefaultTransitionDelegate transitionDelegate =
          const DefaultTransitionDelegate<dynamic>(),
      this.arg,
      List<NavigatorObserver> observers})
      : super(
            key: key,
            pages: pages,
            onPopPage: onPopPage,
            initialRoute: initialRoute,
            onGenerateInitialRoutes: onGenerateInitialRoutes,
            onGenerateRoute: onGenerateRoute,
            onUnknownRoute: onUnknownRoute,
            transitionDelegate: transitionDelegate,
            observers: [
              arg.observer,
              if (observers != null) ...observers,
            ]);

  @override
  FaradayNavigatorState createState() => FaradayNavigatorState();

  ///
  static FaradayNavigatorState of(BuildContext context) {
    FaradayNavigatorState faraday;
    if (context is StatefulElement && context.state is FaradayNavigatorState) {
      faraday = context.state as FaradayNavigatorState;
    }
    return faraday ?? context.findAncestorStateOfType<FaradayNavigatorState>();
  }
}

///
class FaradayNavigatorState extends NavigatorState {
  _FaradayWidgetsBindingObserver _observerForAndroid;

  @override
  FaradayNavigator get widget => super.widget;

  ///
  FaradayNavigatorObserver get observer => widget.arg.observer;

  @override
  void initState() {
    observer.disableHorizontalSwipePopGesture
        .addListener(notifyNativeDisableOrEnableBackGesture);
    _observerForAndroid = _FaradayWidgetsBindingObserver(this);
    WidgetsBinding.instance.addObserver(_observerForAndroid);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_observerForAndroid);
    _observerForAndroid = null;
    super.dispose();
  }

  ///
  void notifyNativeDisableOrEnableBackGesture() {
    FaradayNativeBridge.of(context).disableHorizontalSwipePopGesture(
        disable: observer.disableHorizontalSwipePopGesture.value);
  }

  @override
  void pop<T extends Object>([T result]) {
    if (observer.onlyOnePage) {
      FaradayNativeBridge.of(context).pop(widget.arg.key, result);
    } else {
      super.pop();
    }
  }
}

class _FaradayWidgetsBindingObserver extends WidgetsBindingObserver {
  final FaradayNavigatorState navigator;

  _FaradayWidgetsBindingObserver(this.navigator);

  @override
  Future<bool> didPopRoute() {
    if (!FaradayNativeBridge.of(navigator.context)
        .isOnTop(navigator.widget.arg.key)) {
      return Future.value(false);
    }
    return navigator.maybePop();
  }
}
