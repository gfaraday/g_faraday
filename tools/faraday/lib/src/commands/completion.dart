import 'dart:io';

import 'package:faraday/src/commands/command.dart';
import 'package:faraday/src/services/parse_string.dart';
import 'package:g_json/g_json.dart';
import 'package:recase/recase.dart';

class CompletionCommand extends FaradayCommand {
  CompletionCommand() : super() {
    argParser.addOption('offset', help: 'valid zero-based offset');
    argParser.addOption('relative-path', help: '源文件相对于 `lib`目录的相对路径');
    argParser.addOption('file');
  }

  @override
  String get description => '自动为 @common 和 @entry 生成方法实现';

  @override
  String get name => 'completion';

  // 返回自动补全的字符串数组
  @override
  String run() {
    final offsetS = stringArg('offset');
    if (offsetS == null || offsetS.isEmpty) return '';

    final offset = num.parse(offsetS, (_) => -1).toInt();
    if (offset <= 0) return '';

    final fileIdentifier = stringArg('relative-path');
    if (fileIdentifier == null || fileIdentifier.isEmpty) return '';

    // if (argResults.rest.isEmpty) return '';
    final sourceCode = File(stringArg('file')).readAsStringSync();

    final r = parse(sourceCode: sourceCode, offset: offset);

    final result = <String>[];

    r.forEach((clazz, info) {
      final token = '$fileIdentifier|$clazz';
      final common = info['common'];
      if (common.isNotEmpty) {
        result.addAll(common.map((m) =>
            "FaradayCommon.invokeMethod('$token#${m.name}', {${m.arguments.map((p) => p.dartStyle).join(', ')}}).then((r) => JSON(r))"));
      }
      final route = info['route'];
      if (route.isNotEmpty) {
        result.addAll(route.map((m) {
          final arguments = m.arguments.isNotEmpty
              ? ", arguments: {${m.arguments.map((p) => p.dartStyle).join(', ')}}"
              : null;
          return "Navigator.of(context).pushNamedFromNative('${m.name.name.snakeCase}'${arguments ?? ''})";
        }));
      }
    });
    if (result.isEmpty) return '';
    return result.first;
  }
}

extension ParameterDart on Parameter {
  String get dartStyle =>
      isRequired ? "'$name': $name" : "if ($name != null) '$name': $name";
}
