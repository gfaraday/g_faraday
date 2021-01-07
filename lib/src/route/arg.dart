// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:g_json/g_json.dart';

import 'navigator.dart';
import 'observer.dart';

class FaradayArguments {
  final GlobalKey<FaradayNavigatorState> key;
  final Object arguments;
  final String name;
  final int id;
  final bool opaque;
  final observer = FaradayNavigatorObserver();

  FaradayArguments(this.arguments, this.name, this.id, {this.opaque = true})
      : key = GlobalKey(debugLabel: 'id: $id');

  JSON get info => JSON({
        'route': name,
        'opaque': opaque,
        if (arguments != null) 'arguments': arguments
      });
}
