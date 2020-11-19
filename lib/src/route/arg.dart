// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';

import 'observer.dart';

class FaradayArguments {
  final GlobalKey key;
  final Object arguments;
  final String name;
  final int id;
  final observer = FaradayNavigatorObserver();

  FaradayArguments(this.arguments, this.name, this.id)
      : key = GlobalKey(debugLabel: 'id: $id');
}
