// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';

const _channel = MethodChannel('g_faraday/common');

class FaradayCommon {
  const FaradayCommon();

  static Future<T> invokeMethod<T>(String method, [dynamic arguments]) {
    return _channel.invokeMethod(method, arguments);
  }
}

// decorate class
const common = FaradayCommon();

class _FaradayCommonIgnoreMethod {
  const _FaradayCommonIgnoreMethod();
}

// decorate method
const ignore = _FaradayCommonIgnoreMethod();
