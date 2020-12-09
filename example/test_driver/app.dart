import 'package:flutter_driver/driver_extension.dart';
import 'package:g_faraday_example/main.dart' as app;

//
// https://cloud-trends.medium.com/how-to-fix-flutter-idevice-id-running-errors-in-mac-osx-catalina-7aa1f89f61aa
//
void main() {
  enableFlutterDriverExtension();

  app.main();
}
