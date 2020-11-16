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
      onWillPop: () async {
        //拦截返回键
        final result = await showDialog(context);
        return Future.value(result != null);
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
  return showCupertinoDialog(
    context: context,
    useRootNavigator: false,
    builder: (ctx) => Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CupertinoButton.filled(
          child: Text("返回"),
          onPressed: () {
            Navigator.of(ctx).pop('value from dialog');
          },
        ),
        CupertinoButton.filled(
          child: Text("不返回"),
          onPressed: () {
            Navigator.of(ctx).pop();
          },
        ),
      ],
    )),
  );
}
