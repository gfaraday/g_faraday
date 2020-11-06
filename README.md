# faraday

![Platform](https://img.shields.io/badge/platform-ios%7Candroid-green)
![Language](https://img.shields.io/badge/language-dart%7Cswift%7Ckotlin-lightgrey)

一个`Flutter`混合开发解决方案

## Features

- [x] `iOS/Android` 原生页面堆栈与`Flutter Navigator`无缝桥接
- [x] 支持所有`Navigator`特性
- [x] [页面间回调](docs/callback.md)
- [x] [`iOS`导航条自动隐藏/显示](docs/ios_navigation_bar.md)
- [x] `WillPopScope`拦截滑动返回或者返回键返回事件
- [x] [发送/接收全局通知](docs/notification.md)
- [ ] 监听页面生命周期
- [ ] 文档

## Requirements
- Flutter 1.22.3
- iOS 10.0+ Xcode 12.0+ Swift 5.1+
- Android minSdkVersion 16 Kotlin 1.4.10+

## 设计原则

- 对原有平台最小侵入
- 对现有代码最小改动
- API尽量保持和原有平台一致

## 更新策略

**`Flutter stable channel`发布后一周内适配发布对应的`g_faraday`版本**

## 快速开始

如果您已经有其他类似的框架开发经验，可以直接查看[Example](example/)浏览最佳实践。

### 添加依赖

``` yaml
dependencies:
  # 请确认依赖与本地Flutter兼容的版本
  g_faraday: ^0.4.0
```

### Flutter 端集成

flutter侧的集成工作，主要是注册需要从原生打开的页面。

``` dart

// 0x00 定义 route factory
final routeGenerator = (_) => faraday.wrapper(
          (settings) {
            //
            if (settings.name == 'first_page')
              return CupertinoPageRoute(
                  builder: (context) => FirstPage(settings: settings);
            //
            if (settings.name == 'second_page')
              return CupertinoPageRoute(
                  builder: (context) => SecondPage(settings: settings);
            return null;
          },
        );

// 0x01 将 route generator 赋给你的app widget
CupertinoApp(onGenerateRoute: routeGenerator);

// 0x02 flutter 侧集成完毕，接下来你可以选择 集成iOS/Android
```

### iOS 集成

混合应用肯定会存在从`Flutter`端打开原生页面的应用场景，所以我们需要实现一个打开原生页面的protocol

``` swift

// 0x00 实现 `FaradayNavigationDelegate`
extension AppDelegate: FaradayNavigationDelegate {
    
    func push(_ name: String, arguments: Any?, options: [String : Any]?) -> UIViewController? {
        
        let isFlutter = options?["flutter"] as? Bool ?? false
        let isPresent = options?["present"] as? Bool ?? false
        
        let vc = isFlutter ? FaradayFlutterViewController(name, arguments: arguments) : FirstViewController(name， arguments: arguments)
        
        let topMost = UIViewController.fa.topMost
        if (isPresent) {
            topMost?.present(vc, animated: true, completion: nil)
        } else {
            topMost?.navigationController?.pushViewController(vc, animated: true)
        }
        
        return vc
    }
}

// 0x01 在 `application: didFinishLaunchingWithOptions`中启动flutter engine
Faraday.sharedInstance.startFlutterEngine(navigatorDelegate: self)


// 0x02 打开一个flutter 页面
let vc = FaradayFlutterViewController("first_page", arguments: nil)
navigationController?.pushViewController(vc, animated: true)

// 0x03 集成完毕
```
### Android 集成

## 混合开发会遇到哪些问题？

### 关于开发人员
引入flutter以后开发人员的角色会有一下三种
>
> - ios/android 纯native开发
> - 纯flutter开发
> - ios/android native/flutter 开发

团队成员不可能会全员进行`ios/android native/flutter`开发，所有我们需要尽可能的保证三种角色的相对独立性。而且也不能对现有的构建打包体系有太多的侵入。

[简单集成]()

[faraday全家桶(推荐)]()

[快速开始](docs/integration.md)

[混合栈路由](docs/route.md)

[网络](docs/net.md)

[Method Channel](docs/generate.md)

[CI/CD 支持](docs/deployment.md)




<!-- <pre>
    ___                   _
   / __\_ _ _ __ __ _  __| | __ _ _   _
  / _\/ _` | '__/ _` |/ _` |/ _` | | | |
 / / | (_| | | | (_| | (_| | (_| | |_| |
 \/   \__,_|_|  \__,_|\__,_|\__,_|\__, |
                                  |___/
</pre> -->