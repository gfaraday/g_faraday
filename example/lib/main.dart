import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:g_faraday/g_faraday.dart';

import 'src/pages/embedding_page.dart';
import 'src/pages/features/basic/pages/flutter_to_flutter.dart';
import 'src/pages/features/basic/pages/native_to_flutter.dart';
import 'src/pages/features/basic/pages/tab_page.dart';
import 'src/pages/fragment_page.dart';
import 'src/pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, RouteFactory> routes = {
    'home': (settings) => CupertinoPageRoute(
        builder: (context) => HomePage(settings.arguments), settings: settings),
    'native2flutter': (settings) => CupertinoPageRoute(
        builder: (context) => Native2FlutterPage(settings.arguments),
        settings: settings),
    'flutter2flutter': (settings) => CupertinoPageRoute(
        builder: (context) => Flutter2Flutter(index: settings.toJson.index),
        settings: settings),
    'tab1': (settings) =>
        CupertinoPageRoute(builder: (context) => TabPage(), settings: settings),
    'flutter_tab_2': (RouteSettings settings) => CupertinoPageRoute(
        builder: (context) => HomePage(settings.arguments), settings: settings),
    'flutter_tab_1': (RouteSettings settings) => CupertinoPageRoute(
        builder: (context) => EmbeddingPage(0), settings: settings),
    'flutter_frag': (RouteSettings settings) =>
        CupertinoPageRoute(builder: (context) => FragmentPage()),
  };

  @override
  Widget build(BuildContext context) {
    final route = faraday.wrapper(
        (settings) {
          final f = routes[settings.name];
          if (f == null) return null;
          return f(settings);
        },
        onUnknownRoute: null,
        switchPageAnimation: (currentRoute) {
          if (currentRoute['route'] == '') {
            return (context, child) => AnimatedSwitcher(
                  duration: Duration(seconds: 1),
                  child: child,
                  transitionBuilder: (child, animation) => RotationTransition(
                    turns: animation,
                    child: child,
                  ),
                );
          }
          return null;
        },
        // flutter 自定义过渡页背景
        nativeContainerBackgroundColorProvider: (context, {route}) =>
            CupertinoColors.secondarySystemBackground);
    final cupertinoApp = CupertinoApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (_) => route,
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Banner(
        location: BannerLocation.topEnd,
        message: 'faraday',
        color: CupertinoColors.activeBlue,
        textStyle: TextStyle(
          color: CupertinoColors.white,
          fontSize: 12 * 0.85,
          fontWeight: FontWeight.w900,
          height: 1.0,
        ),
        child: cupertinoApp,
      ),
    );
  }
}
