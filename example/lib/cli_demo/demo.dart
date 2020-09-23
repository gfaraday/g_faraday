import 'package:flutter/cupertino.dart';
import 'package:g_faraday/g_faraday.dart';
import 'package:g_json/g_json.dart';

class DemoApp extends App {
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

  /// document commnets
  /// will be
  /// send
  /// to native
  @common
  static getSomeData(String id, {bool optionalArg}) {
    return FaradayCommon.invokeMethod('cli_demo/demo.dart|DemoApp#getSomeData',
            {'id': id, if (optionalArg != null) 'optionalArg': optionalArg})
        .then((r) => JSON(r));
  }

  @common
  static showLoading(String message) {}

  @common
  static setSomeData(dynamic data, {@required String id}) {}

  @entry
  static demoHome(BuildContext context) {
    return Navigator.of(context).pushNamedFromNative('demo_home');
  }

  @entry
  static demoHome1(BuildContext context, String id) {
    return Navigator.of(context).pushNamedFromNative('demo_home1');
  }

  @entry
  static demoHome2(BuildContext context, String name) {
    return Navigator.of(context).pushNamedFromNative('demo_home2');
  }

  /// comments open demo home
  @entry
  static demoHome3() {}
}
