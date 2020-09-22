import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../faraday.dart';
import 'app.dart';

void _validate([List<App> apps]) {
  if (Set.from(apps.map((app) => app.name)).length != apps.length) {
    throw '请勿添加重复名称的app';
  }
  for (final app in apps) {
    if (app.pageBuilders.isEmpty) {
      print('请注意 ${app.name} 不包含任何页面');
    }
    if (app.description == null || app.description.isEmpty) {
      print('请为 ${app.name} 添加描述 description');
    }
    if (app.pageBuilders.keys
        .where((element) => !element.startsWith('${app.name}'))
        .isNotEmpty) {
      throw '路由[${app.pageBuilders.keys}]注册必须以${app.name}开头';
    }
  }
}

RouteFactory route(List<App> apps) {
  if (apps == null || apps.isEmpty) return (_) => null;

  if (kDebugMode) _validate(apps);

  final rcs = apps.fold<Map<String, RouteFactory>>(
      {}, (builders, app) => builders..addAll(app.pageBuilders));
  return Faraday.wrapper((settings) {
    final builder = rcs[settings.name];
    if (builder == null) return null;
    return builder(settings.arguments);
  });
}
