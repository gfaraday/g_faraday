import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../widgets/action.dart';
import '../../../widgets/section.dart';

class Others extends StatefulWidget {
  @override
  _OthersState createState() => _OthersState();
}

class _OthersState extends State<Others> {
  @override
  Widget build(BuildContext context) {
    return Section(
        title: '其他(Others)',
        subTitle: '其他一些有趣的小功能',
        child: Row(
          children: [
            Expanded(
              child: FaradayAction(
                color: Colors.teal,
                icon: Icon(Icons.wrap_text, color: Colors.white),
                description: '拦截返回',
                onTap: () => {},
              ),
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: FaradayAction(
                color: Colors.blueAccent,
                icon: Icon(Icons.view_stream, color: Colors.white),
                description: 'iOS 自动处理导航条',
                onTap: () => {},
              ),
            ),
          ],
        ));
  }
}

class _WillPopPage extends StatefulWidget {
  @override
  __WillPopPageState createState() => __WillPopPageState();
}

class __WillPopPageState extends State<_WillPopPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: WillPopScope(
        onWillPop: () async {
          final r = await showCupertinoDialog(
              builder: (ctx) => CupertinoAlertDialog(
                    content: Text('确定退出吗?'),
                    actions: [
                      CupertinoDialogAction(
                        child: Text('按错了'),
                        isDefaultAction: true,
                        onPressed: () => Navigator.of(ctx).pop(false),
                      ),
                      CupertinoDialogAction(
                        child: Text('退出'),
                        isDestructiveAction: true,
                        onPressed: () => Navigator.of(ctx).pop(true),
                      )
                    ],
                  ),
              context: context);
          return r;
        },
        child: Center(
          child: Text(''),
        ),
      ),
    );
  }
}
