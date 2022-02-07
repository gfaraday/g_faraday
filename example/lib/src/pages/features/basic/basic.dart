import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:g_faraday/g_faraday.dart';

import '../../../utils/simple_localizations.dart';
import '../../../widgets/section.dart';
import 'pages/flutter_to_flutter.dart';
import 'pages/flutter_to_native.dart';

class Basic extends StatefulWidget {
  @override
  _BasicState createState() => _BasicState();
}

class _BasicState extends State<Basic> {
  @override
  Widget build(BuildContext context) {
    return Section(
      title: S.of(context).basicTitle,
      subTitle: S.of(context).basicDescription,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: _buildActions(context, onlyBase: false),
        ),
      ),
    );
  }
}

class BasicAllPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.secondarySystemBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text('All Basics'),
      ),
      child: SafeArea(
        child: Center(
          child: ListView(
            physics: AlwaysScrollableScrollPhysics(),
            children: [
              Container(
                margin: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: _buildActions(context, onlyBase: false),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

List<Widget> _buildActions(BuildContext context, {bool onlyBase = true}) {
  final base = [
    _Action(
      title: S.of(context).basicFlutter2Native,
      subTitle: 'ios: viewController android: activity',
      begin: _Action.flutter,
      end: _Action.native,
      onTap: () => Navigator.of(context).push(
        CupertinoPageRoute(builder: (_) => Flutter2NativePage()),
      ),
    ),
    Divider(height: 1),
    _Action(
      title: S.of(context).basicNative2Flutter,
      subTitle: 'viewController activity fragment',
      begin: _Action.native,
      end: _Action.flutter,
      onTap: () => Navigator.of(context).nativePushNamed('native2flutter'),
    ),
    Divider(height: 1),
    _Action(
      title: S.of(context).basicFlutter2Flutter,
      subTitle: S.of(context).basicFlutter2FlutterDescription,
      begin: _Action.flutter,
      end: _Action.flutter,
      onTap: () {
        // Get.toNamed("/Flutter2Flutter");

        Navigator.of(context).push(
          CupertinoPageRoute(builder: (_) => Flutter2Flutter()),
        );
      },
    ),
  ];
  if (onlyBase) return base;
  return [
    ...base,
    Divider(height: 1),
    _Action(
      title: S.of(context).basicChild,
      subTitle: S.of(context).basicChildDescription,
      begin: _Action.flutter,
      end: Icon(Icons.widgets),
      onTap: () => Navigator.of(context).nativePushNamed('tabContainer'),
    ),
  ];
}

class _Action extends StatelessWidget {
  final String title;
  final String subTitle;
  final Widget begin;
  final Widget end;
  final VoidCallback onTap;

  const _Action({
    Key? key,
    required this.title,
    required this.subTitle,
    required this.begin,
    required this.end,
    required this.onTap,
  }) : super(key: key);

  static Widget get flutter => FlutterLogo();
  static Widget get native =>
      Icon(Icons.mobile_screen_share, color: CupertinoColors.activeBlue);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Wrap(
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
                    maxLines: 2,
                    style: TextStyle(
                        fontSize: 12, color: CupertinoColors.secondaryLabel),
                  )
                ],
              ),
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
