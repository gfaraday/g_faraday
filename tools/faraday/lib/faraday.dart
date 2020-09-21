library faraday;

import 'package:faraday/src/utils/log.dart';
import 'package:logging/logging.dart';

import 'src/runner/command_runner.dart';

const commonAnnotation = ['common'];
const routeAnnotation = ['entry'];

final log = Logger('faraday');

void main(List<String> arguments) {
  // final verbose = arguments.contains('-v') || arguments.contains('--verbose');

  // append logger
  Logger.root.onRecord.listen(recordAnsiLog);
  Logger.root.level = Level.ALL; //verbose ? Level.ALL : Level.INFO;

  FaradayCommandRunner().run(arguments).then((v) => print(v));
}
