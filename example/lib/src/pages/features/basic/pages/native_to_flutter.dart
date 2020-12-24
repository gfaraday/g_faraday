import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Native2FlutterPage extends StatefulWidget {
  final dynamic date;

  const Native2FlutterPage(this.date, {Key? key}) : super(key: key);

  @override
  _Native2FlutterPageState createState() => _Native2FlutterPageState();
}

class _Native2FlutterPageState extends State<Native2FlutterPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Native2Flutter'),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.date ?? 'No Date'),
              TextButton(
                child: Text('带参数返回'),
                onPressed: () =>
                    Navigator.of(context).pop('Result From Flutter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
