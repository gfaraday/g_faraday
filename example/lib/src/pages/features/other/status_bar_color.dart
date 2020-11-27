import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../example_page_scaffold.dart';

class StatusBarColorPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<StatusBarColorPage> {
  var _isDark = false;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: ExamplePageScaffold(
        "Status Bar Color",
        children: [
          TextButton(
              child: Text('Change StatusBar Color'),
              onPressed: () {
                setState(() {
                  _isDark = !_isDark;
                });
              })
        ],
      ),
    );
  }
}
