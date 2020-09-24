import 'package:flutter/widgets.dart';

abstract class Feature {
  Feature();
  // 功能描述描述
  String get description;

  // 功能名称
  String get name;

  // 作者
  String get author;

  // 注册feature中的所有页面
  Map<String, RouteFactory> get pageBuilders;
}
