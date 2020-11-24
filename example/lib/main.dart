import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:g_faraday/g_faraday.dart';
import 'package:g_faraday_example/src/pages/fragment_page.dart';

import 'src/pages/embedding_page.dart';
import 'src/pages/first_page.dart';
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
    'first_page': (RouteSettings settings) => CupertinoPageRoute(
        builder: (context) => FirstPage(0), settings: settings),
    'home': (RouteSettings settings) => CupertinoPageRoute(
        builder: (context) => HomePage(settings.arguments), settings: settings),
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
      switchPageAnimation: (currentRoute, {previousRoute}) {
        if (previousRoute != null &&
            currentRoute['route'] == previousRoute['route']) {
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
      // 你看到的红色的闪屏就是这个，如果你的应用背景不是 纯白/纯黑 那么你需要自定义这个颜色
      nativeContainerBackgroundColorProvider: (context) => Colors.red,
    );
    return CupertinoApp(
      onGenerateRoute: (_) => route,
    );
  }
}
