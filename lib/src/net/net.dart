import 'package:flutter/services.dart';

const MethodChannel _channel = const MethodChannel('g_faraday_helper/net');

class FaradayNet {
  static Future request(dynamic arguments) {
    return _channel.invokeMapMethod<String, dynamic>('request', arguments);
  }

  static Future get(String url, {Map<String, dynamic> query, additions}) {
    return _channel.invokeMapMethod<String, dynamic>('get', {
      url: url,
      if (query != null) 'query': query,
      if (additions != null) 'additions': additions
    });
  }

  static Future post(String url,
      {Map<String, dynamic> query, Map<String, dynamic> body, additions}) {
    return _channel.invokeMapMethod<String, dynamic>('post', {
      url: url,
      if (query != null) 'query': query,
      if (body != null) "body": body,
      if (additions != null) 'additions': additions
    });
  }

  static Future put(String url,
      {Map<String, dynamic> query, Map<String, dynamic> body, additions}) {
    return _channel.invokeMapMethod<String, dynamic>('put', {
      url: url,
      if (query != null) 'query': query,
      if (body != null) "body": body,
      if (additions != null) 'additions': additions
    });
  }

  static Future delete(String url, {Map<String, dynamic> query, additions}) {
    return _channel.invokeMapMethod<String, dynamic>('delete', {
      url: url,
      if (query != null) 'query': query,
      if (additions != null) 'additions': additions
    });
  }
}
