import 'package:flutter/cupertino.dart';
import 'package:g_faraday/g_faraday.dart';

import 'second_page.dart';

class FirstPage extends StatefulWidget {
  final int value;

  FirstPage(this.value);

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  int c;

  @override
  void initState() {
    c = widget.value ?? -1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Plugin example app'),
      ),
      child: WillPopScope(
        onWillPop: () {
          showDialog(context);
          return Future.value(false);
        },
        child: SafeArea(
          child: Container(
            child: Center(
              child: Column(children: [
                Text('value: $c'),
                CupertinoButton.filled(
                  child: Text('replace with native'),
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed('native://native_page_first')
                      .then((r) => showResult(r)),
                ),
                CupertinoButton(
                  child: Text('push native'),
                  onPressed: () => Navigator.of(context)
                      .pushNamed('native://native_page_first')
                      .then((r) => showResult(r)),
                ),
                CupertinoButton.filled(
                  child: Text('push'),
                  onPressed: () => Navigator.of(context)
                      .push(CupertinoPageRoute(
                          builder: (context) => FirstPage(c + 1)))
                      .then((r) => showResult(r)),
                ),
                CupertinoButton(
                    child: Text('pop'),
                    onPressed: () => Navigator.of(context).pop('pop flutter')),
                CupertinoButton.filled(
                    child: Text('popAndPush'),
                    onPressed: () => Navigator.of(context).popAndPushNamed(
                        'home',
                        result: 'pop popAndPushNamed')),
                CupertinoButton(
                    child: Text('pop to native'),
                    onPressed: () => Navigator.of(context)
                        .popUntilNative(context, 'pop popUntilNative'))
              ]),
            ),
          ),
        ),
      ),
    );
  }

  showResult(result) {
    showCupertinoDialog(
      context: context,
      builder: (context) => Container(
        child: Center(
          child: Text('result: $result'),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
