import 'dart:io';

import 'package:g_json/g_json.dart';
import 'package:path/path.dart' as p;

JSON _config;

JSON get config => _config;
void readConfig(String projectPath) {
  final _configFile = File(p.join(projectPath, '.faraday.json'));
  _config = _configFile.existsSync()
      ? JSON.parse(_configFile.readAsStringSync())
      : JSON.nil;
}
//

String get staticFileServer => config['static-file-server-address'].stringValue;

String get repoName => config['pod-repo-name'].stringValue;

// =============================================================================
