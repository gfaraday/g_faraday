// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:g_json/g_json.dart';

import 'arg.dart';
import 'navigator.dart';

const _channel = MethodChannel('g_faraday');

typedef TransitionBuilderProvider = TransitionBuilder
    Function(JSON currentRoute, {JSON previousRoute});

typedef ColorProvider = Color Function(BuildContext context);

Color _defaultBackgroundColor(BuildContext context) {
  return MediaQuery.of(context).platformBrightness == Brightness.light
      ? CupertinoColors.white
      : CupertinoColors.black;
}

///
/// backgroundColorProvider
///
/// 如果当前页面不为透明背景，默认为根据系统是否黑暗模式默认为 黑/白
///
/// transitionBuilderProvider
///
/// 页面切换动画，默认返回null 使用native系统默认动画即可，在一下几种场景中需要手动自定义
///
///
/// android
///
/// fragment 切换
/// activity的launch mode 不为 standard 的情况
///
/// ios
/// addChild 或者是 禁用了系统默认动画的情况
class FaradayNativeBridge extends StatefulWidget {
  final RouteFactory onGenerateRoute;
  final RouteFactory onUnknownRoute;

  // 页面默认背景
  final ColorProvider backgroundColorProvider;

  // 页面切换动画
  final TransitionBuilderProvider transitionBuilderProvider;

  FaradayNativeBridge(
    this.onGenerateRoute, {
    Key key,
    this.onUnknownRoute,
    this.backgroundColorProvider,
    this.transitionBuilderProvider,
  }) : super(key: key);

  static FaradayNativeBridgeState of(BuildContext context) {
    FaradayNativeBridgeState faraday;
    if (context is StatefulElement &&
        context.state is FaradayNativeBridgeState) {
      faraday = context.state as FaradayNativeBridgeState;
    }
    return faraday ??
        context.findAncestorStateOfType<FaradayNativeBridgeState>();
  }

  @override
  FaradayNativeBridgeState createState() => FaradayNativeBridgeState();
}

class FaradayNativeBridgeState extends State<FaradayNativeBridge> {
  final List<FaradayArguments> _navigators = [];
  int _index;
  int _preIndex;
  int _previousNotFoundId;

