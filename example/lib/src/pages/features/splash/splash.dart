import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../utils/simple_localizations.dart';
import '../../../widgets/section.dart';
import '../../example_page_scaffold.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

enum _Platform { ios, android, fluter }

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return Section(
      title: S.of(context).splashTitle,
      subTitle: S.of(context).splashDescription,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ..._Platform.values.map((p) {
            final text = p == _Platform.ios
                ? 'iOS'
                : _Platform.android == p
                    ? 'Android'
                    : 'Flutter';

            return CupertinoButton(
              child: Text(text,
                  style: TextStyle(
                    color: _Platform.ios == p
                        ? Colors.black
                        : _Platform.android == p
                            ? Colors.green[800]
                            : Colors.blue,
                  )),
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
  final String? title;
  final _Platform platform;

  const SplashTipPage(this.platform, {Key? key, this.title}) : super(key: key);

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
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('iOS过渡页只需要设置ViewController的`splashScreenView`即可'),
      ),
      TextButton(
          child: const Text('查看`HomeFlutterViewController.swift`'),
          onPressed: () {})
    ];
  }

  List<Widget> _buildAndroidTip(BuildContext context) {
    return [
      const Text('一共有3种方式，根据需求自己选择'),
      const Text('1. 设置 Intent Builder的backgroundColor'),
      TextButton(child: const Text('查看 CustomRoute.kt'), onPressed: () {}),
      const Text('2. manifest 中配置对应Activity的 meta data'),
      TextButton(child: const Text('查看 AndroidManifest'), onPressed: () {}),
      const Text('3. 继承FaradayActivity然后实现 provideSplashScreen'),
      TextButton(child: const Text('查看 FaradayActivity.kt'), onPressed: () {}),
    ];
  }

  List<Widget> _buildFlutterTip(BuildContext context) {
    return [
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('Flutter的过渡页逻辑最为简单'),
      ),
      const Text('在页面内容尚未渲染完成时，用户会看到容器背景，只需要根据特定逻辑返回一个颜色值即可'),
      TextButton(
          child: const Text('查看`main.dart`->`faraday.wrapper'),
          onPressed: () {})
    ];
  }
}
