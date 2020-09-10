import 'package:flutter/widgets.dart';

import 'observer.dart';

class FaradayArguments {
  final GlobalKey key;
  final Object arguments;
  final String name;
  final int seq;
  final observer = FaradayNavigatorObserver();

  FaradayArguments(callArguments, String name, this.seq)
      : key = GlobalKey(debugLabel: 'entry: $name'),
        arguments = callArguments,
        name = name;
}
