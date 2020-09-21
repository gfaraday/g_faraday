import 'dart:convert';
import 'dart:io';

import 'package:faraday/src/commands/command.dart';

class UpgradeCommand extends FaradayCommand {
  @override
  String get description => 'upgrade faraday cli version';

  @override
  String get name => 'upgrade';

  @override
  String run() {
    var isFlutterDart = true;

    if (Platform.isWindows) {
      var process = Process.runSync('where', ['faraday'], runInShell: true);

      isFlutterDart =
          process.stdout.toString().contains('flutter\\.pub-cache\\bin\\faraday');
    } else {
      var process = Process.runSync('which', ['faraday'], runInShell: true);
      isFlutterDart =
          process.stdout.toString().contains('flutter/.pub-cache/bin/faraday');
    }

    if (isFlutterDart) {
      log.config('Upgrade in Flutter Dart VM');
      Process.runSync('flutter', ['pub', 'global', 'activate', 'faraday'],
          runInShell: true);
    } else {
      log.config('Upgrade in Dart VM');
      Process.runSync('pub', ['global', 'activate', 'faraday'], runInShell: true);
    }

    var process = Process.runSync('faraday', ['-v'],
        runInShell: true, stdoutEncoding: utf8);
    log.info(process.stdout);

    return process.stdout;
  }
}
