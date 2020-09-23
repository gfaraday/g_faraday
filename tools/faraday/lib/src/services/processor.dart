import 'dart:convert';
import 'dart:io';

import 'package:faraday/src/services/kotlin_generator.dart';

import '../utils/exception.dart';
import 'package:g_json/g_json.dart';

import 'swift_generator.dart';
import 'parse_string.dart';

void process(String sourceCode, String projectRoot, String identifier,
    Map<String, String> outputs) {
  void _flushSwift(String token, String clazz,
      {List<JSON> commonMethods, List<JSON> routeMethods}) {
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
      flush(impls, 'impl', token, swiftCommonFile, indentation: '        ');
    }

    final swiftRouteFile = outputs['ios-route'];
    if (swiftRouteFile != null) {
      // enum
      final enums = generateSwift(routeMethods ?? [], SwiftCodeType.enmu);
      flush(enums, 'enum', token, swiftRouteFile);

      final enumPages =
          generateSwift(routeMethods ?? [], SwiftCodeType.enumPage);
      flush(enumPages, 'enum_page', token, swiftRouteFile,
          indentation: '            ');
    }
  }

  void _flushKotlin(String token, String clazz,
      {List<JSON> commonMethods, List<JSON> routeMethods}) {
    print('kotlin todo --> $clazz');

    final kotlinCommonFile = outputs['android-common'];
    if (kotlinCommonFile != null) {
      final interface = generateKotlin(
          commonMethods ?? [], KotlinCodeType.interface,
          identifier: token);
      flush(interface, 'interface', token, kotlinCommonFile);

      final impls = generateKotlin(commonMethods ?? [], KotlinCodeType.impl,
          identifier: token);
      flush(impls, 'impl', token, kotlinCommonFile);
    }

    final kotlinRouteFile = outputs['android-route'];
    if (kotlinRouteFile != null) {
      // sealed class
      final sealeds = generateKotlin(routeMethods ?? [], KotlinCodeType.sealed,
          identifier: token);
      flush(sealeds, 'sealed', token, kotlinRouteFile, indentation: '');
    }
  }

  final r = parse(sourceCode: sourceCode);

  // 遍历信息 准备生成 代码
  r.forEach((clazz, info) {
    final commons = info['common']?.map((m) => JSON(m.info))?.toList();
    final routes = info['route']?.map((m) => JSON(m.info))?.toList();
    // 注意 AutoImplCommand 用到了这个token值
    final token = '$identifier|$clazz';
    _flushSwift(token, clazz, commonMethods: commons, routeMethods: routes);
    _flushKotlin(token, clazz, commonMethods: commons, routeMethods: routes);
  });
}

void flush(
    List<String> contents, String prefix, String token, String outputFilePath,
    {String indentation = '    '}) {
  final file = File(outputFilePath);

  final lines = LineSplitter.split(file.readAsStringSync()).toList();

  final beginToken = '$indentation// ---> $prefix $token';
  final endToken = '$indentation// <--- $prefix $token';

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
