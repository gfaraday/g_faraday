import 'package:args/command_runner.dart';
import 'package:logging/logging.dart';

abstract class FaradayCommand extends Command {
  Logger _log;
  Logger get log => _log ??= Logger(name.toUpperCase());

  /// Gets the parsed command-line option named [name] as `bool`.
  bool boolArg(String name) => argResults[name] as bool;

  /// Gets the parsed command-line option named [name] as `String`.
  String stringArg(String name) => argResults[name] as String;

  /// Gets the parsed command-line option named [name] as `List<String>`.
  List<String> stringsArg(String name) => argResults[name] as List<String>;
}
