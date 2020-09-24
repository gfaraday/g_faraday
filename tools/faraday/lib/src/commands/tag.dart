import 'dart:io';

import 'package:dio/dio.dart';
import 'package:faraday/src/commands/command.dart';
import 'package:faraday/src/template/template.dart';
import 'package:faraday/src/utils/exception.dart';
import 'package:g_json/g_json.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';
import 'package:shell/shell.dart';
import 'package:recase/recase.dart';

const pluginRegistrant = 'FlutterPluginRegistrant';

class TagCommand extends FaradayCommand {
  TagCommand() : super() {
    argParser.addOption('project');
    argParser.addFlag('release', defaultsTo: false);
    argParser.addOption('version', abbr: 'v', help: '版本号例如: 1.2.3+2391');
    argParser.addOption('static-file-server-address',
        abbr: 's', help: '文件服务器地址');
    argParser.addOption('repo-name', help: 'private spec repo');
  }

  @override
  String get description => '发布 pod 与 aar';

  @override
  String get name => 'tag';

  Shell get shell => _shell;
  Shell _shell;

  String get project => _project;
  String _project;

  Dio get dio => _dio;
  Dio _dio;

  String get repoName => _repoName;
  String _repoName;

  bool _release;
  bool get release => _release;
  String get mode => _release ? 'Release' : 'Debug';

  String get version => _version;
  String _version;

  YamlMap get pubspec => _pubspec;
  YamlMap _pubspec;

