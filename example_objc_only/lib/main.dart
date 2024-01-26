import 'package:flutter/material.dart';
import 'package:g_faraday/g_faraday.dart';

void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatefulWidget {
  const DemoApp({super.key});

  @override
  DemoAppState createState() => DemoAppState();
}

class DemoAppState extends State<DemoApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (settings) => faraday.wrapper(
        (settings) => MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                child: const Text('pop'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
