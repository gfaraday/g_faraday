import 'package:g_json/g_json.dart';

///
class Options {
  final JSON _raw;

  /// raw options
  Map<String, dynamic> get raw => _raw.mapObject ?? {};

  ///
  Options([Map<String, dynamic>? value]) : _raw = JSON(value ?? {});

  /// enable/disable animation
  factory Options.animated() =>
      Options()..add(key: '_faraday.animated', value: true);

  /// show container with/without present
  factory Options.present() =>
      Options()..add(key: '_faraday.present', value: true);

  /// is flutter route
  factory Options.flutterRoute() =>
      Options()..add(key: '_faraday.flutter', value: true);

  /// add more options
  void add({required String key, required dynamic value}) {
    _raw[key] = value;
  }
}
