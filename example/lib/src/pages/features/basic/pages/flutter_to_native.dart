import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:g_faraday/g_faraday.dart';
import 'package:markdown/markdown.dart' as md;

class Flutter2NativePage extends StatefulWidget {
  @override
  _Flutter2NativePageState createState() => _Flutter2NativePageState();
}

class _Flutter2NativePageState extends State<Flutter2NativePage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Flutter to Native'),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('支持🍎和🍐两种方式打开'),
              ),
              TextButton(
                  child: Text('🍎: Navigator.of(context).nativePushNamed'),
                  onPressed: () async {
                    _showResult(
                        context,
                        await Navigator.of(context)
                            .nativePushNamed('flutter2native', arguments: {}));
                  }),
              TextButton(
                  child: Text('🍐: Navigator.of(context).pushNamed'),
                  onPressed: () async {
                    _showResult(
                        context,
                        await Navigator.of(context)
                            .pushNamed('flutter2native', arguments: {}));
                  }),
              Markdown(
                extensionSet: md.ExtensionSet(
                  md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                  [
                    md.EmojiSyntax(),
                    ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
                  ],
                ),
                data: '''
## **推荐使用🍎来打开native路由**

**注意事项**

* 🍐会先尝试在`flutter`侧寻找对应路由，如果找不到再去native打开
* 如果在`flutter`侧配置了`RouteFactory onUnknownRoute`或者flutter和native有重名路由那么在flutter侧查找路会返回true，
这种case只能用🍎来打开native页面
''',
                shrinkWrap: true,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showResult(BuildContext context, Object result) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Result from native'),
        content: Text('$result'),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }
}
