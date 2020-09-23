# Quick Start

混合项目中使用flutter开发的功能模块一般情况下相对独立。鉴于此faraday中定义了App的概念，每一组相似功能的独立页面都可以归属到一个`App`。 App的具体定义如下:
``` dart

// src/app/app.dart

abstract class App {
  App();
  // 应用描述
  String get description;

  // 应用名称
  String get name;

  // 应用开发者
  String get author;

  // 注册app中的所有页面
  Map<String, RouteFactory> get pageBuilders;
}

```

flutter端的开发从实现一个实现一个app开始, 例如我们实现一个 DemoApp 定义了以下页面

``` dart
  ...
  @override
  Map<String, RouteFactory> pageBuilders = {
    'demo_home': (settings) => CupertinoPageRoute(builder: (context) => Text('Demo page')),
    'demo_detail': (settings) => CupertinoPageRoute(builder: (context) => Text('Demo detail'))
  };

```
假设我们定义的 home 页面可以从`native`打开

``` dart

@common
static demoHome(String id) {
  
}

```