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

  if (arguments.length == 1 && arguments.first == '--version') {
    print('1.0.0');
    return;
  }
  FaradayCommandRunner().run(arguments).then((v) => print(v));
}
