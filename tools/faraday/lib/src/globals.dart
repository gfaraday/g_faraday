import 'dart:io';

import 'package:g_json/g_json.dart';

final _configFile = File('.faraday.json');
final _config = _configFile.existsSync()
    ? JSON.parse(_configFile.readAsStringSync())
    : JSON.nil;

JSON get config => _config;

//
String get projectRooPath => config['porject'].stringValue;

String get staticFileServer => config['static-file-server-address'].stringValue;

String get repoName => config['pod-repo-name'].stringValue;

// =============================================================================
