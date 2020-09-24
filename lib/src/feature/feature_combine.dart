import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../faraday.dart';
import 'feature.dart';

void _validate([List<Feature> features]) {
  if (Set.from(features.map((f) => f.name)).length != features.length) {
    throw '请勿添加重复名称的feature';
  }
  for (final feature in features) {
    if (feature.description == null || feature.description.isEmpty) {
      print('请为 ${feature.name} 添加描述 description');
    }
    if (feature.pageBuilders.keys
        .where((element) => !element.startsWith('${feature.name}'))
        .isNotEmpty) {
      throw '路由[${feature.pageBuilders.keys}]注册必须以${feature.name}开头';
    }
  }
}

RouteFactory route(List<Feature> features) {
  if (features == null || features.isEmpty) return (_) => null;

  if (kDebugMode) _validate(features);

  final rcs = features.fold<Map<String, RouteFactory>>(
      {}, (builders, f) => builders..addAll(f.pageBuilders));
  return Faraday.wrapper((settings) {
    final builder = rcs[settings.name];
    if (builder == null) return null;
    return builder(settings.arguments);
  });
}
