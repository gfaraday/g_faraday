import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:g_faraday/g_faraday.dart';

import '../../../widgets/action.dart';
import '../../../widgets/section.dart';

class GlobalNotification extends StatefulWidget {
  @override
  _GlobalNotificationState createState() => _GlobalNotificationState();
}

class _GlobalNotificationState extends State<GlobalNotification> {
  String _localMessage;

  @override
  Widget build(BuildContext context) {
    return FaradayNotificationListener(
      ['NotificationFromNative'],
      onNotification: (value) {
        setState(() {
          _localMessage = value.arguments.toString();
        });
      },
      child: Section(
        title: '通知(GlobalNotification)',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FaradayAction(
              icon: Icon(
                  _localMessage != null
                      ? Icons.notifications_active
                      : Icons.notifications,
                  color: Colors.white),
              color: Colors.deepPurpleAccent,
              onTap: () =>
                  FaradayNotification('GlobalNotification').dispatchToGlobal(),
              description: 'Post Notification To Native',
            ),
            if (_localMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _localMessage,
                  style: TextStyle(color: Colors.grey),
                  overflow: TextOverflow.fade,
                ),
              )
          ],
        ),
      ),
    );
  }
}
