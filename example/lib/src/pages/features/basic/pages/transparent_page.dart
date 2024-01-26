import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TransparentPage extends StatefulWidget {
  const TransparentPage({Key? key}) : super(key: key);

  @override
  _TransparentPageState createState() => _TransparentPageState();
}

class _TransparentPageState extends State<TransparentPage>
    with SingleTickerProviderStateMixin {
  var _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    Future.microtask(
      () => setState(() {
        _opacity = 0.5;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
                  title: const Text('这里可以拦截返回'),
                  actions: [
                    CupertinoActionSheetAction(
                      onPressed: () {
                        Future.microtask(() {
                          setState(() {
                            _opacity = 0.0;
                          });
                          Navigator.of(context).pop(true);
                        });
                      },
                      child: const Text('返回'),
                    )
                  ],
                ));
        Future.delayed(const Duration(milliseconds: 300), () {
          Navigator.of(context).pop();
        });
      },
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          child: Container(
            color: Colors.black,
          ),
          onTap: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}
