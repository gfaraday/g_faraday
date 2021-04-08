import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:g_faraday/g_faraday.dart';

import 'src/pages/features/basic/pages/flutter_to_flutter.dart';
import 'src/pages/features/basic/pages/native_to_flutter.dart';
import 'src/pages/features/basic/pages/tab_page.dart';
import 'src/pages/features/basic/pages/transparent_page.dart';
import 'src/pages/home_page.dart';
import 'src/utils/observer.dart';
import 'src/utils/simple_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, RouteFactory> routes = {
    'home': (settings) => CupertinoPageRoute(
        builder: (context) => HomePage(settings.arguments), settings: settings),
    'native2flutter': (settings) => CupertinoPageRoute(
        builder: (context) => Native2FlutterPage(settings.arguments),
        settings: settings),
    'flutter2flutter': (settings) => CupertinoPageRoute(
        builder: (context) => Flutter2Flutter(index: settings.toJson.index),
        settings: settings),
    'tab1': (settings) =>
        CupertinoPageRoute(builder: (context) => TabPage(), settings: settings),
    'transparent_flutter': (settings) => CupertinoPageRoute(
          builder: (context) => TransparentPage(),
          settings: settings,
        )
  };

  @override
  Widget build(BuildContext context) {
    final color = Color.fromARGB(255, 6, 210, 116);

    final route = faraday.wrapper(
      (settings) => routes[settings.name]?.call(settings),
      observers: [DemoObserver()],
      errorPage: _buildErrorPage,
      // switchPageAnimation: (currentRoute) {
      //   if (currentRoute['route'] == '') {
      //     return ((context, child) => AnimatedSwitcher(
      //           duration: Duration(seconds: 1),
      //           child: child,
      //           transitionBuilder: (child, animation) => RotationTransition(
      //             turns: animation,
      //             child: child,
      //           ),
      //         ));
      //   }
      //   return null;
      // },
      // flutter 自定义过渡页背景
      // nativeContainerBackgroundColorProvider: (context, {route}) =>
      //     CupertinoColors.secondarySystemBackground,
    );

    final cupertinoApp = CupertinoApp(
      localizationsDelegates: [
        S.delegate,
        DefaultCupertinoLocalizations.delegate
      ],
      supportedLocales: [
        Locale('en', ''),
        Locale.fromSubtags(languageCode: 'zh')
      ],
      theme: CupertinoThemeData(primaryColor: color),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (_) => route,
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Banner(
        location: BannerLocation.topEnd,
        message: 'faraday',
        color: color,
        textStyle: TextStyle(
          color: CupertinoColors.white,
          fontSize: 12 * 0.85,
          fontWeight: FontWeight.w900,
          height: 1.0,
        ),
        child: cupertinoApp,
      ),
    );
  }

  ///
  ///出错页面
  ///
  Widget _buildErrorPage(BuildContext context) {
    return GestureDetector(
      onTap: () => faraday.refresh(), //刷新
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: CupertinoColors.lightBackgroundGray,
        padding: EdgeInsets.only(left: 15.0, right: 15.0),
        alignment: Alignment.center,
        child: Text.rich(
          TextSpan(children: [
            TextSpan(
              text: '404',
              style: TextStyle(
                color: CupertinoColors.systemRed,
                fontSize: 64.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: '\n出错了,点击刷新',
              style: TextStyle(
                fontSize: 16.0,
                color: CupertinoColors.placeholderText,
              ),
            ),
          ]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
