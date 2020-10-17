import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'channel.dart';
import 'route/native_bridge.dart';
import 'route/route.dart';
import 'widgets/not_found_page.dart';

typedef FaradayDecorator = Widget Function(BuildContext context, Widget child);

/// 核心入口类
class Faraday {
  ///
  const Faraday();

  ///
  ///`Flutter Native 容器`: iOS端是指`FaradayFlutterViewController` Android端是指
  ///`FlutterActivity`或者`FlutterFragment`容器初始化时需要指定 `name` 以及 `arguments`
  ///以下统一简称容器
  ///
  ///`Faraday` 内部会为每一个`容器`实例维护一个 [Navigator], 并根据`容器`参数设置 `initialRoute`
  ///
  /// 因为内部维护的时一个标准的Navigator对象，所以你可以像写一个纯Flutter项目那样进行页面导航以及传递参数
  ///
  /// ```dart
  /// @override
  /// void onPress() async {
  ///   final result = await Navigator.of(context).pushNamed('Any Route');
  ///   debugPrint(result.toString());
  /// }
  /// ```
  /// 注意如果路由未找到，会自动转发到 `Native` 侧处理
  ///
  ///同理关闭页面传值也很简单
  /// ```dart
  /// @override
  /// void onPress() async {
  ///   final result = await Navigator.of(context).pop('Any ...');
  ///   debugPrint(result.toString());
  /// }
  /// ```
  ///
  static Route<dynamic> wrapper(RouteFactory rawFactory,
      {FaradayDecorator decorator,
      RouteFactory onUnknownRoute,
      RouteFactory nativeMockFactory,
      RouteSettings mockInitialSettings}) {
    return FaradayPageRouteBuilder(
      pageBuilder: (context) {
        if (kDebugMode) {
          final page = FaradayNativeBridge(
            onGenerateRoute: rawFactory,
            onUnknownRoute: onUnknownRoute ?? _default404Page,
            mockInitialSettings: mockInitialSettings,
            mockNativeRouteFactory: nativeMockFactory,
          );
          return decorator != null ? decorator(context, page) : page;
        }
        final page = FaradayNativeBridge(
            onGenerateRoute: rawFactory,
            onUnknownRoute: onUnknownRoute ?? _default404Page);
        return decorator != null ? decorator(context, page) : page;
      },
    );
  }

  /// 发送通知到native
  /// iOS 端直接通过 NotificationCenter 监听即可
  /// android
  ///
  static Future<dynamic> postNotification(String name, {dynamic arguments}) {
    return notification.invokeMethod(name, arguments);
  }
}

Route<dynamic> _default404Page(RouteSettings settings) =>
    CupertinoPageRoute(builder: (context) => NotFoundPage(settings));

///
const faraday = Faraday();
