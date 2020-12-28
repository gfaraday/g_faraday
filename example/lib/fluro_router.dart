// ignore: import_of_legacy_library_into_null_safe
import 'package:fluro/fluro.dart';
import 'package:g_faraday/g_faraday.dart';

import 'src/pages/features/basic/pages/flutter_to_flutter.dart';
import 'src/pages/features/basic/pages/native_to_flutter.dart';
import 'src/pages/features/basic/pages/tab_page.dart';
import 'src/pages/features/basic/pages/transparent_page.dart';
import 'src/pages/home_page.dart';

final router = FluroRouter();

void defineRoutes(FluroRouter router) {
  router.define('home',
      handler: Handler(handlerFunc: (context, params) => HomePage(params)));
  router.define('native2flutter',
      handler: Handler(
          handlerFunc: (context, params) => Native2FlutterPage(params)));
  router.define('flutter2flutter',
      handler: Handler(
          handlerFunc: (context, params) =>
              Flutter2Flutter(index: JSON(params)['index'].integer)));
  router.define('tab1',
      handler: Handler(handlerFunc: (context, params) => TabPage()));
  router.define('transparent_flutter',
      handler: Handler(handlerFunc: (context, params) => TransparentPage()));
}
