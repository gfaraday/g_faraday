# faraday

``` html
    ___                   _
   / __\_ _ _ __ __ _  __| | __ _ _   _
  / _\/ _` | '__/ _` |/ _` |/ _` | | | |
 / / | (_| | | | (_| | (_| | (_| | |_| |
 \/   \__,_|_|  \__,_|\__,_|\__,_|\__, |
                                  |___/
```

![Platform](https://img.shields.io/badge/platform-ios%7Candroid-green)

一个`Flutter`混合开发解决方案

## 设计原则

- 对原有平台最小侵入
- 对现有代码最小改动
- API尽量保持和原有平台一致

## 更新策略

_Flutter **stable channel** 发布后 **一周内**适配发布对应的`g_faraday`版本_

## Features

- [x] `iOS/Android` 原生页面堆栈与`Flutter Navigator`无缝桥接
- [x] 支持所有`Navigator`特性
- [x] [页面间回调](docs/callback.md)
- [x] [`iOS`导航条自动隐藏/显示](docs/ios_navigation_bar.md)
- [x] `WillPopScope`拦截滑动返回(ios)或者返回按键键(android)
- [x] [发送/接收全局通知](docs/notification.md)
- [ ] 监听页面生命周期
- [x] 完整的文档(7/9)

## Requirements

- Flutter 1.22.3
- iOS 10.0+ Xcode 12.0+ Swift 5.1+
- Android minSdkVersion 16 Kotlin 1.4.10+

## 快速开始

如果您已经有其他类似框架使用经验，可以直接查看[Example](example/)浏览最佳实践。

### 添加依赖

``` yaml
dependencies:
  # 请确认与本地Flutter兼容的版本
  g_faraday: ^0.4.0
```

### Flutter 端集成

flutter侧的集成工作，主要是注册需要从原生打开的页面。

``` dart

// 0x00 定义 route
final route = faraday.wrapper((settings) {
    switch (settings.name) {
    case 'first_page':
        return CupertinoPageRoute(builder: (context) => Text('First Page'));
    case 'second_page':
        return CupertinoPageRoute(builder: (context) => Text('Second Page'));
    }
    return CupertinoPageRoute(builder: (context) => Text(settings.name));
});

// 0x01 将 route 赋给你的app widget
CupertinoApp(onGenerateRoute: (_) => route);

// 0x02 flutter 侧集成完毕，接下来你可以选择 集成iOS/Android
```

### iOS 集成

为了实现从`Flutter`端打开原生页面的应用场景，所以我们需要实现一个打开原生页面的protocol

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
Faraday.default.startFlutterEngine(navigatorDelegate: self)


// 0x02 打开一个flutter 页面
let vc = FaradayFlutterViewController("first_page", arguments: nil)
navigationController?.pushViewController(vc, animated: true)

// 0x03 集成完毕
```

### Android 集成

为了实现从`Flutter`端打开原生页面的应用场景，所以我们需要实现一组打开原生页面的接口

``` kotlin

// 0x00 实现 navigator
class SimpleFlutterNavigator : FaradayNavigator {

    companion object {
        const val KEY_ARGS = "_args"
    }

    /**
     * Open native page
     * @param name route name
     * @param arguments data from flutter page to native page
     * @param callback  onActivityResult callback
     */
    override fun push(name: String, arguments: Serializable?, options: HashMap<String, *>?, callback: (result: HashMap<String, *>?) -> Unit) {
        val intent = Intent(Intent.ACTION_VIEW)
        intent.data = Uri.parse(name)
        intent.putExtra(KEY_ARGS, arguments)
        Faraday.startNativeForResult(intent, callback)
    }

    /**
     * Close container Activity when flutter pops the last page
     * @param result data from flutter to native
     */
    override fun pop(result: Serializable?) {
        val activity = Faraday.getCurrentActivity() ?: return
        if (result != null) {
            activity.setResult(Activity.RESULT_OK, Intent().apply { putExtra(KEY_ARGS, result) })
        }
        activity.finish()
    }

    /**
     * 是否允许滑动返回
     */
    override fun enableSwipeBack(enable: Boolean) {
    }

}

// 0x01 在 Application 的onCreate方法中启动FlutterEngine
if (!Faraday.initEngine(this, SimpleFlutterNavigator())) {
    GeneratedPluginRegistrant.registerWith(Faraday.engine)
}

// 0x02 打开一个Flutter页面
val intent = FaradayActivity.build(context, routeName, params)
context.startActivity(intent)

```

## faraday 全家桶 (推荐)

在进行Flutter混合开发时会遇到很多相似的问题，我们提供了相应的解决方案大家玩的开心。

- [路由](docs/route.md)
- [桥接原生方法](docs/bridge.md)
- [网络请求](docs/net.md)
- [JSON](docs/json.md)
- [命令行工具 | 代码生成 | 打包发布 | CI/CD](https://github.com/gfaraday/cli)
- [vscode 插件 | 自动补全 | 打包发布](https://github.com/gfaraday/faraday_extension)

## FAQ

## Communication

微信群二维码

## Contributing

If you wish to contribute a change to any of the existing plugins in this repo, please review our [contribution](CONTRIBUTING.md) guide and open a pull request.

## License

g_faraday is released under the MIT license. [See LICENSE](LICENSE) for details.
