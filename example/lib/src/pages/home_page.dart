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
            slivers: _buildSlivers(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSlivers(BuildContext context) {
    return [
      CupertinoSliverNavigationBar(
        backgroundColor: CupertinoColors.white,
        border: null,
        largeTitle: Text('Faraday功能演示'),
      ),
      SliverPersistentHeader(
        delegate: HomePageBannerDelegate(),
        floating: false,
        pinned: false,
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
            ),
          ),
        ),
      ),
    ];
  }
}

class HomePageBannerDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return AnimatedContainer(
      padding: EdgeInsets.all(16),
      duration: Duration(microseconds: 100),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('* 右上角有绿色角标的均为 Flutter 页面'),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('* 所有功能在 iOS/Android 均可用'),
          ),
          Text('* 钉钉群号：35138694 🚀'),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 130;

  @override
  double get minExtent => 110;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
