import 'package:flutter/cupertino.dart';

import 'route/native_bridge.dart';
import 'route/route.dart';

/// 核心入口类
class Faraday {
  /// 备用 后续会创建faraday注解
  const Faraday();

  ///
  ///`Flutter Native 容器`: iOS端是指`FlutterViewController` Android端是指
  ///`FlutterActivity`或者`FlutterFragment`容器初始化时需要指定 `name` 以及 `arguments`
  ///以下统一简称容器
  ///
  ///`Faraday` 内部会为每一个`容器`实例维护一个 [Navigator], 并根据`容器`参数设置 `initialRoute`
  ///
  /// 因为内部维护的时一个标准的[Navigator]对象，所以你可以像写一个纯Flutter项目那样进行页面导航以及传递参数
  ///
  /// ```dart
  /// @override
  /// void onPress() async {
  ///   final result = await Navigator.of(context).pushNamed('Any Route');
  ///   log(result.toString());
  /// }
  /// ```
  ///
  ///同理关闭页面传值也很简单
  /// ```dart
  /// @override
  /// void onPress() async {
  ///   final result = await Navigator.of(context).pop('Any ...');
  ///   log(result.toString());
  /// }
  /// ```
  ///
  Route<dynamic> wrapper(
    RouteFactory rawFactory, {
    ColorProvider? nativeContainerBackgroundColorProvider,
    TransitionBuilderProvider? switchPageAnimation,
    List<NavigatorObserver>? observers,
  }) {
    return FaradayPageRouteBuilder(
      pageBuilder: (context) {
        final page = FaradayNativeBridge(
          rawFactory,
          backgroundColorProvider: nativeContainerBackgroundColorProvider,
          transitionBuilderProvider: switchPageAnimation,
          observers: observers,
        );
        return page;
      },
    );
  }
}

///
const faraday = Faraday();
