import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'example_page_scaffold.dart';

class StatusBarColor extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<StatusBarColor> {
  var _isDark = false;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: ExamplePageScaffold(
        "Status Bar Color",
        children: [
          CupertinoButton(
            child: Text('chnage color'),
            onPressed: () {
              setState(() {
                _isDark = !_isDark;
              });
            },
          ),
        ],
      ),
    );
  }
}
