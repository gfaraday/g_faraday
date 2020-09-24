import 'dart:io';

import 'package:g_json/g_json.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import '../utils/exception.dart';
import '../commands/command.dart';
import '../template/template.dart' as t;

class InitCommand extends FaradayCommand {
  InitCommand() : super() {
    argParser.addOption('project-path', abbr: 'p');
    argParser.addOption('ios-common', help: '初始化 ios FaradayCommon.swift');
    argParser.addOption('ios-route', help: '初始化 ios FaradayRoute.swift');
    argParser.addOption('ios-net', help: '初始化 ios FaradayNet.swift');
    argParser.addOption('android-common', help: '初始化 android Common.kt');
    argParser.addOption('android-route', help: '初始化 android Route.kt');
    argParser.addOption('android-net', help: '初始化 android Net.kt');
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

    var projectPath = stringArg('project-path');
    if (projectPath == null || projectPath.isEmpty) {
      projectPath = path.current;
    }

    log.fine('Init debug message to lib/src/debug/debug.dart');
    final debugFile = File(path.join(projectPath, 'lib/src/debug/debug.dart'))
      ..createSync(recursive: true);

    debugFile.writeAsStringSync(t.d_debug(), mode: FileMode.write);

    final configPath = path.join(projectPath, '.faraday.json');
    final config = JSON.parse(File(configPath).readAsStringSync());

    final ios_common = stringArg('ios-common') ?? config['ios-common'].string;
    final ios_route = stringArg('ios-route') ?? config['ios-route'].string;
    final ios_net = stringArg('ios-net') ?? config['ios-net'].string;
    final android_common =
        stringArg('android-common') ?? config['android-common'].string;
    final android_route =
        stringArg('android-route') ?? config['android-route'].string;
    final android_net =
        stringArg('android-net') ?? config['android-net'].string;

    final outputs = <String, String>{
      if (ios_common != null) ios_common: t.s_common,
      if (ios_route != null) ios_route: t.s_route,
      if (ios_net != null) ios_net: t.s_net,
      if (android_common != null) android_common: t.k_common,
      if (android_route != null) android_route: t.k_route,
      if (android_net != null) android_net: t.k_net,
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
      return outputs.keys.join('\n');
    }

    return '';
  }
}
