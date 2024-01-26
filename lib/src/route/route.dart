import 'package:flutter/cupertino.dart';

// ignore: public_member_api_docs
class FaradayPageRouteBuilder<T> extends PageRouteBuilder<T> {
  // ignore: public_member_api_docs
  FaradayPageRouteBuilder({
    super.settings,
    required WidgetBuilder pageBuilder,
  }) : super(
            transitionDuration: const Duration(microseconds: 0),
            pageBuilder: (context, _, __) => pageBuilder(context),
            maintainState: true);

  @override
  Future<RoutePopDisposition> willPop() {
    return Future.value(RoutePopDisposition.bubble);
  }
}
