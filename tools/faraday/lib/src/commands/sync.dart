import 'package:faraday/src/commands/command.dart';


class SyncCommand extends FaradayCommand {
  @override
  String get description => '同步flutter与native的路由及common定义';

  @override
  String get name => 'sync';

  @override
  String run() {

  }
}
