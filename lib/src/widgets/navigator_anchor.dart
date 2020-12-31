import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../faraday.dart';
import 'notification_listener.dart';

const _notificatioinName = '_faraday.navigator_anchor';
final _channel = MethodChannel('g_faraday/anchor');

Future<bool?> _removeAnchor(String identifier) {
  return _channel.invokeMethod<bool>('removeAnchor', identifier);
}

Future<bool?> _addAnchor(String identifier) {
  return _channel.invokeMethod<bool>('addAnchor', identifier);
}

Future<bool?> _replaceAnchor(String identifier, String oldIdentifier) {
  return _channel.invokeMethod<bool>(
      'replaceAnchor', {'id': identifier, 'oldID': oldIdentifier});
}

Future<bool?> _handler(MethodCall call) async {
  if (call.method != 'popToAnchor') return false;
  return faraday.popToAnchor(call.arguments);
}

/// 跨页面返回锚点
class FaradayNavigatorAnchor extends StatefulWidget {
  ///
  final Widget child;

  /// 锚点唯一标志
  final String identifier;

  ///
  FaradayNavigatorAnchor({
    required this.child,
    required this.identifier,
    Key? key,
  }) : super(key: key);

  @override
  _FaradayNavigatorAnchorState createState() => _FaradayNavigatorAnchorState();
}

class _FaradayNavigatorAnchorState extends State<FaradayNavigatorAnchor> {
  @override
  void initState() {
    super.initState();
    _addAnchor(widget.identifier);
    if (!_channel.checkMethodCallHandler(_handler)) {
      _channel.setMethodCallHandler(_handler);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FaradayNotificationListener(
      [_notificatioinName],
      onNotification: (tc, notification) {
        if (notification.name != _notificatioinName ||
            notification.arguments != widget.identifier) return;

        final mr = ModalRoute.of(context);
        Navigator.of(context)?.popUntil((route) => route == mr);
      },
      child: widget.child,
    );
  }

  @override
  void didUpdateWidget(covariant FaradayNavigatorAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.identifier != oldWidget.identifier) {
      _replaceAnchor(widget.identifier, oldWidget.identifier);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _removeAnchor(widget.identifier);
  }
}

// ignore: public_member_api_docs
extension NavigatorAnchorFaraday on Faraday {
  /// 跳转到指定锚点
  Future<bool?> popToAnchor(String identifer) async {
    FaradayNotification(_notificatioinName, identifer)
        .dispatchToGlobal(deliverToNative: false);
    // 主要是为了等待 flutter侧的动画完成
    return Future.delayed(Duration(milliseconds: 300), () {
      return _channel.invokeMethod<bool>('popToAnchor', identifer);
    });
  }
}
