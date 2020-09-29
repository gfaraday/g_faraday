import 'package:flutter/widgets.dart';

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
