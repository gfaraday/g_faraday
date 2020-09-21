import 'dart:convert';
import 'dart:io';

import '../utils/exception.dart';
import 'package:g_json/g_json.dart';

import 'generator.dart';
import 'parse_string.dart';

void process(String sourceCode, String projectRoot, String identifier,
    Map<String, String> outputs) {
  void _flushSwift(String fileIdentifier, String clazz,
      {List<JSON> commonMethods, List<JSON> routeMethods}) {
    // 注意 AutoImplCommand 用到了这个token值
    final token = '$fileIdentifier|$clazz';

    final swiftCommonFile = outputs['ios-common'];
    if (swiftCommonFile != null && commonMethods != null) {
      // protocol
      final protocols = generateSwift(
          commonMethods ?? [], SwiftCodeType.protocol,
          identifier: token);
      flush(protocols, 'protocol', token, swiftCommonFile);

      // impl
      final impls = generateSwift(commonMethods ?? [], SwiftCodeType.impl,
          identifier: token);
      flush(impls, 'impl', token, swiftCommonFile);
    }

    final swiftRouteFile = outputs['ios-route'];
    if (swiftRouteFile != null) {
      // enum
      final enums = generateSwift(routeMethods ?? [], SwiftCodeType.enmu);
      flush(enums, 'enum', token, swiftRouteFile);
    }
  }

  void _flushKotlin(String fileIdentifier, String clazz,
      {List<JSON> commonMethods, List<JSON> routeMethods}) {
    print('kotlin todo --> $clazz');
  }

  final r = parse(sourceCode: sourceCode);
  // 遍历信息 准备生成 代码
  r.forEach((clazz, info) {
    final commons = info['common']?.map((m) => JSON(m.info))?.toList();
    final routes = info['route']?.map((m) => JSON(m.info))?.toList();
    _flushSwift(identifier, clazz,
        commonMethods: commons, routeMethods: routes);
    _flushKotlin(identifier, clazz,
        commonMethods: commons, routeMethods: routes);
  });
}

void flush(
    List<String> contents, String prefix, String token, String outputFilePath) {
  final file = File(outputFilePath);

  final lines = LineSplitter.split(file.readAsStringSync()).toList();

  final beginToken = '  // ---> $prefix $token';
  final endToken = '  // <--- $prefix $token';

  final begin = lines.indexWhere((l) => l.endsWith(beginToken));
  if (begin != -1) {
    final end = lines.indexWhere((l) => l.endsWith(endToken));
    if (end != -1 && end > begin) lines.removeRange(begin, end + 1);
  }

  if (contents.isNotEmpty) {
    final insert = lines.indexWhere((l) => l.endsWith(prefix));
    if (insert == -1) {
      throwToolExit('insert point not found [$prefix]');
    }
    contents.insert(0, beginToken);
    contents.add(endToken);
    lines.insertAll(insert + 1, contents);
  }

  file.writeAsStringSync(lines.join('\n'));
}
