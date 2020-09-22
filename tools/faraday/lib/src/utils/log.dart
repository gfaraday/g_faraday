import 'package:ansicolor/ansicolor.dart';
import 'package:logging/logging.dart';

final finePen = AnsiPen()..xterm(15);
final configPen = AnsiPen()..xterm(212);
final infoPen = AnsiPen()..xterm(10);
final warningPen = AnsiPen()..xterm(11);
final severePen = AnsiPen()..xterm(1);

void recordAnsiLog(LogRecord record) {
  // record.level).call('${record.time} ${record.loggerName}-${record.level.name}:
  print(_penForlevel(record.level).call(record.message));
}

AnsiPen _penForlevel(Level l) {
  if (l == Level.SEVERE) {
    return severePen;
  } else if (l == Level.WARNING) {
    return warningPen;
  } else if (l == Level.INFO) {
    return infoPen;
  } else if (l == Level.CONFIG) {
    return configPen;
  } else {
    return finePen;
  }
}
