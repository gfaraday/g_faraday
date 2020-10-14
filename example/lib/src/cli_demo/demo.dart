import 'package:flutter/cupertino.dart';
import 'package:g_faraday/g_faraday.dart';
import 'package:g_json/g_json.dart';

class DemoApp extends Feature {
  @override
  String get author => 'gix.gong';

  @override
  String get description => 'faraday demo app';

  @override
  String get name => 'demo';

  @override
  Map<String, RouteFactory> pageBuilders = {
    'demo_home': (settings) => CupertinoPageRoute(
          builder: (context) => Text('Demo page'),
        )
  };

  /// document commnets will be show on native methods
  /// get some data from native
  @common
  static getSomeData(String id, {bool optionalArg}) {
    return FaradayCommon.invokeMethod('cli_demo/demo.dart|DemoApp#getSomeData',
            {'id': id, if (optionalArg != null) 'optionalArg': optionalArg})
        .then((r) => JSON(r));
  }

  /// entry
  @entry
  static demoHome(BuildContext context) {
    return Navigator.of(context).nativePushNamed('demo_home');
  }

  static postUser(dynamic user) {
    return FaradayNet.request('post', '');
  }
}

class Home extends Feature {
  @override
  String get name => 'Home';

  @override
  Map<String, RouteFactory> get pageBuilders => {
        'Home_home': (settings) =>
            CupertinoPageRoute(builder: (context) => Text('Home')),
      };

  // common method
  @common
  static getData(int id) {}

  // entry
  @entry
  static homeHome() {}

  // api
  fetchUser(String id) {}
}
