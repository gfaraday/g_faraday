import 'package:flutter/cupertino.dart';
import 'package:g_faraday/g_faraday.dart';

import '../widgets/section.dart';
import 'features/basic/basic.dart';
import 'features/notification/notification.dart';
import 'features/splash/splash.dart';

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
    return WillPopScope(
      onWillPop: () async {
        final r = await showCupertinoDialog(
            builder: (ctx) => CupertinoAlertDialog(
                  content: Text('确定退出吗?'),
                  actions: [
                    CupertinoDialogAction(
                      child: Text('按错了'),
                      isDefaultAction: true,
                      onPressed: () => Navigator.of(ctx).pop(false),
                    ),
                    CupertinoDialogAction(
                      child: Text('退出'),
                      isDestructiveAction: true,
                      onPressed: () => Navigator.of(ctx).pop(true),
                    )
                  ],
                ),
            context: context);
        return r;
      },
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.secondarySystemBackground,
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            CupertinoSliverNavigationBar(
              backgroundColor: CupertinoColors.white,
              border: null,
              largeTitle: Text('Faraday功能演示'),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 100,
                color: CupertinoColors.white,
              ),
            ),
            SliverToBoxAdapter(child: Basic()),
            SliverToBoxAdapter(child: Splash()),
            SliverToBoxAdapter(child: GlobalNotification()),
            SliverToBoxAdapter(
                child: Section(
              title: '自定义SplashScreen',
              subTitle: '启动页 过渡页面配置',
              child: Container(
                height: 100,
                color: CupertinoColors.activeOrange,
              ),
              onTapViewAll: () {},
            )),
            SliverToBoxAdapter(
                child: Section(
              title: '自定义StatusBarColor',
              subTitle: 'ios android 状态栏配置',
              child: Container(
                height: 100,
                color: CupertinoColors.activeOrange,
              ),
              onTapViewAll: () {},
            )),
            SliverToBoxAdapter(
                child: Section(
              title: '自定义SplashScreen',
              subTitle: '启动页 过渡页面配置',
              child: Container(
                height: 100,
                color: CupertinoColors.activeOrange,
              ),
              onTapViewAll: () {},
            )),
            SliverToBoxAdapter(
                child: Section(
              title: '自定义SplashScreen',
              subTitle: '启动页 过渡页面配置',
              child: Container(
                height: 100,
                color: CupertinoColors.activeOrange,
              ),
              onTapViewAll: () {},
            )),
            SliverToBoxAdapter(
              child: SafeArea(
                top: false,
                child: Container(),
                minimum: EdgeInsets.only(bottom: 16),
              ),
            )
          ],
        ),
      ),
    );
  }

  ///
  /// 打开原生页面，并等待返回结果
  ///
  openNativeForResult() async {
    final result = await Navigator.of(context).nativePushNamed(
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
