import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../widgets/section.dart';
import '../../example_page_scaffold.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

enum _Platform { ios, android, fluter }

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return Section(
      title: '闪屏过渡页',
      subTitle: '解决各种闪屏、黑屏、白屏等疑难杂症',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ..._Platform.values.map((p) {
            final text = p == _Platform.ios
                ? 'iOS'
                : _Platform.android == p
                    ? 'Android'
                    : 'Flutter';

            return OutlineButton(
              child: Text(text),
              textColor: _Platform.ios == p
                  ? Colors.black
                  : _Platform.android == p
                      ? Colors.green[800]
                      : Colors.blue,
              onPressed: () => Navigator.of(context).push(CupertinoPageRoute(
                  builder: (_) => SplashTipPage(p, title: text),
                  fullscreenDialog: true)),
            );
          })
        ],
      ),
    );
  }
}

class SplashTipPage extends StatefulWidget {
  final String title;
  final _Platform platform;

  const SplashTipPage(this.platform, {Key key, this.title}) : super(key: key);

  @override
  _SplashTipPageState createState() => _SplashTipPageState();
}

class _SplashTipPageState extends State<SplashTipPage> {
  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      widget.title,
      children: _Platform.ios == widget.platform
          ? _buildIOSTip(context)
          : _Platform.android == widget.platform
              ? _buildAndroidTip(context)
              : _buildFlutterTip(context),
    );
  }

  // 这个大写 IOS 很难受
  List<Widget> _buildIOSTip(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('iOS过渡页只需要设置ViewController的`splashScreenView`即可'),
      ),
      TextButton(
          child: Text('查看`HomeFlutterViewController.swift`'), onPressed: () {})
    ];
  }

  List<Widget> _buildAndroidTip(BuildContext context) {
    return [
      Text('一共有3种方式，根据需求自己选择'),
      Text('1. 设置 Intent Builder的backgroundColor'),
      TextButton(child: Text('查看 CustomRoute.kt'), onPressed: () {}),
      Text('2. manifest 中配置对应Activity的 meta data'),
      TextButton(child: Text('查看 AndroidManifest'), onPressed: () {}),
      Text('3. 继承FaradayActivity然后实现 provideSplashScreen'),
      TextButton(child: Text('查看 FaradayActivity.kt'), onPressed: () {}),
    ];
  }

  List<Widget> _buildFlutterTip(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Flutter的过渡页逻辑最为简单'),
      ),
      Text('在页面内容尚未渲染完成时，用户会看到容器背景，只需要根据特定逻辑返回一个颜色值即可'),
      TextButton(
          child: Text('查看`main.dart`->`faraday.wrapper'), onPressed: () {})
    ];
  }
}
