import 'package:flutter/services.dart';

const _channel = MethodChannel('g_faraday/net');

///
class FaradayNet {
  ///
  static Future request(String method, String url,
      {Map<String, dynamic> parameters, Map<String, dynamic> headers}) {
    return _channel.invokeMethod(method, {
      'url': url,
      if (parameters != null) 'parameters': parameters,
      if (headers != null) 'headers': headers
    });
  }
}
