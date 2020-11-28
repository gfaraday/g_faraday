import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:g_faraday/g_faraday.dart';

import '../../../widgets/action.dart';
import '../../../widgets/section.dart';
import '../../example_page_scaffold.dart';

class Others extends StatefulWidget {
  @override
  _OthersState createState() => _OthersState();
}

class _OthersState extends State<Others> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 16),
      child: Section(
        title: '其他(Others)',
        subTitle: '其他一些有趣的小功能',
        child: Row(
          children: [
            Expanded(
              child: FaradayAction(
                color: Colors.teal,
                icon: Icon(Icons.wrap_text, color: Colors.white),
                description: '拦截返回',
                onTap: () => Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (_) => _WillPopPage())),
              ),
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: FaradayAction(
                color: Colors.blueAccent,
                icon: Icon(Icons.view_stream, color: Colors.white),
                description: Platform.isIOS ? 'iOS 自动处理导航条' : 'No Action',
                onTap: () {
                  if (Platform.isIOS) {
                    Navigator.of(context).nativePushNamed('navigationBar');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
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
          child: ExamplePageScaffold(
            'WillPopScope',
            children: [
              Text('当前页面拦截了返回，所以iOS不能滑动返回，android点返回键需要确认'),
              TextButton(
                  child: Text('需要确认: Navigator.of(context).maybePop()'),
                  onPressed: () => Navigator.of(context).maybePop()),
              TextButton(
                  child: Text('直接返回: Navigator.of(context).pop()'),
                  onPressed: () => Navigator.of(context).pop()),
            ],
          )),
    );
  }
}
