import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: public_member_api_docs
class Section extends StatelessWidget {
  final String title;
  final String? subTitle;
  final Widget child;
  final VoidCallback? onTapViewAll;

  const Section({
    Key? key,
    required this.title,
    this.subTitle,
    this.onTapViewAll,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    if (subTitle != null)
                      Text(
                        subTitle!,
                        style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.secondaryLabel),
                      )
                  ],
                ),
                Spacer(),
                if (onTapViewAll != null)
                  CupertinoButton(
                    onPressed: onTapViewAll,
                    child: Text('查看全部', style: TextStyle(fontSize: 14)),
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
              ],
            ),
          ),
          child,
          Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Divider(),
          )
        ],
      ),
    );
  }
}
