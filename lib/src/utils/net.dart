import 'package:flutter/services.dart';

const MethodChannel _channel = const MethodChannel('g_faraday_helper/net');

class FaradayNet {
  final String method;
  const FaradayNet(this.method);

  static Future<Map<String, dynamic>> request(dynamic arguments) {
    return _channel.invokeMapMethod<String, dynamic>('request', arguments);
  }
}

const get = FaradayNet('GET');
const post = FaradayNet('POST');
const put = FaradayNet('PUT');
const delete = FaradayNet('DELETE');
const request = FaradayNet('REQUEST');

class Body {
  const Body();
}

const body = Body();

class Query {
  const Query();
}

const query = Query();
