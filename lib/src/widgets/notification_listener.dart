import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:g_json/g_json.dart';

import '../route/native_bridge.dart';
import 'log.dart';

///
const _notificationChannel = MethodChannel('g_faraday/notification');
var _notificationChannelEnabled = false;

final _notificationController =
    StreamController<FaradayNotification>.broadcast(onListen: () {
  log('_notificationController onlListened');
}, onCancel: () {
  log('_notificationController onCanceled', level: Level.WARNING);
});

StreamSubscription _observerNativeNotification(
    List<String> names, ValueChanged<FaradayNotification> onNotification) {
  return _notificationController.stream.listen((event) {
    if (names.contains(event.name)) onNotification(event);
  });
}

Future<bool> _handler(MethodCall call) {
  if (_notificationController.hasListener) {
    _notificationController.sink
        .add(FaradayNotification(call.method, call.arguments));
    return Future.value(true);
  }
  return Future.value(false);
}

/// FaradayNotification dispatched by native channel
class FaradayNotification {
  ///
  final String name;

  /// must encoding to json
  final dynamic arguments;

  ///
  FaradayNotification(this.name, [this.arguments])
      : assert(name.isNotEmpty),
        super();

  @override
  String toString() {
    if (kDebugMode) {
      return 'notification: $name: ${JSON(arguments).prettyString()}';
    }
    return super.toString();
  }

  /// 全局广播此通知
  void dispatchToGlobal({bool deliverToNative = true}) {
    if (_notificationController.hasListener) {
      _notificationController.sink.add(this);
    }
    if (deliverToNative) {
      _notificationChannel.invokeMethod(name, arguments);
    }
  }
}

// ignore: public_member_api_docs
typedef NotificationReceivedCallback = void Function(
    BuildContext? topMostContext, FaradayNotification value);

/// Receive native notification
class FaradayNotificationListener extends StatefulWidget {
  /// 想要监听的通知 名称数组
  /// 可以同时监听多个通知
  ///
  /// eg:
  ///
  /// ['ListUpdate', 'Logout']
  final List<String> names;

  ///
  final NotificationReceivedCallback onNotification;

  ///
  final Widget child;

  ///
  const FaradayNotificationListener(
    this.names, {
    Key? key,
    required this.onNotification,
    required this.child,
  }) : super(key: key);

  @override
  _FaradayNotificationListenerState createState() =>
      _FaradayNotificationListenerState();
}

class _FaradayNotificationListenerState
    extends State<FaradayNotificationListener> {
  StreamSubscription? _streamSubscription;

  @override
  void initState() {
    super.initState();
    if (!_notificationChannelEnabled) {
      _notificationChannel.setMethodCallHandler(_handler);
    }
    _streamSubscription = _observerNativeNotification(widget.names, (value) {
      final bridge = FaradayNativeBridge.of(context);
      widget.onNotification(bridge?.topNavigator?.currentContext, value);
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
