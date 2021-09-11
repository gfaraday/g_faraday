# ![log](./doc/images/logo.png)  Faraday [English](./README_EN.md)

![Build](https://img.shields.io/github/workflow/status/gfaraday/g_faraday/Publisher/master?logo=github&style=for-the-badge)
![pub_Version](https://img.shields.io/pub/v/g_faraday?include_prereleases&style=for-the-badge&logo=data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPHN2ZyB3aWR0aD0iNjAwcHgiIGhlaWdodD0iNjAwcHgiIHZpZXdCb3g9IjAgMCA2MDAgNjAwIiB2ZXJzaW9uPSIxLjEiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiPgogICAgPHRpdGxlPmZhcmFkYXk8L3RpdGxlPgogICAgPGRlZnM+CiAgICAgICAgPGxpbmVhckdyYWRpZW50IHgxPSIxMC42ODAxNzA0JSIgeTE9IjI2Ljk5MzAyODclIiB4Mj0iNzIuMTEzMDU3NiUiIHkyPSI1Mi45MTkyNjU3JSIgaWQ9ImxpbmVhckdyYWRpZW50LTEiPgogICAgICAgICAgICA8c3RvcCBzdG9wLWNvbG9yPSIjMDAwMDAwIiBvZmZzZXQ9IjAlIj48L3N0b3A+CiAgICAgICAgICAgIDxzdG9wIHN0b3AtY29sb3I9IiMwMDAwMDAiIHN0b3Atb3BhY2l0eT0iMCIgb2Zmc2V0PSIxMDAlIj48L3N0b3A+CiAgICAgICAgPC9saW5lYXJHcmFkaWVudD4KICAgIDwvZGVmcz4KICAgIDxnIGlkPSJQYWdlLTEiIHN0cm9rZT0ibm9uZSIgc3Ryb2tlLXdpZHRoPSIxIiBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPgogICAgICAgIDxnIGlkPSJmYXJhZGF5IiBmaWxsLXJ1bGU9Im5vbnplcm8iPgogICAgICAgICAgICA8ZyBpZD0iR3JvdXAiPgogICAgICAgICAgICAgICAgPGcgaWQ9ImZsdXR0ZXItc2Vla2xvZ28uY29tIj4KICAgICAgICAgICAgICAgICAgICA8cG9seWdvbiBpZD0iUGF0aCIgZmlsbD0iI0VCRkNGNCIgcG9pbnRzPSIyMDQuNTY2ODQ1IDAgMCAyMjEuOTI4NzQ2IDYzLjMxNzM1OSAyOTAuNjE5OTQ2IDMzMS4yMDI5ODkgMCI+PC9wb2x5Z29uPgogICAgICAgICAgICAgICAgICAgIDxwb2x5Z29uIGlkPSJQYXRoIiBmaWxsPSIjRUJGQ0Y0IiBwb2ludHM9IjIwMy4zNDU5MzggMjA0LjI0MTI0IDkzLjk5MDAzNzQgMzIyLjYyMDg5OSAxNTcuNDQzOTAxIDM5Mi4zMzY5MjcgMjIwLjU0MzM2OCAzMjQuMDMwNjU4IDMzMS4yMDI5ODkgMjA0LjI0MTI0Ij48L3BvbHlnb24+CiAgICAgICAgICAgICAgICAgICAgPHBvbHlnb24gaWQ9IlBhdGgiIGZpbGw9IiNFQkZDRjQiIHBvaW50cz0iMTU3LjM5NjAxNSAzOTIuODE5ODQxIDIwNS40NDUxNzMgNDQ0LjgwOTk3MyAzMzEuMjAyOTg5IDQ0NC44MDk5NzMgMjIwLjUxMTk2NSAzMjQuNTI1NjA2Ij48L3BvbHlnb24+CiAgICAgICAgICAgICAgICAgICAgPHBvbHlnb24gaWQ9IlBhdGgiIGZpbGw9IiNFQkZDRjQiIHBvaW50cz0iOTMuMjQ0MDg0NyAzMjMuODY0MiAxNTYuNjA3OTA4IDI1NS4wOTk3MyAyMjAuODAxOTkzIDMyNC41MDgyMzIgMTU3LjU1ODAwMSAzOTMuMTQ0MjA1Ij48L3BvbHlnb24+CiAgICAgICAgICAgICAgICAgICAgPHBvbHlnb24gaWQ9IlBhdGgiIGZpbGwtb3BhY2l0eT0iMC44IiBmaWxsPSJ1cmwoI2xpbmVhckdyYWRpZW50LTEpIiBwb2ludHM9IjE1Ny4zOTYwMTUgMzkyLjMzNjkyNyAyMTAuMzIyOTA0IDM3My4zMzA1NzYgMjE1LjU4MDMyNCAzMjkuMzY5MjcyIj48L3BvbHlnb24+CiAgICAgICAgICAgICAgICA8L2c+CiAgICAgICAgICAgICAgICA8ZyBpZD0iZmx1dHRlci1zZWVrbG9nby5jb20iIHRyYW5zZm9ybT0idHJhbnNsYXRlKDI2Ny43OTcwMTEsIDE1NC4xOTAwMjcpIiBmaWxsPSIjRUJGQ0Y0Ij4KICAgICAgICAgICAgICAgICAgICA8cG9seWdvbiBpZD0iUGF0aCIgcG9pbnRzPSIyMDQuNTY2ODQ1IDAgMCAyMjEuOTI4NzQ2IDYzLjMxNzM1OSAyOTAuNjE5OTQ2IDMzMS4yMDI5ODkgMCI+PC9wb2x5Z29uPgogICAgICAgICAgICAgICAgICAgIDxwb2x5Z29uIGlkPSJQYXRoIiBwb2ludHM9IjIwMy4zNDU5MzggMjA0LjI0MTI0IDkzLjk5MDAzNzQgMzIyLjYyMDg5OSAxNTcuNDQzOTAxIDM5Mi4zMzY5MjcgMjIwLjU0MzM2OCAzMjQuMDMwNjU4IDMzMS4yMDI5ODkgMjA0LjI0MTI0Ij48L3BvbHlnb24+CiAgICAgICAgICAgICAgICAgICAgPHBvbHlnb24gaWQ9IlBhdGgiIHBvaW50cz0iMTU3LjM5NjAxNSAzOTIuODE5ODQxIDIwNS40NDUxNzMgNDQ0LjgwOTk3MyAzMzEuMjAyOTg5IDQ0NC44MDk5NzMgMjIwLjUxMTk2NSAzMjQuNTI1NjA2Ij48L3BvbHlnb24+CiAgICAgICAgICAgICAgICAgICAgPHBvbHlnb24gaWQ9IlBhdGgiIHBvaW50cz0iOTMuMjQ0MDg0NyAzMjMuODY0MiAxNTYuNjA3OTA4IDI1NS4wOTk3MyAyMjAuODAxOTkzIDMyNC41MDgyMzIgMTU3LjU1ODAwMSAzOTMuMTQ0MjA1Ij48L3BvbHlnb24+CiAgICAgICAgICAgICAgICA8L2c+CiAgICAgICAgICAgIDwvZz4KICAgICAgICA8L2c+CiAgICA8L2c+Cjwvc3ZnPg==)
![Flutter_Version](https://img.shields.io/badge/Flutter-stable-blue?style=for-the-badge&logo=flutter)
![License](https://img.shields.io/github/license/gfaraday/g_faraday?style=for-the-badge)

[一个`Flutter`混合栈开发解决方案](https://juejin.cn/post/6911985354488676365)

## Features

- [x] 支持`ios`、`android`、`flutter`三端所有原生路由(页面切换)跳转行为
- [x] 支持混合栈(native -> flutter -> native)路由跳转(popTo、replace ...)
- [x] 支持flutter页面作为root页面
- [x] 支持flutter作为子页面加入原生堆栈
- [x] 支持flutter作为弹出页面(背景透明到native层)
- [x] [页面间回调传值完整支持](doc/callback.md)
- [x] [iOS导航条自动隐藏/显示](doc/ios_navigation_bar.md)
- [x] `WillPopScope`拦截滑动返回(ios)或者返回按键键(android)
- [x] [发送/接收全局通知](doc/notification.md)
- [x] 支持自定义页面切换动画
- [x] 支持完整的生命周期监听
- [ ] 单元测试
- [x] 完整的文档(7/10)

## 使用`g_faraday`的APP

| 序号 | 名称   | 版本号 | iOS                                                                            | Android                                                         |
| ---- | ------ | ------ | ------------------------------------------------------------------------------ | --------------------------------------------------------------- |
| 0    | 寓小二 | 8.0.0  | [AppStore](https://apps.apple.com/cn/app/寓小二-公寓系统定制专家/id1081403007) | [应用宝](https://a.app.qq.com/o/simple.jsp?pkgname=com.yuxiaor) |

> 您的app也在使用?[联系我们](#Communication)

## Show Cases

![demo](doc/images/demo.png)

## Example App

[Android下载apk](https://github.com/gfaraday/g_faraday/releases/download/v0.5.0-nullsafety.3/appv2.apk)

<!-- [iOS下载app](https://github.com/gfaraday/g_faraday/releases/download/0.4.2/example.app.zip)
> [模拟器安装app](doc/ios-simulator-install.md) -->

## 设计原则

- 对原有平台最小侵入
- 对现有代码最小改动
- API尽量保持和原有平台一致

## 更新策略

_Flutter **stable channel** 发布后 **一周内**适配发布对应的`g_faraday`版本_

## Requirements

- Flutter 2.5.0 • channel stable
- iOS 10.0+ Xcode 12.0+ Swift 5.1+
- Android minSdkVersion 16 Kotlin 1.4.10+

## 版本对应关系

| g_faraday           | flutter                                                                   | cocoapods | remark        |
| ------------------- | ------------------------------------------------------------------------- | --------- | ------------- |
| ^0.7.2              | Flutter 2.5.0 • channel stable • `https://github.com/flutter/flutter.git` | any       | recommend     |
| ^0.7.0              | Flutter 2.0.0 • channel stable                                            | any       | not recommend |
| ^0.5.1-nullsafety.0 | Flutter 1.24.0-10.2.pre • channel beta                                    | any       | not recommend |
| ^0.5.0-nullsafety.0 | Flutter 1.24.0-10.2.pre • channel beta                                    | any       | not recommend |
| ^4.0.0              | Flutter 1.24.0-10.2.pre • channel beta                                    | any       | not recommend |

## 快速开始

如果您已经有其他类似框架使用经验，可以直接查看[Example](example/)浏览最佳实践。

> run example project: `flutter run --no-sound-null-safety`

### 添加依赖

``` yaml
dependencies:
  g_faraday: ^0.7.0
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

> 注意不管是`CupertinoApp`还是`MaterialApp`都不要设置`home`

### iOS 集成

[Objective-C集成看这里](./example_objc_only/README.md)

为了实现从`Flutter`端打开原生页面的应用场景，所以我们需要实现一个打开原生页面的protocol

``` swift

// 0x00 实现 `FaradayNavigationDelegate`
extension AppDelegate: FaradayNavigationDelegate {

    func push(_ name: String, arguments: Any?, options: [String : Any]?, callback token: CallbackToken) {

        let isFlutter = options?["flutter"] as? Bool ?? false
        let isPresent = options?["present"] as? Bool ?? false

        let vc = isFlutter ? FaradayFlutterViewController(name, arguments: arguments) : FirstViewController(name， arguments: arguments)

        let topMost = UIViewController.fa.topMost
        if (isPresent) {
            // 此处注意
            // vc.modalPresentationStyle 不能是`pageSheet`
            // 如果的确需要这种UI效果，可以配合透明背景，在Flutter侧实现
            topMost?.present(vc, animated: true, completion: nil)
        } else {
            topMost?.navigationController?.pushViewController(vc, animated: true)
        }

        // 非常重要
        // 如果此处不调用 `enableCallback` 那么flutter侧`await Navigator`则永远不会返回
        vc.fa.enableCallback(with: token)
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

    override fun create(name: String, arguments: Serializable?, options: HashMap<String, *>?): Intent? {
        val context = Faraday.getCurrentActivity() ?: return null

        val isFlutterRoute = options?.get("flutter") == true

        if (isFlutterRoute) {
            // singleTask 模式
            val builder = FaradayActivity.builder(name, arguments)

            // 你看到的绿色的闪屏就是这个
            builder.backgroundColor = Color.WHITE
            builder.activityClass = SingleTaskFlutterActivity::class.java

            return builder.build(context);
        }

        when (name) {
            "flutter2native" -> {
                return Intent(context, FlutterToNativeActivity::class.java)
            }
            "native2flutter" -> {
                return Intent(context, Native2FlutterActivity::class.java)
            }
            "tabContainer" -> {
                return Intent(context, TabContainerActivity::class.java)
            }
            else -> {
                val intent = Intent(Intent.ACTION_VIEW)
                intent.data = Uri.parse(name)
                intent.putExtra(KEY_ARGS, arguments)
                return intent
            }
        }

    }

    override fun pop(result: Serializable?) {
        val activity = Faraday.getCurrentActivity() ?: return
        if (result != null) {
            activity.setResult(Activity.RESULT_OK, Intent().apply { putExtra(KEY_ARGS, result) })
        }
        activity.finish()
    }

    override fun enableSwipeBack(enable: Boolean) {

    }

}

// 0x01 在 Application 的onCreate方法中启动FlutterEngine
if (!Faraday.startFlutterEngine(this, SimpleFlutterNavigator())) {
    GeneratedPluginRegistrant.registerWith(Faraday.engine)
}

// 0x02 打开一个Flutter页面
val intent = FaradayActivity.build(context, routeName, params)
context.startActivity(intent)

```

## faraday 全家桶 (推荐)

在进行Flutter混合开发时会遇到很多相似的问题，我们提供了相应的解决方案大家玩的开心。

- [路由](doc/route.md)
- [桥接原生方法](doc/bridge.md)
- [网络请求](doc/net.md)
- [JSON](doc/json.md)
- [命令行工具 | 代码生成](https://github.com/gfaraday/cli)
- [vscode 插件 | 自动补全](https://github.com/gfaraday/faraday_extension)
- [打包发布 | CI/CD](./doc/ci.md)

## FAQ

### 是否支持使用第三方路由框架?

支持。

example中提供了[fluro](https://github.com/lukepighetti/fluro)和[getx](https://github.com/jonataslaw/getx)的实现范例

### 是否支持使用`url`配置路由?

支持。

- ios推荐使用[⛵️ URLNavigator](https://github.com/devxoul/URLNavigator)
- android[原生支持](https://developer.android.com/training/app-links/deep-linking)
- flutter推荐[fluro](https://github.com/lukepighetti/fluro)

可以保证3端统一使用url进行路由管理。

### 打包时提示 `failed to load module 'g_faraday'`

请使用`xcode 12.3`及以上版本

## Communication

[扫码加入微信群，请备注 faraday](https://github.com/KevinGong2013)

![wechat group](doc/images/wechat.JPG)

## Contributing

If you wish to contribute a change to any of the existing plugins in this repo, please review our [contribution](CONTRIBUTING.md) guide and open a pull request.

## License

g_faraday is released under the MIT license. [See LICENSE](LICENSE) for details.
