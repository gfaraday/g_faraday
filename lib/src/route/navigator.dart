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
      {Key? key,
      PopPageCallback? onPopPage,
      required String initialRoute,
      required RouteListFactory onGenerateInitialRoutes,
      required RouteFactory onGenerateRoute,
      RouteFactory? onUnknownRoute,
      DefaultTransitionDelegate transitionDelegate =
          const DefaultTransitionDelegate<dynamic>(),
      required this.arg,
      List<NavigatorObserver>? observers})
      : super(
            key: key,
            onPopPage: onPopPage,
            initialRoute: initialRoute,
            onGenerateRoute: onGenerateRoute,
            onUnknownRoute: onUnknownRoute,
            onGenerateInitialRoutes: onGenerateInitialRoutes,
            transitionDelegate: transitionDelegate,
            observers: [
              arg.observer,
              if (observers != null) ...observers,
            ]);

  @override
  FaradayNavigatorState createState() => FaradayNavigatorState();

  ///
  static FaradayNavigatorState of(BuildContext context) {
    if (context is StatefulElement && context.state is FaradayNavigatorState) {
      return context.state as FaradayNavigatorState;
    }
    final faraday = context.findAncestorStateOfType<FaradayNavigatorState>();
    assert(faraday != null);
    return faraday!;
  }
}

///
class FaradayNavigatorState extends NavigatorState {
  late _FaradayWidgetsBindingObserver? _observerForAndroid;

  @override
  FaradayNavigator get widget => super.widget as FaradayNavigator;

  ///
  FaradayNavigatorObserver get observer => widget.arg.observer;

  @override
  void initState() {
    observer.disableHorizontalSwipePopGesture
        .addListener(notifyNativeDisableOrEnableBackGesture);
    _observerForAndroid = _FaradayWidgetsBindingObserver(this);
    WidgetsBinding.instance?.addObserver(_observerForAndroid!);
    super.initState();
  }

  @override
  void dispose() {
    observer.disableHorizontalSwipePopGesture
        .removeListener(notifyNativeDisableOrEnableBackGesture);
    if (_observerForAndroid != null) {
      WidgetsBinding.instance?.removeObserver(_observerForAndroid!);
      _observerForAndroid = null;
    }
    super.dispose();
  }

  ///
  void notifyNativeDisableOrEnableBackGesture() {
    FaradayNativeBridge.of(context)?.disableHorizontalSwipePopGesture(
        disable: observer.disableHorizontalSwipePopGesture.value);
  }

  @override
  Future<T?> pushNamed<T extends Object?>(String routeName,
      {Object? arguments}) {
    try {
      return super.pushNamed(routeName, arguments: arguments);
      // ignore: avoid_catching_errors
    } on FlutterError catch (e) {
      debugPrint('g_faraday FaradayNavigator $e');
      debugPrint('fallback to native. name: $routeName, arguments: $arguments');

      final bridge = FaradayNativeBridge.of(context);
      assert(bridge != null);
      return bridge!.pushNamed<T>(routeName, arguments: arguments);
    }
  }

  @override
  void pop<T extends Object?>([T? result]) {
    if (observer.onlyOnePage) {
      FaradayNativeBridge.of(context)?.pop<Object>(widget.arg.key, result);
    } else {
      super.pop(result);
    }
  }

  @override
  Future<bool> maybePop<T extends Object?>([T? result]) async {
    final r = await super.maybePop(result);
    if (!r && observer.onlyOnePage) {
      pop(result);
      return true;
    }
    return r;
  }
}

class _FaradayWidgetsBindingObserver extends WidgetsBindingObserver {
  final FaradayNavigatorState navigator;

  _FaradayWidgetsBindingObserver(this.navigator);

  @override
  Future<bool> didPopRoute() async {
    final bridge = FaradayNativeBridge.of(navigator.context);
    assert(bridge != null);
    if (!bridge!.isOnTop(navigator.widget.arg.key)) {
      return false;
    }
    return await navigator.maybePop();
  }
}
