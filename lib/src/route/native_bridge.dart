// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../channel.dart';
import 'arg.dart';
import 'navigator.dart';

class FaradayNativeBridge extends StatefulWidget {
  final RouteFactory onGenerateRoute;
  final RouteFactory onUnknownRoute;

  FaradayNativeBridge(
      {Key key, @required this.onGenerateRoute, this.onUnknownRoute})
      : super(key: key);

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
  final List<FaradayNavigator> _navigatorStack = [];
  int _index;
  int _preIndex = 0;
  int _seq = 0;

  Timer _reassembleTimer;

  @override
  void initState() {
    super.initState();
    channel.setMethodCallHandler(_handler);
  }

  @override
  void reassemble() {
    try {
      channel.invokeMethod('reCreateLastPage');
    } on MissingPluginException catch (_) {
      debugPrint('reCreateLastPage failed !!');
    }
    super.reassemble();
  }

  void dispose() {
    _navigatorStack.clear();
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
    return channel.invokeMethod<T>('pushNativePage', {
      'name': name,
      if (options != null) 'options': options,
      if (arguments != null) 'arguments': arguments
    });
  }

  Future<void> pop<T extends Object>(Key key, [T result]) async {
    assert(_navigatorStack.isNotEmpty);
    assert(_navigatorStack[_index].arg.key == key);
    await channel.invokeMethod('popContainer', result);
  }

  Future<void> disableHorizontalSwipePopGesture({bool disable}) async {
    await channel.invokeMethod('disableHorizontalSwipePopGesture', disable);
  }

  bool isOnTop(Key key) {
    return _navigatorStack.isNotEmpty && _navigatorStack[_index].arg.key == key;
  }

  @override
  Widget build(BuildContext context) {
    if (_index == null || _navigatorStack.isEmpty) {
      if (kDebugMode) {
        if (_reassembleTimer == null) {
          _reassembleTimer = Timer(Duration(milliseconds: 1),
              WidgetsBinding.instance.reassembleApplication);
        }
        return Container(
          color: CupertinoDynamicColor.resolve(CupertinoColors.white, context),
          child: Center(
            child: Text('Reassemble Application ...'),
          ),
        );
      }
      return Center(
          child: CupertinoActivityIndicator(
        animating: true,
      ));
    }

    if (kDebugMode) {
      _reassembleTimer?.cancel();
    }
    return IndexedStack(
      children: _navigatorStack,
      index: _index,
    );
  }

  Future<dynamic> _handler(MethodCall call) {
    switch (call.method) {
      case 'pageCreate':
        String name = call.arguments['name'];
        final seq = call.arguments['seq'] as int;
        // seq 不等于null 证明整个app 部分状态丢失，此时需要重建页面
        if (seq != null) {
          if (seq == -1) {
            debugPrint('recreate page: $name seq: $seq');
          } else {
            // seq 不为空 native可能重复调用了oncreate 方法
            final index = _findIndexBy(seq: seq);
            if (index != null) {
              _updateIndex(index);
              return Future.value(index);
            }
            _seq = seq;
          }
        }
        final arg = FaradayArguments(call.arguments['args'], name, _seq++);
        _navigatorStack.add(_appRoot(arg));
        _updateIndex(_navigatorStack.length - 1);
        return Future.value(arg.seq);
      case 'pageShow':
        final index = _findIndexBy(seq: call.arguments);
        _updateIndex(index);
        return Future.value(index != null);
      case 'pageHidden':
        final index = _findIndexBy(seq: call.arguments);
        if (index == _index) {
          _updateIndex(_preIndex);
          return Future.value(true);
        }
        return Future.value(false);
      case 'pageDealloc':
        assert(_index != null, _index < _navigatorStack.length);
        final current = _navigatorStack[_index];
        final index = _findIndexBy(seq: call.arguments);
        assert(index != null, 'page not found seq: ${call.arguments}');
        _navigatorStack.removeAt(index);
        _updateIndex(_navigatorStack.indexOf(current));
        return Future.value(true);
      default:
        return Future.value(false);
    }
  }

  // 如果找不到返回null，不会返回-1
  int _findIndexBy({@required int seq}) {
    assert(seq != null);
    final index = _navigatorStack.indexWhere((n) => n.arg.seq == seq);
    return index != -1 ? index : null;
  }

  void _updateIndex(int index) {
    if (index == null) return;
    if (index == _index) return;
    setState(() {
      _preIndex = _index;
      _index = index;
      debugPrint('index: $_index, preIndex: $_preIndex, max_seq: $_seq');
    });
  }

  FaradayNavigator _appRoot(FaradayArguments arg) {
    final initialSettings =
        RouteSettings(name: arg.name, arguments: arg.arguments);
    return FaradayNavigator(
      key: GlobalKey(debugLabel: 'seq: ${arg.seq}'),
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
