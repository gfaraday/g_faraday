import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TransparentPage extends StatefulWidget {
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
    return WillPopScope(
      onWillPop: () async {
        await showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
                  title: Text('这里可以拦截返回'),
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
                      child: Text('返回'),
                    )
                  ],
                ));
        return Future.microtask(
            () => Future.delayed(Duration(milliseconds: 300), () {
                  return true;
                }));
      },
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: Duration(milliseconds: 200),
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
