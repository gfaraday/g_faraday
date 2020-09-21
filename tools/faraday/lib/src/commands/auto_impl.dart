import 'dart:io';

import 'package:faraday/src/commands/command.dart';
import 'package:faraday/src/services/parse_string.dart';
import 'package:g_json/g_json.dart';

class AutoImplCommand extends FaradayCommand {
  AutoImplCommand() : super() {
    argParser.addOption('file', abbr: 'f', help: '文件路径');
  }

  @override
  String get description => '自动为 @common 和 @entry 生成方法实现';

  @override
  String get name => 'auto-impl';

  // 返回自动补全的字符串数组
  @override
  String run() {
    final file = File(stringArg('file'));
    final fileIdentifier = file.absolute.path.split('lib/').last;

    final r = parse(sourceCode: file.readAsStringSync());
    final result = <String>[];

    r.forEach((clazz, info) {
      final token = '$fileIdentifier|$clazz';
      final common = info['common'];
      if (common != null) {
        result.addAll(common.map((m) =>
            "FaradayCommon.invokeMethod('$token#${m.name}', {${m.arguments.map((p) => p.dartStyle).join(', ')}}).then((r) => JSON(r))"));
      }
      final route = info['route'];
      if (route != null) {
        result.addAll(route.map((m) =>
            "Navigator.of(context).pushNamedFromNative('${m.name}', arguments: {${m.arguments.map((p) => p.dartStyle).join(', ')}})"));
      }
    });
    return JSON(result).rawString();
  }
}

extension ParameterDart on Parameter {
  String get dartStyle =>
      isRequired ? "'$name': $name" : "if ($name != null) '$name': name";
}
