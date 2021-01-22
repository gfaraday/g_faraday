import 'dart:developer' as developer;

// ignore: public_member_api_docs
class Level {
  // ignore: public_member_api_docs
  final String name;

  /// Unique value for this level. Used to order levels, so filtering can
  /// exclude messages whose level is under certain value.
  final int value;

  // ignore: public_member_api_docs
  const Level(this.name, this.value);

  /// Key for static configuration messages ([value] = 700).
  // ignore: constant_identifier_names
  static const Level CONFIG = Level('CONFIG', 700);

  /// Key for informational messages ([value] = 800).
  // ignore: constant_identifier_names
  static const Level INFO = Level('INFO', 800);

  /// Key for potential problems ([value] = 900).
  // ignore: constant_identifier_names
  static const Level WARNING = Level('WARNING', 900);
}

// ignore: public_member_api_docs
void log(String message,
    {Level level = Level.CONFIG, String name = 'g_faraday'}) {
  assert(() {
    developer.log(
      message,
      level: level.value,
      name: name,
      time: DateTime.now(),
    );
    return true;
  }());
}
