import 'package:flutter/cupertino.dart';

// ignore: public_member_api_docs
class FaradayPageRouteBuilder<T> extends PageRouteBuilder<T> {
  // ignore: public_member_api_docs
  FaradayPageRouteBuilder({
    RouteSettings settings,
    @required WidgetBuilder pageBuilder,
    // this.transitionsBuilder = _defaultTransitionsBuilder,
    // this.transitionDuration = const Duration(milliseconds: 300),
    // this.opaque = true,
    // this.barrierDismissible = false,
    // this.barrierColor,
    // this.barrierLabel,
  })  : assert(pageBuilder != null),
        super(
            transitionDuration: Duration(microseconds: 0),
            settings: settings,
            pageBuilder: (context, _, __) => pageBuilder(context),
            maintainState: false); // disab

  @override
  Future<RoutePopDisposition> willPop() {
    return Future.value(RoutePopDisposition.bubble);
  }
}
