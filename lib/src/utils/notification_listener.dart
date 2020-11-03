import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../channel.dart';
import 'notification.dart';

final _notificationController =
    StreamController<FaradayNotification>.broadcast(onListen: () {
  debugPrint('_notificationController onlListened');
}, onCancel: () {
  debugPrint('_notificationController onCanceled');
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
  final ValueChanged<FaradayNotification> onNotification;

  ///
  final Widget child;

  ///
  const FaradayNotificationListener(
    this.names, {
    Key key,
    @required this.onNotification,
    @required this.child,
  })  : assert(child != null),
        assert(onNotification != null),
        super(key: key);

  @override
  _FaradayNotificationListenerState createState() =>
      _FaradayNotificationListenerState();
}

class _FaradayNotificationListenerState
    extends State<FaradayNotificationListener> {
  StreamSubscription _streamSubscription;

  @override
  void initState() {
    super.initState();
    if (!notification.checkMethodCallHandler(_handler)) {
      notification.setMethodCallHandler(_handler);
    }
    _streamSubscription = _observerNativeNotification(widget.names, (value) {
      widget.onNotification?.call(value);
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
