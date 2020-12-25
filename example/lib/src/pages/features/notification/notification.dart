import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:g_faraday/g_faraday.dart';
import 'package:g_faraday_example/src/utils/simple_localizations.dart';

import '../../../widgets/action.dart';
import '../../../widgets/section.dart';

class GlobalNotification extends StatefulWidget {
  @override
  _GlobalNotificationState createState() => _GlobalNotificationState();
}

class _GlobalNotificationState extends State<GlobalNotification> {
  String? _localMessage;

  @override
  Widget build(BuildContext context) {
    return FaradayNotificationListener(
      ['NotificationFromNative'],
      onNotification: (value) {
        setState(() {
          _localMessage = value.arguments.toString();
        });
      },
      child: Padding(
        padding: EdgeInsets.only(right: 16),
        child: Section(
          title: S.of(context).notification,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FaradayAction(
                icon: Icon(
                  _localMessage == null
                      ? Icons.notifications
                      : Icons.notifications_active,
                  color: Colors.white,
                ),
                color: Colors.deepPurpleAccent,
                onTap: () {
                  setState(() {
                    _localMessage = null;
                    FaradayNotification('GlobalNotification')
                        .dispatchToGlobal();
                  });
                },
                description: 'Post Notification To Native',
              ),
              if (_localMessage != null)
                TweenAnimationBuilder(
                  duration: Duration(milliseconds: 300),
                  tween: Tween(begin: 5.0, end: 1.0),
                  builder: (context, dynamic value, child) =>
                      Transform.scale(scale: value, child: child),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _localMessage!,
                      style: TextStyle(color: Colors.purple[900]),
                      overflow: TextOverflow.fade,
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
