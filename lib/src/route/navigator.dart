import 'package:flutter/widgets.dart';

import 'arg.dart';
import 'native_bridge.dart';
import 'observer.dart';

class FaradayNavigator extends Navigator {
  final FaradayArguments arg;

  FaradayNavigator(
      {Key key,
      List pages = const <Page<dynamic>>[],
      PopPageCallback onPopPage,
      String initialRoute,
      RouteListFactory onGenerateInitialRoutes,
      RouteFactory onGenerateRoute,
      RouteFactory onUnknownRoute,
      DefaultTransitionDelegate transitionDelegate = const DefaultTransitionDelegate<dynamic>(),
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

  static FaradayNavigatorState of(BuildContext context) {
    FaradayNavigatorState faraday;
    if (context is StatefulElement && context.state is FaradayNavigatorState) {
      faraday = context.state as FaradayNavigatorState;
    }
    return faraday ?? context.findAncestorStateOfType<FaradayNavigatorState>();
  }
}

class FaradayNavigatorState extends NavigatorState with WidgetsBindingObserver {
  @override
  FaradayNavigator get widget => super.widget;

  FaradayNavigatorObserver get observer => widget.arg.observer;

  @override
  void initState() {
    observer.disableHorizontalSwipePopGesture.addListener(notifyNativeDisableOrEnableBackGesture);
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  void notifyNativeDisableOrEnableBackGesture() {
    FaradayNativeBridge.of(context).disableHorizontalSwipePopGesture(observer.disableHorizontalSwipePopGesture.value);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // WidgetsBindingObserver
  @override
  Future<bool> didPopRoute() {
    if (!FaradayNativeBridge.of(context).isOnTop(widget.arg.key)) return Future.value(false);
    return maybePop();
  }

  @override
  Future<T> pushNamed<T extends Object>(String routeName, {Object arguments}) {
    try {
      return super.pushNamed(routeName, arguments: arguments);
    } catch (e) {
      return FaradayNativeBridge.of(context).push(routeName, arguments: arguments);
    }
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
