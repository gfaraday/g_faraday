import 'package:flutter/widgets.dart';

class FaradayDebugger extends StatefulWidget {
  @override
  _FaradayDebuggerState createState() => _FaradayDebuggerState();
}

class _FaradayDebuggerState extends State<FaradayDebugger> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text('Debugger'),
    );
  }
}
