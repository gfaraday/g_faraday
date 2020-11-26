import 'package:flutter/cupertino.dart';

import '../../../widgets/section.dart';

class GlobalNotification extends StatefulWidget {
  @override
  _GlobalNotificationState createState() => _GlobalNotificationState();
}

class _GlobalNotificationState extends State<GlobalNotification> {
  @override
  Widget build(BuildContext context) {
    return Section(
      title: '通知(GlobalNotification)',
      onTapViewAll: () {},
      child: Placeholder(
        fallbackHeight: 100,
      ),
    );
  }
}
