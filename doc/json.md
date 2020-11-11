# JSON

json在我们日常开发中已经变的非常重要了，用来传递数据可读性非常的好。我们将对json的处理单独剥离出来成为一个独立的`package`:

[https://pub.dev/packages/g_json](https://pub.dev/packages/g_json)

同时我们在`faraday`中也提供了以下扩展方法

``` dart

extension RouteSettingsFaraday on RouteSettings {
  ///
  /// eg:
  /// final arg = settings.toJson;
  /// final id = arg.id;
  /// final name = arg.name;
  /// final types = arg.types;
  ///
  dynamic get toJson => JSON(arguments);
}
```

在使用`RouteSettings`来创建页面的时候可以很方便的读取参数
