import 'package:flutter/cupertino.dart';

/// Default not found page
class NotFoundPage extends StatefulWidget {
  ///
  final RouteSettings settings;

  ///
  NotFoundPage(this.settings);

  @override
  _NotFoundPage createState() => _NotFoundPage();
}

class _NotFoundPage extends State<NotFoundPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Default 404 Page'),
              Text('name: ${widget.settings.name}'),
              Text('arguments: ${widget.settings.arguments}'),
            ],
          ),
        ),
      ),
    );
  }
}
