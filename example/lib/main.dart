import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:g_faraday/g_faraday.dart';

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
  };

  @override
  Widget build(BuildContext context) {
    final route = faraday.wrapper((setttings) {
      final f = routes[setttings.name];
      if (f == null) return null;
      return f(setttings);
    });
    return CupertinoApp(
      onGenerateRoute: (_) => route,
    );
  }
}
