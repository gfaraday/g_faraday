import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../faraday.dart';
import 'notification_listener.dart';

const _notificatioinName = '_faraday.navigator_anchor';
final _channel = MethodChannel('g_faraday/anchor');
final _anchors = <String>[];

Future<bool?> _removeAnchor(String identifier) {
  assert(_anchors.contains(identifier));
  _anchors.remove(identifier);
  return _channel.invokeMethod<bool>('removeAnchor', identifier);
}

Future<bool?> _addAnchor(String identifier) {
  assert(!_anchors.contains(identifier));
  _anchors.add(identifier);
  return _channel.invokeMethod<bool>('addAnchor', identifier);
}

Future<bool?> _replaceAnchor(String identifier, String oldIdentifier) {
  assert(_anchors.contains(oldIdentifier));
  _anchors.remove(oldIdentifier);
  assert(!_anchors.contains(identifier));
  _anchors.add(identifier);
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
  Future<bool?> popToAnchor(String identifier) async {
    if (!faraday.hasAnchorPoint(identifier)) return false;
    FaradayNotification(_notificatioinName, identifier)
        .dispatchToGlobal(deliverToNative: false);
    // 主要是为了等待 flutter侧的动画完成
    return Future.delayed(Duration(milliseconds: 300), () {
      return _channel.invokeMethod<bool>('popToAnchor', identifier);
    });
  }

  /// 是否存在某个锚点
  bool hasAnchorPoint(String identifier) {
    return _anchors.contains(identifier);
  }
}
