import 'package:flutter/cupertino.dart';
import 'package:g_faraday/g_faraday.dart';

class EmbeddingPage extends StatefulWidget {
  final int value;

  EmbeddingPage(this.value);

  @override
  _EmbeddingPageState createState() => _EmbeddingPageState();
}

class _EmbeddingPageState extends State<EmbeddingPage> {
  int value;

  @override
  void initState() {
    value = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: Wrap(
            runSpacing: 8.0,
            spacing: 8.0,
            children: [
              ...List.generate(
                20,
                (_) => CupertinoButton.filled(
                    child: Text('$value'),
                    onPressed: () {
                      setState(() {
                        value += 2;
                      });
                      Navigator.of(context).nativePushNamed('tab', present: false);
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
