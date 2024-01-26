import 'package:flutter/material.dart';

class TabPage extends StatefulWidget {
  const TabPage({Key? key}) : super(key: key);

  @override
  _TabPageState createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
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
