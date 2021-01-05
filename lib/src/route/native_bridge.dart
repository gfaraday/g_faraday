// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'arg.dart';
import 'navigator.dart';
import 'options.dart';

const _channel = MethodChannel('g_faraday');
final _bridgeKey =
    GlobalKey<FaradayNativeBridgeState>(debugLabel: 'default bridge');

Future<bool> _onHandler(MethodCall call) async {
  log('method: [ ${call.method} ] arguments: [ ${call.arguments} ]');
  if (_bridgeKey.currentState == null) return false;
  return _bridgeKey.currentState!._handler(call);
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
  final RouteSettings? initialSettings;

  FaradayNativeBridge({required this.onGenerateRoute, this.initialSettings})
      : super(key: _bridgeKey);

  static FaradayNativeBridgeState? of(BuildContext context) {
    if (context is StatefulElement &&
        context.state is FaradayNativeBridgeState) {
      return context.state as FaradayNativeBridgeState;
    }
    return context.findAncestorStateOfType<FaradayNativeBridgeState>();
  }

  @override
  FaradayNativeBridgeState createState() => FaradayNativeBridgeState();
}

class FaradayNativeBridgeState extends State<FaradayNativeBridge> {
  final List<FaradayPage<dynamic>> _pages = [];
  int? _previousNotFoundId;

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler(_onHandler);
    _pages.add(
      _createPage(
        FaradayArgument(
          widget.initialSettings?.arguments,
          widget.initialSettings?.name ?? '/',
          -1,
        ),
      ),
    );
  }

  // void _recreateLastPage() async {
  //   await _channel.invokeMethod('reCreateLastPage');
  //   if (_pages.isNotEmpty) {
  //     _updatePage(0);
  //   }

  //   // 如果重建页面500ms 以后还没有显示命令，默认显示首页
  //   Timer(Duration(milliseconds: 500), () {
  //     if (_pages.isNotEmpty) {
  //       _updatePage(0);
  //     }
  //   });
  // }

  void dispose() {
    _pages.clear();
    super.dispose();
  }

  Future<T?> pushNamed<T extends Object?>(
    String name, {
    Object? arguments,
    Options? options,
  }) async {
    //
    return _channel.invokeMethod<T>('pushNativePage', {
      'name': name,
      if (options != null) 'options': options.raw,
      if (arguments != null) 'arguments': arguments
    });
  }

  Future<void> pop<T extends Object>(Key key, [T? result]) {
    assert(_pages.isNotEmpty);
    assert(_pages.first.key == key);
    return _channel.invokeMethod('popContainer', result);
  }

  Future<void> disableHorizontalSwipePopGesture({required bool disable}) {
    return _channel.invokeMethod('disableHorizontalSwipePopGesture', disable);
  }

  bool isOnTop(Key key) {
    if (topNavigator == null) return false;
    return topNavigator == key;
  }

  GlobalKey<FaradayNavigatorState>? get topNavigator =>
      _pages.isEmpty ? null : _pages.first.arg.key;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: List.of(_pages),
      onPopPage: (_, __) => false,
      onGenerateRoute: widget.onGenerateRoute,
    );
  }

  Future<bool> _handler(MethodCall call) async {
    switch (call.method) {
      case 'pageCreate':
        String name = call.arguments['name'];
        int id = call.arguments['id'];

        // 通过id查找，当前堆栈中是否存在对应的页面，如果存在 直接显示出来
        final index = _findIndexBy(id: id);
        if (index != null) {
          _updatePage(index);
          return true;
        }
        final arg = FaradayArgument(call.arguments['args'], name, id,
            opaque: call.arguments['background_mode'] != 'transparent');
        _pages.add(_createPage(arg));
        if (_previousNotFoundId != null) {
          if (_previousNotFoundId == id) {
            _updatePage(_pages.length - 1);
          }
        }

        return true;
      case 'pageShow':
        final index = _findIndexBy(id: call.arguments);
        if (index == null) {
          _previousNotFoundId = call.arguments;
          return false;
        }
        _updatePage(index);
        return true;
      case 'pageDealloc':
        final index = _findIndexBy(id: call.arguments);
        assert(index != null, 'page not found seq: ${call.arguments}');
        assert(index! < _pages.length);
        final current = _pages.isEmpty ? null : _pages.first;
        _pages.removeAt(index!);
        if (current != null) {
          final newIndex = _pages.indexOf(current);
          _updatePage(newIndex == -1 ? null : newIndex);
        }
        return true;
      default:
        return false;
    }
  }

  // 如果找不到返回null，不会返回-1
  int? _findIndexBy({required int id}) {
    final index = _pages.indexWhere((page) => page.arg.id == id);
    return index != -1 ? index : null;
  }

  void _updatePage(int? index) {
    assert(index != -1);
    setState(() {
      if (index != null) {
        final page = _pages.removeAt(index);
        _pages.add(page);
      }
      log('page sequence: $_pages');
    });
  }

  FaradayPage<dynamic> _createPage(FaradayArgument arg) {
    return FaradayPage(arg, (context, settings) {
      final route = widget.onGenerateRoute(settings);
      assert(route != null);
      return route!;
    });
  }
}

typedef RouteCreator<T> = Route<T> Function(
    BuildContext context, RouteSettings settings);

class FaradayPage<T> extends Page<T> {
  final FaradayArgument arg;
  final RouteCreator<T> creator;

  FaradayPage(this.arg, this.creator)
      : super(
          key: ValueKey('${arg.name}: ${arg.id}'),
          arguments: arg.arguments,
          name: arg.name,
          restorationId: '${arg.id}',
        );

  @override
  Route<T> createRoute(BuildContext context) => creator(context, this);
}
