import 'package:flutter/cupertino.dart';

class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        //拦截返回键
        showDialog(context);
        return Future.value(false);
      },
      child: CupertinoPageScaffold(
          child: Center(
              child: CupertinoButton(
        child: Text("SecondPage"),
        onPressed: () => Navigator.of(context).maybePop(),
      ))),
    );
  }
}

showDialog(BuildContext context) {
  showCupertinoDialog(
    context: context,
    builder: (c) => Center(
      child: CupertinoButton.filled(
        child: Text("确认返回？"),
        onPressed: () {
          Navigator.of(c).pop();
          Navigator.of(context).pop('value from dialog');
        },
      ),
    ),
  );
}
