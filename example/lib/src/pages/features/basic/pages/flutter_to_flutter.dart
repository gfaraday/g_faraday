import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:g_faraday/g_faraday.dart';

class Flutter2Flutter extends StatefulWidget {
  final int? index;

  const Flutter2Flutter({Key? key, this.index}) : super(key: key);

  @override
  _Flutter2FlutterState createState() => _Flutter2FlutterState();
}

class _Flutter2FlutterState extends State<Flutter2Flutter> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Flutter to Flutter ${widget.index ?? 0}'),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    'Flutter 页面之间的跳转和纯flutter项目没有任何区别， navigator的所有api均可使用'),
              ),
              TextButton(
                child: Text('Open New Flutter Page'),
                onPressed: () => Navigator.of(context)!.push(
                  CupertinoPageRoute(
                      builder: (_) => Flutter2Flutter(
                            index: (widget.index ?? 0) + 1,
                          )),
                ),
              ),
              TextButton(
                child: Text('Open New Flutter By New Container'),
                onPressed: () => Navigator.of(context)!.nativePushNamed(
                    'flutter2flutter',
                    arguments: {'index': (widget.index ?? 1) * -1},
                    options: {'flutter': true}),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
