import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:g_faraday/g_faraday.dart';

class Flutter2NativePage extends StatefulWidget {
  @override
  _Flutter2NativePageState createState() => _Flutter2NativePageState();
}

class _Flutter2NativePageState extends State<Flutter2NativePage> {
  Object? _result;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Flutter to Native'),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                        await Navigator.of(context).pushNamed<Object?>(
                            'flutter2native',
                            arguments: {}));
                  }),
              if (_result != null)
                Text(
                  'result: $_result',
                  style: TextStyle(color: CupertinoColors.destructiveRed),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('''推荐使用🍎来打开native路由

注意事项

如果在flutter侧配置了RouteFactory onUnknownRoute或者flutter有重名路由那么在flutter侧查找路会返回true,这种case只能用🍎来打开native页面
                '''),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showResult(BuildContext context, Object? result) {
    setState(() {
      _result = result ?? 'NO RESULT';
    });
  }
}
