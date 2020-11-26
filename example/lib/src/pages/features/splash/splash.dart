import 'package:flutter/cupertino.dart';

import '../../../widgets/section.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return Section(
      title: '闪屏过渡页',
      subTitle: '解决各种闪屏、黑屏、白屏等疑难杂症',
      onTapViewAll: () {},
      child: Placeholder(
        fallbackHeight: 250,
      ),
    );
  }
}
