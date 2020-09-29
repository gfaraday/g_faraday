// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';

import 'observer.dart';

class FaradayArguments {
  final GlobalKey key;
  final Object arguments;
  final String name;
  final int seq;
  final observer = FaradayNavigatorObserver();

  FaradayArguments(this.arguments, this.name, this.seq)
      : key = GlobalKey(debugLabel: 'entry: $name');
}
