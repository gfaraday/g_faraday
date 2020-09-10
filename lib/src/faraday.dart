import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'route/native_bridge.dart';
import 'route/route.dart';

typedef FaradayDecorator = Widget Function(BuildContext context, Widget child);

class Faraday {
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
  static RouteFactory factory(RouteFactory rawFactory,
      {FaradayDecorator decorator, RouteFactory nativeMockFactory, String mockInitialname, Object mockInitialArguments}) {
    final f = (settings) {
      return FaradayPageRouteBuilder(
        pageBuilder: (context) {
          if (kDebugMode) {
            if (nativeMockFactory != null) assert(mockInitialname != null && mockInitialname.isNotEmpty);
            final page = FaradayNativeBridge(
              onGenerateRoute: rawFactory,
              mockInitialSettings: RouteSettings(name: mockInitialname, arguments: mockInitialArguments),
              mockNativeRouteFactory: nativeMockFactory,
            );
            return decorator != null ? decorator(context, page) : page;
          }
          final page = FaradayNativeBridge(onGenerateRoute: rawFactory);
          return decorator != null ? decorator(context, page) : page;
        },
        settings: settings,
      );
    };
    return f;
  }
}
