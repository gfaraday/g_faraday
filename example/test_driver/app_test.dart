import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main(List<String> args) {
  group('route', () {
    FlutterDriver? driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
      await driver?.waitUntilNoTransientCallbacks();
    });

    tearDownAll(() async {
      // driver?.close();
    });

    test('flutter to native', () async {
      final f2nFinder = find.byValueKey('flutter2native');
      await driver?.tap(f2nFinder);

      final pageFinder = find.byValueKey('flutter2native_page');
      final image = await driver?.screenshot();
    });
  });
}
