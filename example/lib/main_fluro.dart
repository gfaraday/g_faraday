// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:g_faraday/g_faraday.dart';

import 'fluro_router.dart';
import 'src/utils/simple_localizations.dart';

void main(List<String> args) {
  defineRoutes(router);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final color = Color.fromARGB(255, 6, 210, 116);

    final route = faraday.wrapper(
      router.generator,
      switchPageAnimation: (currentRoute) {
        if (currentRoute['route'] == '') {
          return ((context, child) => AnimatedSwitcher(
                duration: Duration(seconds: 1),
                child: child,
                transitionBuilder: (child, animation) => RotationTransition(
                  turns: animation,
                  child: child,
                ),
              ));
        }
        return null;
      },
      // flutter 自定义过渡页背景
      nativeContainerBackgroundColorProvider: (context, {route}) =>
          CupertinoColors.secondarySystemBackground,
    );

    final cupertinoApp = CupertinoApp(
      localizationsDelegates: [
        S.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
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
}