  @override
  Future run() async {
    _project = stringArg('project') ?? path.current;

    // 确定存在
    final pubspecFile = File(path.join(project, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      throwToolExit('flutter module not found');
    }

    _pubspec = loadYaml(pubspecFile.readAsStringSync());
    final module = _pubspec['flutter']['module'];
    if (module == null) throwToolExit('$project is not module project');

    final androidPackage = module['androidPackage'];

    _version = stringArg('version');
    if (version == null || version.isEmpty) throwToolExit('version not valid');

    _release = boolArg('release') ?? false;

    final fMap = _pubspec['faraday'];
    if (fMap == null) throwToolExit('请在 pubspec.yaml 中配置faraday节点相关参数');

    final address = stringArg('static-file-server-address') ??
        fMap['static_file_server_address'];
    _dio = Dio(BaseOptions(baseUrl: address));

    try {
      final test = await dio.get('/');
      if (test.statusCode != 200) {
        throwToolExit('static file server not reachable');
      }
    } catch (e) {
      throw ('文件服务器地址不正确 address => $address');
    }

    _shell = Shell(workingDirectory: project);

    _repoName = stringArg('repo-name') ?? fMap['faraday'];

    final repoList =
        (await shell.startAndReadAsString('pod', ['repo'])).split('\n');
    final index = repoList.indexWhere((r) => r.startsWith(repoName));
    if (index == -1) {
      throwToolExit('cocoapods repo-list $repoList not contain $repoName');
    }
    final _repoURL = repoList[index + 2].split(' ').last;

    // update debug message.
    final versionNumber = version.split('+').last;

    log.fine('Update debug message to lib/src/debug/debug.dart');
    final debugFile =
        File(path.join(shell.workingDirectory, 'lib/src/debug/debug.dart'))
          ..createSync(recursive: true);

    await debugFile.writeAsString(d_debug(versionNumber), mode: FileMode.write);

    log.fine('Clean workspace...');
    log.config(await shell.startAndReadAsString('flutter', ['clean']));

    log.config(await shell.startAndReadAsString('flutter', ['pub', 'get']));

    log.fine('Build android aar $version...');
    await shell.startAndReadAsString('flutter', [
      'build',
      'aar',
      '--build-number',
      version,
      '--no-pub',
      '--no-profile',
      release ? '--no-debug' : '--no-release'
    ]);

    log.config('Publish android aar...');
    final repo = Directory(path.join(project, 'build/host/outputs/repo'));
    try {
      for (final item in repo.listSync(followLinks: false, recursive: true)) {
        if (item.statSync().type != FileSystemEntityType.file) continue;
        final filePath = item.absolute.path;
        upload(filePath,
            filename: 'android-aar-' + filePath.split('outputs/').last);
      }
    } catch (e) {
      throwToolExit('Publish aar error: $e');
    }

    log.fine('Build ios-framework $version');
    await shell.startAndReadAsString('flutter', [
      'build',
      'ios-framework',
      '--no-pub',
      '--no-profile',
      release ? '--no-debug' : '--no-release',
      '--cocoapods',
    ]);

    log.config('Publish ios cocoapods...');
    final flutterPodName = 'Flutter$mode';
    // Flutter
    log.fine('Start process Flutter.Framework...');
    final flutterVersion = await processFlutterFramework();
    final dependencyFlutter =
        "   s.dependency '$flutterPodName', '$flutterVersion'";
    log.config(dependencyFlutter);

    // Plugins & PluginRegistrant
    log.fine('Start process Plugins...');
    final registrantVersion = await processPlugins(dependencyFlutter);

    // App
    log.fine('Start process App.framework...');
    final appName = await processAppFramework(registrantVersion);

    // 打印集成提示
    log.info('\nConsuming the Module:\n');
    log.info('''
For iOS Developer:
  1. Open <native-project>/Podfile
  2. Ensure you have the $repoName source configured, otherwise add this line: 

    source $_repoURL

  3. Make the host app depend on $appName pod

    pod '$appName', '~> $version', :configuration => ['$mode'], :inhibit_warnings => true


For Android Developer:
  1. Open <native-project>/app/build.gradle
  2. Ensure you have the repositories configured, otherwise add them:
      
      String storageUrl = System.env.FLUTTER_STORAGE_BASE_URL ?: "https://storage.googleapis.com"
      repositories {
        maven {
           url '${path.join(dio.options.baseUrl, 'android-aar-repo')}'
        }
        maven {
           url '\$storageUrl/download.flutter.io'
        }
      }

  3. Make the host app depend on the Flutter module:

    dependencies {
      ${mode.toLowerCase()}Implementation '$androidPackage:flutter_${mode.toLowerCase()}:1.0'
    }

''');
    log.config(_repoURL);
  }

  // return latest flutter version
  Future<String> processFlutterFramework() async {
    //
    final source =
        File(path.join(project, 'build/ios/framework', mode, 'Flutter.podspec'))
            .readAsStringSync();
    final regExp = RegExp(r"^\s+s.version\s+=\s+\'?.*\'", multiLine: true);
    final match = regExp.firstMatch(source);
    if (match == null) throwToolExit("Can't find flutter version");
    // 这里应该可以直接用正则 group出来
    final localVersion =
        source.substring(match.start, match.end - 1).split("'").last;

    log.config('Local flutter version: $localVersion');
    final podName = 'Flutter$mode';
    if (await podIsLatest(podName, localVersion)) {
      log.fine(podName + ': v$localVersion is Latest.');
      return localVersion;
    }

    // 需要上传新版 Flutter
    // 替换名字为 FlutterRelease 或者 FlutterDebug
    final newSource = source.replaceFirst(r'Flutter', podName);

    await _generateTempPodSpecFileAndPublish(newSource, podName);

    return localVersion;
  }

  // retrun FlutterPluginRegistrant latest version
  Future<String> processPlugins(String flutterDependency) async {
    final plugins = JSON
        .parse(File(path.join(project, '.flutter-plugins-dependencies'))
            .readAsStringSync())['plugins']['ios']
        .listValue
        .map((p) => p['name'].stringValue);

    log.config('plugins: ${plugins.join(',')}');

    // 除了 App.framework 其他的均不需要 每次都上传， 只需要判断版本不一致再上传
    YamlMap lock =
        loadYaml(File(path.join(project, 'pubspec.lock')).readAsStringSync());
    YamlMap packages = lock['packages'];

    final dependencies = <String, String>{};

    var hasNewPlugin = false;
    for (final plugin in plugins) {
      // 获取当前 pubspec version
      final lockVersion = packages[plugin]['version'];
      if (await publish(plugin, lockVersion)) {
        hasNewPlugin = true;
      }

      dependencies[plugin] = lockVersion;
    }

    if (hasNewPlugin) {
      // FlutterPluginRegistrant
      final buffer = StringBuffer();
      dependencies.forEach((k, v) {
        buffer.writeln("s.dependency '$k${release ? '' : mode}', '$v'");
      });
      buffer.writeln(flutterDependency);

      await processFlutterPluginRegistrant(buffer.toString());

      return version;
    }

    return await findPodLatestVersionInRepo(
        pluginRegistrant + (release ? '' : mode));
  }

  // return latest FlutterPluginRegistrant version
  void processFlutterPluginRegistrant(String dependency) async {
    //
    final podName = pluginRegistrant + (release ? '' : mode);
    final downloadSource =
        await _zipAndUpload(pluginRegistrant, podName, version);
    final specContent = _generatePluginPodspecContent(
        pluginRegistrant, podName, version, downloadSource,
        dependency: dependency);
    await _generateTempPodSpecFileAndPublish(specContent, podName);
  }

  Future<String> processAppFramework([String registrantVersion]) async {
    String podName = pubspec['name'] + (release ? '' : mode);

    await publish(
      'App',
      version,
      podName: podName.pascalCase,
      dependency:
          "s.dependency '$pluginRegistrant${release ? '' : mode}', '$registrantVersion'",
    );

    return podName.pascalCase;
  }

  //
  Future<bool> publish(String plugin, String lockVersion,
      {String dependency, String podName}) async {
    //
    podName ??= release ? plugin : '${plugin}Debug';

    if (await podIsLatest(podName, lockVersion)) {
      log.fine('plugin: $podName-v$lockVersion no need publish');
      return false;
    }

    // 上传 framework zip 文件到服务器
    final downloadURL = await _zipAndUpload(plugin, podName, lockVersion);
    // 'http://localhost:8000/g_faradayDebug/0.0.1/g_faraday.framework.zip';

    // 生成 podspec 内容
    final specContent = _generatePluginPodspecContent(
        plugin, podName, lockVersion, downloadURL,
        dependency: dependency);

    // 生成零时文件 上传 然后 删除
    await _generateTempPodSpecFileAndPublish(specContent, podName);

    return true;
  }

  Future<bool> podIsLatest(String podName, String lockVersion) async {
    final latestVersion = await findPodLatestVersionInRepo(podName);
    return latestVersion == lockVersion;
  }

  Future<String> findPodLatestVersionInRepo(String podName) async {
    // 获取最新的 pod info
    try {
      final podInfo = await shell.startAndReadAsString(
          'pod', ['search', '^$podName\$', '--simple', '--regex']);
      if (podInfo.contains('-> $podName (')) {
        final versionStr = podInfo.split('\n')[1].split(' ').last;
        final version = versionStr.substring(1, versionStr.length - 1);
        log.config('Remote $podName version: v$version');
        return version;
      }
    } catch (_) {}

    return null;
  }

  // 压缩framework并上传
  Future<String> _zipAndUpload(
      String name, String podName, String version) async {
    //
    shell.navigate(path.join(project, 'build/ios/framework/', mode));

    // zip
    await shell.startAndReadAsString(
        'zip', ['-r', '-1', '$name.framework.zip', '$name.framework']);

    // upload
    final filename = 'ios-frameworks/$podName/$version/$name.framework.zip';

    try {
      await upload(path.join(shell.workingDirectory, '$name.framework.zip'),
          filename: filename);
    } catch (e) {
      throwToolExit('upload $filename failed. $e');
    } finally {
      await shell.startAndReadAsString('rm', ['$name.framework.zip']);
    }

    shell.navigate(project);
    return path.join(dio.options.baseUrl, filename);
  }

  void upload(String file, {String filename}) async {
    final formData = FormData.fromMap(
        {'file': await MultipartFile.fromFile(file, filename: filename)});
    await dio.post('/', data: formData);
  }

  void _generateTempPodSpecFileAndPublish(
      String specContent, String podName) async {
    final podspecFileName = path.join(project, podName + '.podspec');
    File(podspecFileName)
        .writeAsStringSync(specContent, mode: FileMode.writeOnly);
    // 发布对应 podspec 文件
    await _publishPod(podspecFileName);
    // 删除对应 podspec 文件
    await shell.startAndReadAsString('rm', [podspecFileName]);
  }

  void _publishPod(String podspecFileName) async {
    // 发布对应 podspec 文件
    try {
      final r = await shell.startAndReadAsString('pod', [
        'repo',
        'push',
        repoName,
        podspecFileName,
        '--allow-warnings',
        '--skip-import-validation',
        '--no-ansi'
      ]);
      final info = r.split('\n').where((l) => l.isNotEmpty).toList();
      log.config(info.sublist(info.length - 2, info.length - 1).first);
    } catch (e) {
      throwToolExit('push $podspecFileName failed.  $e');
    }
  }

  String _generatePluginPodspecContent(
      String name, String podName, String version, String source,
      {String dependency}) {
    return '''
Pod::Spec.new do |s|
  s.authors      = "YuxiaorMobileTeam"
  s.name         = "$podName"
  s.version      = "$version"
  s.summary      = "Faraday iOS Artifacts."
  s.description  = "Yuxiaor Flutter components."
  s.homepage     = "https://github.com/YuxiaorMobileTeam"
  s.license      = { :type => "MIT", :text => "Copyright (C) 2022 Yuxiaor Faraday, Inc. All rights reserved."}
  s.author       = { "Yuxiaor" => "kevin@yuxiaor.com" }
  s.source       = { :http => '$source' }
  s.requires_arc = true  
  s.platform     = :ios
  s.ios.deployment_target = '8.0'
  s.vendored_frameworks = '$name.framework'
  s.frameworks = 'SystemConfiguration','Security'
  ${dependency ?? ''}
  s.library = 'z','c++'
  s.license      = {
    :type => 'Copyright',
    :text => <<-LICENSE
      Copyright (C) 2020 Yuxiaor Faraday, Inc. All rights reserved.
      LICENSE
  }
end
    ''';
  }
}
