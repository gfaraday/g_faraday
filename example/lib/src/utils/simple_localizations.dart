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
      'home': {
        'title': 'Faraday Features Demo',
        'tip1': 'All flutter page has faraday banner on rightTop',
        'tip2': 'All feature available on ios&android',
        'tip3': 'Debug Mode will show an error page. it is expected.'
      },
      'basic': {
        'title': 'Basic(基础)',
        'description': 'Supported basic route features',
        'f2n': 'flutter page open to native page',
        'n2f': 'native page push flutter route',
        'f2f': 'flutter open new flutter route',
        'f2f_d': 'Supported open flutter route in new container',
        'fc': 'show flutter page in `ChildContainer`',
        'fc_d': 'flutter page in tab'
      },
      'splash': {
        'title': 'Splash Screen (闪屏过渡页)',
        'description': 'Resolve ALL, Splash Issues',
      },
      'notification': 'Global Notification(通知)',
      'other': {
        'title': 'Others(其他)',
        'description': 'Some helpers',
      },
      'advance': {
        'title': 'Advance(高级功能)',
        'description': 'Browse source code, finding advance features🚀',
      }
    },
    'zh': {
      'home': {
        'title': 'Faraday功能演示',
        'tip1': '右上角有绿色角标的均为 Flutter 页面',
        'tip2': '所有功能在 iOS/Android 均可用',
        'tip3': 'Debug模式第一次打开Flutter页面时出现一闪而过的红屏是正常的'
      },
      'basic': {
        'title': '基础(Basic)',
        'description': '集成faraday的基础功能',
        'f2n': '从Flutter跳转到Native页面',
        'n2f': '从Flutter跳转到Flutter页面',
        'f2f': '从Flutter跳转到Flutter页面',
        'f2f_d': '支持在新的native容器打开',
        'fc': '将Flutter作为子页面引入`',
        'fc_d': '在native容器中作为tab添加flutter页面'
      },
      'splash': {
        'title': '闪屏过渡页(Splash Screen)',
        'description': '解决各种闪屏、黑屏、白屏等疑难杂症',
      },
      'notification': '通知(Global Notification)',
      'other': {
        'title': '其他(Others)',
        'description': '其他一些有趣的小功能',
      },
      'advance': {
        'title': '高级功能(Advance)',
        'description': '以下是隐藏内容,请查看源码',
      }
    },
  });

  String get otherTitle => _values['other']['title'].stringValue;
  String get otherDescription => _values['other']['description'].stringValue;

  String get splashTitle => _values['splash']['title'].stringValue;
  String get splashDescription => _values['splash']['description'].stringValue;

  String get notification => _values['notification'].stringValue;

  String get advanceTitle => _values['advance']['title'].stringValue;
  String get advanceDescription =>
      _values['advance']['description'].stringValue;

  JSON get _values => _localizedValues[locale.languageCode];

  String get homeTitle => _values[['home', 'title']].stringValue;
  String get homeTip1 => _values[['home', 'tip1']].stringValue;
  String get homeTip2 => _values[['home', 'tip2']].stringValue;
  String get homeTip3 => _values[['home', 'tip3']].stringValue;

  String get basicTitle => _values[['basic', 'title']].stringValue;
  String get basicDescription => _values[['basic', 'description']].stringValue;
  String get basicFlutter2Native => _values[['basic', 'f2n']].stringValue;
  String get basicNative2Flutter => _values[['basic', 'n2f']].stringValue;
  String get basicFlutter2Flutter => _values[['basic', 'f2f']].stringValue;
  String get basicFlutter2FlutterDescription =>
      _values[['basic', 'f2f_d']].stringValue;
  String get basicChild => _values[['basic', 'fc']].stringValue;
  String get basicChildDescription => _values[['basic', 'fc_d']].stringValue;
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
