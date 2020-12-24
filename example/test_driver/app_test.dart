import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:g_faraday_example/main.dart' as app;
// ignore: import_of_legacy_library_into_null_safe
import 'package:integration_test/integration_test.dart';

void main(List<String> args) {
  group('route', () {
    setUpAll(() async {
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    });

    testWidgets('flutter to native', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final f2nFinder = find.byKey(ValueKey('flutter2native'));
      await tester.tap(f2nFinder);
    });

    // test('flutter to native', () async {
    //   final f2nFinder = find.byValueKey('flutter2native');
    //   await driver?.tap(f2nFinder);

    //   final pageFinder = find.byValueKey('flutter2native_page');
    //   final image = await driver?.screenshot();
    // });
  });
}
