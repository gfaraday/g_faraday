import 'package:flutter/cupertino.dart';

import 'first_page.dart';
import 'second_page.dart';

class HomePage extends StatefulWidget {
  final Map args;

  HomePage(this.args);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var info = "";

  @override
  void initState() {
    super.initState();
    info = "${widget.args}";
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            //拦截返回键
            showDialog(context);
            return Future.value(false);
          },
          child: Container(
            color: CupertinoColors.white,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(child: Text("Flutter Home Page")),
                button(
                  "pop with result",
                  () => Navigator.of(context).pop('[flutter pop with result]'),
                ),
                button(
                  "maybe pop",
                  () => Navigator.of(context).maybePop('result form maybe pop'),
                ),
                button(
                  "open Native,并等待返回数据",
                  () => openNativeForResult(),
                ),
                button(
                  "open Flutter",
                  () => Navigator.of(context).push(CupertinoPageRoute(
                    builder: (context) => FirstPage(-2),
                  )),
                ),
                button(
                  "open willscope flutter page",
                  () => Navigator.of(context)
                      .push(CupertinoPageRoute(
                          builder: (context) => SecondPage()))
                      .then((v) {
                    setState(() {
                      info += "$v \n";
                    });
                  }),
                ),
                SizedBox(height: 16),
                Text(info),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  /// 打开原生页面，并等待返回结果
  ///
  openNativeForResult() async {
    final result = await Navigator.of(context).pushNamed(
      "native://native_page_first",
      arguments: {'data': 'data form flutter home'},
    );

    info = info + "\n\n原生返回给Flutter的数据：\n$result";
    setState(() {});
  }

  Widget button(String text, VoidCallback callback) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      child: CupertinoButton(
        color: CupertinoColors.activeBlue,
        child: Text(
          text,
          style: TextStyle(fontSize: 14, color: CupertinoColors.white),
        ),
        onPressed: () => callback.call(),
      ),
    );
  }
}
