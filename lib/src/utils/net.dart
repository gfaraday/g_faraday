import 'package:flutter/services.dart';

const MethodChannel _channel = const MethodChannel('g_faraday_helper/net');

class FaradayNet {
  static Future<Map<String, dynamic>> request(dynamic arguments) {
    return _channel.invokeMapMethod<String, dynamic>('request', arguments);
  }
}
