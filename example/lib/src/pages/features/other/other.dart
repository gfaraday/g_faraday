import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:g_faraday/g_faraday.dart';

import '../../../utils/simple_localizations.dart';
import '../../../widgets/action.dart';
import '../../../widgets/section.dart';
import '../../example_page_scaffold.dart';

class Others extends StatefulWidget {
  const Others({Key? key}) : super(key: key);

  @override
  _OthersState createState() => _OthersState();
}

class _OthersState extends State<Others> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Section(
        title: S.of(context).otherTitle,
        subTitle: S.of(context).otherDescription,
        child: Row(
          children: [
            Expanded(
              child: FaradayAction(
                color: Colors.teal,
                icon: const Icon(Icons.wrap_text, color: Colors.white),
                description: '拦截返回',
                onTap: () => Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (_) => _WillPopPage())),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: FaradayAction(
                color: Colors.blueAccent,
                icon: const Icon(Icons.view_stream, color: Colors.white),
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
      child: PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (didPop) return;

            final r = await showCupertinoDialog(
                builder: (context) => CupertinoAlertDialog(
                      content: const Text('确定退出吗?'),
                      actions: [
                        CupertinoDialogAction(
                          isDefaultAction: true,
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('按错了'),
                        ),
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('退出'),
                        )
                      ],
                    ),
                context: context);
            if (r) {
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
            }
          },
          child: ExamplePageScaffold(
            'WillPopScope',
            children: [
              const Text('当前页面拦截了返回，所以iOS不能滑动返回，android点返回键需要确认'),
              TextButton(
                  child: const Text('需要确认: Navigator.of(context)?.maybePop()'),
                  onPressed: () => Navigator.of(context).maybePop()),
              TextButton(
                  child: const Text('直接返回: Navigator.of(context)?.pop()'),
                  onPressed: () => Navigator.of(context).pop()),
            ],
          )),
    );
  }
}
