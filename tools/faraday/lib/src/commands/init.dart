import 'dart:io';

import 'package:g_json/g_json.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import '../utils/exception.dart';
import '../commands/command.dart';
import '../template/template.dart' as t;

class InitCommand extends FaradayCommand {
  InitCommand() : super() {
    argParser.addOption('ios-common', help: '初始化 ios FaradayCommon.swift');
    argParser.addOption('ios-route', help: '初始化 ios FaradayRoute.swift');
    argParser.addOption('android-common', help: '初始化 android Common.kt');
    argParser.addOption('android-route', help: '初始化 android Route.kt');
  }

  @override
  String get description => 'init faraday project';

  @override
  String get name => 'init';

  @override
  String run() {
    final welcome = '''
   ___                   _             
  / __\\_ _ _ __ __ _  __| | __ _ _   _ 
 / _\\/ _` | '__/ _` |/ _` |/ _` | | | |
/ / | (_| | | | (_| | (_| | (_| | |_| |
\\/   \\__,_|_|  \\__,_|\\__,_|\\__,_|\\__, |
                                 |___/       
    ''';
    log.info(welcome);

    Logger.root.level = Level.ALL;

    final ios_common = stringArg('ios-common');
    final ios_route = stringArg('ios-route');
    final ios_net = stringArg('ios_net');
    final android_common = stringArg('android-common');
    final android_route = stringArg('android-route');
    final android_net = stringArg('android_net');

    final outputs = <String, String>{
      if (ios_common != null) ios_common: t.s_common,
      if (ios_route != null) ios_route: t.s_route,
      if (ios_net != null) ios_route: t.s_net,
      if (android_common != null) android_common: t.k_common,
      if (android_route != null) android_route: t.k_route,
      if (android_net != null) android_route: t.k_net,
    };

    if (outputs.isNotEmpty) {
      outputs.forEach((fp, c) {
        // android 需要吧package 信息拿出来
        if (c.contains('fun ')) {
          final ktfile = File(fp).readAsStringSync().split('\n');
          if (ktfile.isEmpty || !ktfile.first.startsWith('package ')) {
            throwToolExit('Kotlin file must starts with `package `');
          }
          final package = ktfile.first;
          c = package + '\n\n' + c;
        }
        File(fp).writeAsStringSync(c, mode: FileMode.write);
      });
      return outputs.keys.join(' ');
    }

    log.fine('faraday将帮你集成`g_faraday`\n');

    // 拉取模版
    var projectPath = path.current;
    if (projectPath.contains('/lib')) {
      projectPath = projectPath.split('/lib').first;
    }

    final pubspec = File(path.join(projectPath, 'pubspec.yaml'));
    if (!pubspec.existsSync()) {
      throwToolExit('请在flutter module 项目下执行');
    }

    // final metadata =
    //     File(path.join(projectPath, '.metadata')).readAsStringSync();
    // if (!metadata.contains('project_type: module')) {
    //   throwToolExit('请在flutter module 项目中使用此框架');
    // }

    final config = JSON({});
    config['project'] = '.';

    log.fine(
        '输入静态文件服务器地址，需要支持上传下载。 如需帮助请点击 https://github.com/yuxiaormobi/xxx.md');
    log.config('static-file-server-address: ');

    config['static-file-server-address'] = stdin.readLineSync();

    log.fine(
        '输入 cocoapods private spec 名称。如需帮助: https://github.com/yuxiaormob/xxx.md');
    log.config('cocoapods-repo-name: ');
    config['pod-repo-name'] = stdin.readLineSync();

    // 写文件
    File(path.join(projectPath, '.faraday.json'))
        .writeAsStringSync(config.prettyString('  '));

    return '';
  }
}
