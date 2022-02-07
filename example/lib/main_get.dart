// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:g_faraday/g_faraday.dart';
// import 'package:get/get.dart';

// import 'src/pages/features/basic/pages/flutter_to_flutter.dart';
// import 'src/pages/features/basic/pages/native_to_flutter.dart';
// import 'src/pages/features/basic/pages/tab_page.dart';
// import 'src/pages/features/basic/pages/transparent_page.dart';
// import 'src/pages/home_page.dart';
// import 'src/utils/simple_localizations.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   Map<String, RouteFactory> routes = {
//     'home': (settings) => CupertinoPageRoute(
//         builder: (context) => HomePage(settings.arguments), settings: settings),
//     'native2flutter': (settings) => CupertinoPageRoute(
//         builder: (context) => Native2FlutterPage(settings.arguments),
//         settings: settings),
//     'flutter2flutter': (settings) => CupertinoPageRoute(
//         builder: (context) => Flutter2Flutter(index: settings.toJson.index),
//         settings: settings),
//     'tab1': (settings) =>
//         CupertinoPageRoute(builder: (context) => TabPage(), settings: settings),
//     'transparent_flutter': (settings) => CupertinoPageRoute(
//           builder: (context) => TransparentPage(),
//           settings: settings,
//         )
//   };

//   List<GetPage> getPages = [
//     // GetPage(name: '/', page: () => HomePage({})),
//     GetPage(name: '/Home', page: () => HomePage({})),
//     GetPage(name: '/Flutter2Flutter', page: () => Flutter2Flutter()),
//   ];

//   @override
//   void initState() {
//     super.initState();

//     Get.addPages(getPages);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final color = Color.fromARGB(255, 6, 210, 116);

//     final route = faraday.wrapper(
//       (settings) {
//         if (getPages.indexWhere((element) => element.name == settings.name) >
//             -1) {
//           print("TAG GetX Route settings ${settings.toString()}");
//           return PageRedirect(settings, null).page();
//         }

//         final f = routes[settings.name!];
//         if (f == null) return null;
//         return f(settings);
//       },
//       switchPageAnimation: (currentRoute) {
//         if (currentRoute['route'] == '') {
//           return ((context, child) => AnimatedSwitcher(
//                 duration: Duration(seconds: 1),
//                 child: child,
//                 transitionBuilder: (child, animation) => RotationTransition(
//                   turns: animation,
//                   child: child,
//                 ),
//               ));
//         }
//         return null;
//       },
//       // flutter 自定义过渡页背景
//       nativeContainerBackgroundColorProvider: (context, {route}) =>
//           CupertinoColors.secondarySystemBackground,
//       navigatorKeyCallback: (key, id) {
//         print("TAG navigatorKeyCallback key $key id $id");

//         /// 添加进去 GetX 的 GlobalKey 组合，方便根据 id 切换 Navigator
//         Get.keys.putIfAbsent(
//           id,
//           () => key as GlobalKey<NavigatorState>,
//         );

//         /// 添加最顶层 Navigator 作为 GetX 默认的 Navigator
//         Get.addKey(key as GlobalKey<NavigatorState>);
//       },
//       faradayNavigatorParentBuilder: (child) =>
//           ScreenUtilInit(designSize: Size(750, 1334), builder: () => child),
//     );

//     final cupertinoApp = GetCupertinoApp(
//       localizationsDelegates: [
//         S.delegate,
//       ],
//       supportedLocales: [
//         Locale('en', ''),
//         Locale.fromSubtags(languageCode: 'zh')
//       ],
//       theme: CupertinoThemeData(primaryColor: color),
//       debugShowCheckedModeBanner: false,
//       onGenerateRoute: (_) => route,
//     );

//     return Directionality(
//       textDirection: TextDirection.ltr,
//       child: Banner(
//         location: BannerLocation.topEnd,
//         message: 'faraday',
//         color: color,
//         textStyle: TextStyle(
//           color: CupertinoColors.white,
//           fontSize: 12 * 0.85,
//           fontWeight: FontWeight.w900,
//           height: 1.0,
//         ),
//         child: cupertinoApp,
//       ),
//     );
//   }
// }
