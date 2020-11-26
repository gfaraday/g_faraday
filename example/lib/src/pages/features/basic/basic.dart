import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../widgets/section.dart';
import 'pages/flutter_to_native.dart';

class Basic extends StatefulWidget {
  @override
  _BasicState createState() => _BasicState();
}

class _BasicState extends State<Basic> {
  @override
  Widget build(BuildContext context) {
    return Section(
      title: '基础',
      subTitle: '集成faraday的基础功能',
      onTapViewAll: () {},
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            _Action(
              title: '从Flutter跳转到Native页面',
              subTitle: 'ios: viewController android: activity',
              begin: _Action.flutter,
              end: _Action.native,
              onTap: () => Navigator.of(context).push(
                CupertinoPageRoute(builder: (_) => Flutter2NativePage()),
              ),
            ),
            Divider(height: 1),
            _Action(
              title: '从Native跳转到Flutter页面',
              subTitle: 'viewController activity fragment',
              begin: _Action.native,
              end: _Action.flutter,
              onTap: () {},
            ),
            Divider(height: 1),
            _Action(
              title: '从Flutter跳转到Flutter页面',
              subTitle: '支持在新的native容器打开',
              begin: _Action.flutter,
              end: _Action.flutter,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final String title;
  final String subTitle;
  final Widget begin;
  final Widget end;
  final VoidCallback onTap;

  const _Action({
    Key key,
    @required this.title,
    @required this.subTitle,
    @required this.begin,
    @required this.end,
    @required this.onTap,
  }) : super(key: key);

  static Widget get flutter => FlutterLogo();
  static Widget get native =>
      Icon(Icons.mobile_screen_share, color: CupertinoColors.activeBlue);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Wrap(
              direction: Axis.vertical,
              children: [
                Row(
                  children: [
                    begin,
                    Icon(
                      Icons.arrow_right_alt,
                      color: CupertinoColors.tertiaryLabel,
                    ),
                    end
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.black),
                ),
                Text(
                  subTitle,
                  style: TextStyle(
                      fontSize: 12, color: CupertinoColors.secondaryLabel),
                )
              ],
            ),
            Spacer(),
            Icon(
              CupertinoIcons.right_chevron,
              color: CupertinoColors.tertiaryLabel,
            )
          ],
        ),
      ),
    );
  }
}
