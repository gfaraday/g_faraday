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
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        await showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
                  title: const Text('这里可以拦截返回'),
                  actions: [
                    CupertinoActionSheetAction(
                      onPressed: () {
                        final navigator = Navigator.of(context);
                        Future.microtask(() {
                          setState(() {
                            _opacity = 0.0;
                          });
                          navigator.pop(true);
                        });
                      },
                      child: const Text('返回'),
                    )
                  ],
                ));
        await Future.delayed(const Duration(milliseconds: 300));
        navigator.pop();
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
