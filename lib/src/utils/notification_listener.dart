import 'package:flutter/widgets.dart';

import 'notification.dart';

/// Receive native notification
class FaradayNotificationListener
    extends NotificationListener<FaradayNotification> {
  ///
  final String name;

  ///
  FaradayNotificationListener(this.name,
      {Key key,
      @required Widget child,
      NotificationListenerCallback<FaradayNotification> onNotification})
      : assert(name != null && name.isNotEmpty),
        super(
            key: key,
            child: child,
            onNotification: (n) {
              if (n.name == name && onNotification != null) {
                return onNotification(n.arguments);
              }
              return false;
            });
}
