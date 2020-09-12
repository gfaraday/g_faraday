import 'package:flutter/services.dart';

const MethodChannel _channel = const MethodChannel('g_faraday_helper/common');

class FaradayCommon {
  const FaradayCommon();

  static Future<T> invokeMethod<T>(String method, [dynamic arguments]) {
    return _channel.invokeMethod(method, arguments);
  }

  static Future<List<T>> invokeListMethod<T>(String method, [dynamic arguments]) async {
    final List<dynamic> result = await invokeMethod<List<dynamic>>(method, arguments);
    return result?.cast<T>();
  }

  static Future<Map<K, V>> invokeMapMethod<K, V>(String method, [dynamic arguments]) async {
    final Map<dynamic, dynamic> result = await invokeMethod<Map<dynamic, dynamic>>(method, arguments);
    return result?.cast<K, V>();
  }
}

const fc = FaradayCommon();
