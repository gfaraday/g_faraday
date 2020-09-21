import 'dart:io';

import 'package:g_json/g_json.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import '../utils/exception.dart';
import '../commands/command.dart';

class InitCommand extends FaradayCommand {
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
    print(welcome);

    Logger.root.level = Level.ALL;

    log.info('faraday将帮你集成`g_faraday`');

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
        '请输入静态文件服务器地址，需要支持上传下载。 如需帮助请点击 https://github.com/yuxiaormobi/xxx.md');
    log.config('static-file-server-address: ');

    config['static-file-server-address'] = stdin.readLineSync();

    log.fine(
        '请输入 cocoapods private spec 名称。如需帮助: https://github.com/yuxiaormob/xxx.md');
    log.config('cocoapods-repo-name: ');
    config['pod-repo-name'] = stdin.readLineSync();

    // 写文件
    File(path.join(projectPath, '.faraday.json'))
        .writeAsStringSync(config.prettyString());

    // 需要帮忙生成一堆文件
    return '';
  }
}
