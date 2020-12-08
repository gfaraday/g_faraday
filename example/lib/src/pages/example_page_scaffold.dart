import 'package:flutter/cupertino.dart';

class ExamplePageScaffold extends StatefulWidget {
  final String? title;
  final List<Widget>? children;

  const ExamplePageScaffold(this.title, {Key? key, this.children})
      : super(key: key);

  @override
  _ExamplePageScaffoldState createState() => _ExamplePageScaffoldState();
}

class _ExamplePageScaffoldState extends State<ExamplePageScaffold> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title ?? 'NoTitle'),
      ),
      child: SafeArea(
        minimum: EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.children!,
          ),
        ),
      ),
    );
  }
}
