import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:g_faraday/g_faraday.dart';

// SimpleLocalizations
class S {
  S(this.locale);

  final Locale locale;

  static SimpleLocalizationsDelegate delegate = SimpleLocalizationsDelegate();

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static final JSON _localizedValues = JSON({
    'en': {
      'homeTitle': 'Faraday Features Demo',
    },
    'zh': {
      'homeTitle': 'Farday功能演示',
    },
  });

  JSON get _values => _localizedValues[locale.languageCode];

  String get homeTitle {
    return _values['homeTitle'].stringValue;
  }
}

class SimpleLocalizationsDelegate extends LocalizationsDelegate<S> {
  const SimpleLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(S(locale));
  }

  @override
  bool shouldReload(SimpleLocalizationsDelegate old) => false;
}
