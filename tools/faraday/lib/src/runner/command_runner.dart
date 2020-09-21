import 'package:args/command_runner.dart';

import '../commands/generate.dart';
import '../commands/auto_impl.dart';
import '../commands/tag.dart';
import '../commands/init.dart';
import '../commands/upgrade.dart';

class FaradayCommandRunner extends CommandRunner {
  FaradayCommandRunner() : super('faraday', 'g_faraday_scaffold cli.') {
    argParser.addFlag('verbose', abbr: 'v', negatable: false);

    addCommand(GenerateCommand());
    addCommand(AutoImplCommand());
    addCommand(TagCommand());
    addCommand(UpgradeCommand());
    addCommand(InitCommand());
  }
}
