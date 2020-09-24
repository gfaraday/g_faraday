import 'package:flutter/widgets.dart';

import 'notification.dart';

typedef FaradayNotificationListenerCallback = void Function(dynamic);

class FaradayNotificationListener
    extends NotificationListener<FaradayNotification> {
  final String name;

  FaradayNotificationListener(this.name,
      {Key key,
      @required Widget child,
      FaradayNotificationListenerCallback onNotification})
      : assert(name != null && name.isNotEmpty),
        super(
            key: key,
            child: child,
            onNotification: (n) {
              if (n.name == name && onNotification != null) {
                onNotification(n.arguments);
                return true;
              }
              return false;
            });
}
