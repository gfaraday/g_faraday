// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:g_json/g_json.dart';

import '../widgets/log.dart';
import 'arg.dart';
import 'navigator.dart';
import 'options.dart';

const _channel = MethodChannel('g_faraday');

typedef TransitionBuilderProvider = TransitionBuilder? Function(
    JSON currentRoute);

typedef ColorProvider = Color Function(BuildContext context, {JSON? route});

Color _defaultBackgroundColor(BuildContext context, {JSON? route}) {
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

  // 页面默认背景
  final ColorProvider? backgroundColorProvider;

  // 页面切换动画
  final TransitionBuilderProvider? transitionBuilderProvider;

  // NavigatorObserver
  final List<NavigatorObserver>? observers;

  FaradayNativeBridge(
    this.onGenerateRoute, {
    Key? key,
    this.backgroundColorProvider,
    this.transitionBuilderProvider,
    this.observers,
  }) : super(key: key);

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
  final List<FaradayArguments> _navigators = [];
  int? _index;
  int? _previousNotFoundId;

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler(_handler);
  }

  void _recreateLastPage() async {
    await _channel.invokeMethod('reCreateLastPage');
    if (_navigators.isNotEmpty && (_index == null)) {
      _updateIndex(0);
    }

    // 如果重建页面500ms 以后还没有显示命令，默认显示首页
    Timer(Duration(milliseconds: 500), () {
      if (_navigators.isNotEmpty && (_index == null)) {
        _updateIndex(0);
      }
    });
  }

  @override
  void reassemble() {
    try {
      _recreateLastPage();
    } on MissingPluginException catch (_) {
      log('reCreateLastPage failed !!', level: Level.WARNING);
    }
    super.reassemble();
  }

  void dispose() {
    _navigators.clear();
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
    assert(_navigators.isNotEmpty);
    assert(_index != null);
    assert(_navigators[_index!].key == key);

    return _channel.invokeMethod('popContainer', result);
  }

  Future<void> disableHorizontalSwipePopGesture({required bool disable}) {
    log("swipe pop gesture ${disable ? 'disabled' : 'enabled'}");
    return _channel.invokeMethod('disableHorizontalSwipePopGesture', disable);
  }

  bool isOnTop(Key key) {
    if (_index == null) return false;
    return topNavigator == key;
  }

  GlobalKey<FaradayNavigatorState>? get topNavigator =>
      _navigators.isEmpty ? null : _navigators[_index ?? 0].key;

  @override
  Widget build(BuildContext context) {
    if (_navigators.isEmpty) {
      if (kDebugMode) {
        // 应该弹出警告错误界面
        final style = TextStyle(
            color: const Color(0xFFFFFF66),
            fontFamily: 'monospace',
            fontSize: 14.0,
            fontWeight: FontWeight.bold);
        return Container(
          color: RenderErrorBox.backgroundColor,
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
          child: Center(
            child: Wrap(
              direction: Axis.vertical,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 5.0,
              children: [
                Text(
                  'g_faraday 路由栈错误，请确认非 hot-restart 引起',
                  style: style,
                ),
                Text(
                  'tips: 可以保存当前dart文件，触发 hot-reload 从而快速恢复',
                  style: style.apply(fontSizeDelta: -2, color: Colors.grey),
                ),
                OutlineButton(
                  child: Text('点此恢复', style: style.apply(color: Colors.white)),
                  autofocus: true,
                  onPressed: reassemble,
                ),
              ],
            ),
          ),
        );
      } else {
        return Container(
          color: (widget.backgroundColorProvider ?? _defaultBackgroundColor)
              .call(context),
          alignment: Alignment.center,
          child: null,
        );
      }
    }

    if (_index == null) {
      log('g_faraday: _index is null.', level: Level.CONFIG);
    } else {
      assert(_index! < _navigators.length);
    }

    final current = _navigators[_index ?? 0];
    final content = Container(
      key: ValueKey(_index),
      color: current.opaque
          ? (widget.backgroundColorProvider ?? _defaultBackgroundColor)
              .call(context, route: current.info)
          : Colors.transparent,
      child: IndexedStack(
        children: _navigators
            .map((arg) => _buildPage(context, arg))
            .toList(growable: false),
        index: _index,
      ),
    );

    final builder = widget.transitionBuilderProvider?.call(current.info);
    if (builder == null) return content;
    return builder(context, content);
  }

  Future<bool> _handler(MethodCall call) async {
    log('g_faraday: method: ${call.method}: ${call.arguments}');
    switch (call.method) {
      case 'pageCreate':
        String name = call.arguments['name'];
        int id = call.arguments['id'];

        // 通过id查找，当前堆栈中是否存在对应的页面，如果存在 直接显示出来
        final index = _findIndexBy(id: id);
        if (index != null) {
          _updateIndex(index);
          return true;
        }
        final arg = FaradayArguments(
          call.arguments['args'],
          name,
          id,
          opaque: call.arguments['background_mode'] != 'transparent',
          observers: widget.observers,
        );
        _navigators.add(arg);
        if (_previousNotFoundId != null) {
          // show 比create 先调用
          _updateIndex(_findIndexBy(id: _previousNotFoundId!));
        }
        return true;
      case 'pageShow':
        final index = _findIndexBy(id: call.arguments);
        _previousNotFoundId = index == null ? call.arguments : null;
        if (_previousNotFoundId != null) {
          _recreateLastPage();
        }
        _updateIndex(index);
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
        return index != null;
      case 'pageDealloc':
        final index = _findIndexBy(id: call.arguments);
        assert(index != null, 'page not found seq: ${call.arguments}');
        assert(index! < _navigators.length);
        final current = _index == null ? null : _navigators[_index!];

        final arg = _navigators.removeAt(index!);
        arg.key.currentState?.clean();

        final newIndex = current != null ? _navigators.indexOf(current) : -1;
        _updateIndex(newIndex == -1
            ? _navigators.isEmpty
                ? null
                : _navigators.length - 1
            : newIndex);
        // 此时`native`容器已经`dealloc`了,不会再触发渲染会导致`flutter`侧widget延迟释放
        // 因此在这里手动触发一次渲染
        WidgetsBinding.instance?.drawFrame();
        log('''
TRIGGER `drawFrame` by hand. if you find any bugs please contact me.
Email: aoxianglele@icloud.com
Or
Github Issue: https://github.com/gfaraday/g_faraday/issues
        ''');
        return true;
      default:
        return false;
    }
  }

  // 如果找不到返回null，不会返回-1
  int? _findIndexBy({required int id}) {
    final index = _navigators.indexWhere((arg) => arg.id == id);
    return index != -1 ? index : null;
  }

  void _updateIndex(int? index) {
    assert(index != -1);
    setState(() {
      _index = index;
      _previousNotFoundId = null;

      if (_index != null && _index! < _navigators.length) {
        final value = _navigators[_index!]
            .observer
            .disableHorizontalSwipePopGesture
            .value;
        // 每次切换都需要还原一次配置
        disableHorizontalSwipePopGesture(disable: value);
      }
    });
  }

  Widget _buildPage(BuildContext context, FaradayArguments arg) {
    return FaradayNavigator(
      key: arg.key,
      arg: arg,
      initialRoute: arg.name,
      onGenerateRoute: widget.onGenerateRoute,
      onGenerateInitialRoutes: (navigator, initialRoute) {
        assert(initialRoute == arg.name);
        final settings = RouteSettings(
          name: initialRoute,
          arguments: arg.arguments,
        );
        final r = widget.onGenerateRoute(settings);
        return [if (r != null) r];
      },
    );
  }
}
