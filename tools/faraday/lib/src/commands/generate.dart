import 'dart:io';

import '../commands/command.dart';
import '../services/processor.dart';
import '../utils/exception.dart';
import 'package:path/path.dart' as path;

class GenerateCommand extends FaradayCommand {
  GenerateCommand() : super() {
    argParser.addOption('file', abbr: 'f', help: '解析指定文件');
    argParser.addOption('ios-common', help: 'ios FaradayCommon.swift');
    argParser.addOption('ios-route', help: 'ios FaradayRoute.swift');
    argParser.addOption('android-common', help: 'android FaradayCommon.kt');
    argParser.addOption('android-route', help: 'android FaradayRoute.kt');
  }

  @override
  String get description => 'generate route&common method(s)';

  @override
  String get name => 'generate';

  @override
  String run() {
    String projectRoot;
    final filePath = stringArg('file');

    final ios_common = stringArg('ios-common');
    final ios_route = stringArg('ios-route');
    final android_common = stringArg('android-common');
    final android_route = stringArg('android-route');

    final outputs = <String, String>{
      if (ios_common != null) 'ios-common': ios_common,
      if (ios_route != null) 'ios-route': ios_route,
      if (android_common != null) 'android-common': android_common,
      if (android_route != null) 'android-route': android_route,
    };

    if (filePath != null && filePath.contains('lib/')) {
      projectRoot = filePath.split('lib/').first;

      final metadata =
          File(path.join(projectRoot, '.metadata')).readAsStringSync();
      if (!metadata.contains('project_type: module')) {
        throw ('源文件必须包含于某个 flutter module 项目 $metadata');
      }
      if (!filePath.contains('lib/')) {
        throwToolExit('源文件必须包含于某个 flutter module 项目');
      }

      log.info('project root' + projectRoot);

      final sourceCode = File(filePath).readAsStringSync() ?? '';
      log.info('source code length: ${sourceCode.length}');

      process(sourceCode, projectRoot, filePath.split('lib/').last, outputs);

      return 'generated common(s)&route(s) for $filePath';
    }

    // 从当前目录开始查找 项目根目录
    //
    final pwd = path.current;

    if (pwd.contains('lib')) {
      projectRoot = filePath.split('lib').first;
    } else {
      if (File(path.join(pwd, 'pubspec.yaml')).existsSync()) {
        projectRoot = pwd;
      } else {
        throwToolExit('必须在flutter module项目下执行，或者指定--file');
      }
    }

    log.info('project root' + projectRoot);

    for (final item
        in Directory(pwd.contains('lib') ? pwd : path.join(projectRoot, 'lib'))
            .listSync(followLinks: false, recursive: true)) {
      if (item is File && item.path.endsWith('.dart')) {
        log.fine('processing $item');
        process(item.readAsStringSync(), projectRoot,
            item.path.split('lib/').last, outputs);
      }
    }

    return 'generated common(s)&route(s) for $projectRoot';
  }
}
