import 'package:flutter/services.dart';

const MethodChannel _channel = const MethodChannel('g_faraday_helper/common');

class FaradayCommon {
  const FaradayCommon();

  static Future<T> invokeMethod<T>(String method, [dynamic arguments]) {
    return _channel.invokeMethod(method, arguments);
  }
}

const common = FaradayCommon();