  Timer _reassembleTimer;

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler(_handler);
  }

  void _recreateLastPage() {
    _channel.invokeMethod('reCreateLastPage');
  }

  @override
  void reassemble() {
    try {
      _recreateLastPage();
    } on MissingPluginException catch (_) {
      debugPrint('reCreateLastPage failed !!');
    }
    super.reassemble();
  }

  void dispose() {
    _navigators.clear();
    super.dispose();
    if (kDebugMode) {
      _reassembleTimer?.cancel();
    }
  }

  Future<T> push<T extends Object>(
    String name, {
    Object arguments,
    Map<String, dynamic> options,
  }) async {
    //
    return _channel.invokeMethod<T>('pushNativePage', {
      'name': name,
      if (options != null) 'options': options,
      if (arguments != null) 'arguments': arguments
    });
  }

  Future<void> pop<T extends Object>(Key key, [T result]) async {
    assert(_navigators.isNotEmpty);
    assert(_navigators[_index].key == key);
    await _channel.invokeMethod('popContainer', result);
  }

  Future<void> disableHorizontalSwipePopGesture({bool disable}) async {
    await _channel.invokeMethod('disableHorizontalSwipePopGesture', disable);
  }

  bool isOnTop(Key key) {
    return _navigators.isNotEmpty && _navigators[_index].key == key;
  }

  @override
  Widget build(BuildContext context) {
    if (_index == null || _navigators.isEmpty || _index == -1) {
      if (kDebugMode) {
        if (_reassembleTimer == null) {
          // 只有在开发过程中 Relaunch 才会执行的逻辑
          _reassembleTimer = Timer(Duration(seconds: 5), () {
            if (_index == null || _index < 0) {
              WidgetsBinding.instance.reassembleApplication();
              _reassembleTimer = null;
            }
          });
        }
      }
      return Container(
        color: (widget.backgroundColorProvider ?? _defaultBackgroundColor)
            .call(context),
        alignment: Alignment.center,
      );
    }

    if (kDebugMode) {
      _reassembleTimer?.cancel();
    }

    final current = _navigators[_index];
    final content = Container(
      key: ValueKey(_index),
      color: current.opaque
          ? (widget.backgroundColorProvider ?? _defaultBackgroundColor)
              .call(context)
          : Colors.transparent,
      child: IndexedStack(
        children: _navigators
            .map((arg) => _buildPage(context, arg))
            .toList(growable: false),
        index: _index,
      ),
    );
    if (widget.transitionBuilderProvider == null || _preIndex == _index) {
      return content;
    }
    final previous =
        (_preIndex != null && _preIndex >= 0) ? _navigators[_preIndex] : null;
    final builder = widget.transitionBuilderProvider(current.info,
        previousRoute: previous?.info);
    if (builder == null) return content;
    return builder(context, content);
  }

  Future<bool> _handler(MethodCall call) async {
    debugPrint('page lifecycle: ${call.method} ${call.arguments}');
    switch (call.method) {
      case 'pageCreate':
        String name = call.arguments['name'];
        int id = call.arguments['id'];

        assert(name != null);
        assert(id != null);

        // 通过id查找，当前堆栈中是否存在对应的页面，如果存在 直接显示出来
        final index = _findIndexBy(id: id);
        if (index != null) {
          _updateIndex(index);
          return true;
        }
        // seq 不为空 native可能重复调用了onCreate 方法

        final arg = FaradayArguments(call.arguments['args'], name, id,
            opaque: call.arguments['background_mode'] != 'transparent');
        _navigators.add(arg);
        if (_previousNotFoundId != null) {
          // show 比create 先调用
          _updateIndex(_findIndexBy(id: _previousNotFoundId));
        }
        return true;
      case 'pageShow':
        final index = _findIndexBy(id: call.arguments);
        _previousNotFoundId = index == null ? call.arguments : null;
        if (_previousNotFoundId != null) {
          _recreateLastPage();
        }
        _updateIndex(index);
        return Future.value(index != null);
      case 'pageDealloc':
        assert(_index != null, _index < _navigators.length);
        final current = _navigators[_index];
        final index = _findIndexBy(id: call.arguments);
        assert(index != null, 'page not found seq: ${call.arguments}');
        _navigators.removeAt(index);
        _updateIndex(_navigators.indexOf(current));
        return Future.value(true);
      default:
        return Future.value(false);
    }
  }

  // 如果找不到返回null，不会返回-1
  int _findIndexBy({@required int id}) {
    final index = _navigators.indexWhere((arg) => arg.id == id);
    return index != -1 ? index : null;
  }

  void _updateIndex(int index) {
    setState(() {
      _preIndex = _index;
      _index = index;
      debugPrint('index: $_index');
    });
  }

  Widget _buildPage(BuildContext context, FaradayArguments arg) {
    final initialSettings =
        RouteSettings(name: arg.name, arguments: arg.arguments);
    // return TweenAnimationBuilder<double>(
    //   builder: (context, value, child) => Opacity(
    //     opacity: value,
    //     child: child,
    //   ),
    //   child: FaradayNavigator(
    //     key: arg.key,
    //     arg: arg,
    //     initialRoute: arg.name,
    //     onGenerateRoute: widget.onGenerateRoute,
    //     onUnknownRoute: widget.onUnknownRoute,
    //     onGenerateInitialRoutes: (navigator, initialRoute) => [
    //       widget.onGenerateRoute(initialSettings) ??
    //           widget.onUnknownRoute(initialSettings),
    //     ],
    //   ),
    //   duration: Duration(milliseconds: 180),
    //   tween: Tween(begin: 0, end: 1),
    // );
    return FaradayNavigator(
      key: arg.key,
      arg: arg,
      initialRoute: arg.name,
      onGenerateRoute: widget.onGenerateRoute,
      onUnknownRoute: widget.onUnknownRoute,
      onGenerateInitialRoutes: (navigator, initialRoute) => [
        widget.onGenerateRoute(initialSettings) ??
            widget.onUnknownRoute(initialSettings),
      ],
    );
  }
}
