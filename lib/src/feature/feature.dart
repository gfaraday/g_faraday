import 'package:flutter/widgets.dart';
import 'package:g_json/g_json.dart';

/// 一组业务需求的功能集合
abstract class Feature {
  /// 功能描述描述
  String get description => '';

  /// 作者
  String get author => 'Unowner';

  /// 功能名称
  String get name;

  /// 注册feature中的所有页面
  Map<String, RouteFactory> get pageBuilders => {};
}

/// Convenience method for routesettings
/// JSON object ref: https://pub.dev/packages/g_json
///
extension RouteSettingsFaraday on RouteSettings {
  ///
  /// eg:
  /// final arg = settings.toJson;
  /// final id = arg.id;
  /// final name = arg.name;
  /// final types = arg.types;
  ///
  dynamic get toJson => JSON(arguments);
}
