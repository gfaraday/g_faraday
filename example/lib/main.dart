import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:g_faraday/g_faraday.dart';

import 'pages/embedding_page.dart';
import 'pages/first_page.dart';
import 'pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      onGenerateRoute: route([DemoApp()]),
    );
  }
}

class DemoApp extends App {
  @override
  String get author => 'faraday';

  @override
  String get description => 'g_faraday demo app';

  @override
  String get name => 'demo';

  @override
  Map<String, RouteFactory> pageBuilders = {
    '/demo_first_page': (RouteSettings settings) => CupertinoPageRoute(
        builder: (context) => FirstPage(0), settings: settings),
    '/demo_home': (RouteSettings settings) => CupertinoPageRoute(
        builder: (context) => HomePage(settings.arguments), settings: settings),
    '/demo_flutter_tab_1': (RouteSettings settings) => CupertinoPageRoute(
        builder: (context) => EmbeddingPage(0), settings: settings),
  };
}
