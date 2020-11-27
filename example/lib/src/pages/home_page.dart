import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/section.dart';
import 'features/basic/basic.dart';
import 'features/notification/notification.dart';
import 'features/other/other.dart';
import 'features/splash/splash.dart';

class HomePage extends StatefulWidget {
  final Map args;

  HomePage(this.args);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: WillPopScope(
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
              SliverToBoxAdapter(child: Others()),
              SliverToBoxAdapter(
                  child: Section(
                title: '高级功能(Advance)',
                subTitle: '以下是隐藏内容,请查看源码',
                //
                // 有什么你想要的功能没有看到，可以在 github 提 issue 我们会尽快加上哦
                //
                child: Container(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.scale(
                      scale: 0.6,
                      child: Image.asset('images/faraday.png'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Faraday',
                        style: TextStyle(color: CupertinoColors.secondaryLabel),
                      ),
                    )
                  ],
                )),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
