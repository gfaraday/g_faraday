import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/simple_localizations.dart';
import '../widgets/section.dart';
import 'features/basic/basic.dart';
import 'features/notification/notification.dart';
import 'features/other/other.dart';
import 'features/splash/splash.dart';

class HomePage extends StatefulWidget {
  final dynamic args;

  const HomePage(this.args, {Key? key}) : super(key: key);

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
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          final r = await showCupertinoDialog(
              builder: (context) => CupertinoAlertDialog(
                    content: const Text('确定退出吗?'),
                    actions: [
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('按错了'),
                      ),
                      CupertinoDialogAction(
                        isDestructiveAction: true,
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('退出'),
                      )
                    ],
                  ),
              context: context);
          if (r) {
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop();
          }
        },
        child: CupertinoPageScaffold(
          backgroundColor: CupertinoColors.secondarySystemBackground,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
        largeTitle: Text(S.of(context).homeTitle),
      ),
      SliverPersistentHeader(
        delegate: HomePageBannerDelegate(),
        floating: false,
        pinned: false,
      ),
      const SliverToBoxAdapter(child: Basic()),
      const SliverToBoxAdapter(child: Splash()),
      const SliverToBoxAdapter(child: GlobalNotification()),
      const SliverToBoxAdapter(child: Others()),
      SliverToBoxAdapter(
        child: Section(
          title: S.of(context).advanceTitle,
          subTitle: S.of(context).advanceDescription,
          //
          // 有什么你想要的功能没有看到，可以在 github 提 issue 我们会尽快加上哦
          //
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: 0.6,
                child: Image.asset('images/faraday.png'),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Faraday',
                  style: TextStyle(color: CupertinoColors.secondaryLabel),
                ),
              )
            ],
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
      padding: const EdgeInsets.all(16),
      duration: const Duration(microseconds: 100),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('* ${S.of(context).homeTip1}'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('* ${S.of(context).homeTip2}'),
          ),
          Text('* ${S.of(context).homeTip3}',
              style: DefaultTextStyle.of(context)
                  .style
                  .apply(color: const Color(0xF0900000))),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 150;

  @override
  double get minExtent => 150;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
