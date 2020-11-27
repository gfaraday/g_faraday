import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TabPage extends StatefulWidget {
  @override
  _TabPageState createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlutterLogo(
            style: FlutterLogoStyle.stacked,
          ),
          SizedBox(height: 20),
          Text('Hello guy, This is Flutter Tab'),
        ],
      ),
    );
  }
}
