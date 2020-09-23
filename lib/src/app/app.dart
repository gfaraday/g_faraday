import 'package:flutter/widgets.dart';

abstract class App {
  App();
  // 应用描述
  String get description;

  // 应用名称
  String get name;

  // 应用author
  String get author;

  // 注册app中的所有页面
  Map<String, RouteFactory> get pageBuilders;
}
