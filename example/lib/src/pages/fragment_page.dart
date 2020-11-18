import 'package:flutter/cupertino.dart';
import 'package:g_faraday/g_faraday.dart';

///
///Flutter Fragment Example
///
class FragmentPage extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<FragmentPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Text("Flutter Fragment")),
            button(
              "Push New Flutter Page",
              pushNewFlutterPage,
            ),
          ],
        ),
      ),
    );
  }

  ///
  ///从一个Flutter Fragment中打开flutter页面
  ///
  void pushNewFlutterPage() {
    Navigator.of(context).nativePushNamed(
      'first_page',
      options: {'is_flutter_route': true},
    );
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
