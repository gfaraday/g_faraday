// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';

class _FaradayEntry {
  final bool onlyFlutter;

  const _FaradayEntry({@required this.onlyFlutter});
}

const entry = _FaradayEntry(onlyFlutter: false);
const flutterEntry = _FaradayEntry(onlyFlutter: true);
