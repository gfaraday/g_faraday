# 桥接原生方法

作为一个原生为主的混合应用，原生代码层肯定已经有了大量的基础设施例如加解密，或者本机缓存等等。想要调用这些本地`服务`有两种方式：

## FaradayCommon

faraday定义了一个特定的[channel](https://flutter.dev/docs/development/platform-integration/platform-channels)用于处理类似的需求。首先iOS/Android 需要实现指定接口

> 针对FaradayCommon我们提供了相应的[cli](https://github.com/gfaraday/cli)用来自动解析参数生成对应的接口文件

### flutter

``` dart
FaradayCommon.invokeMethod('method', 'arguments');
```

### ios

``` swift

// 0x00 定义一个用来处理 flutter端调用的处理函数，然后在Faraday初始化时传递给engine
func handle(_ name: String, _ arguments: Any?, _ completion: @escaping (_ result: Any?) -> Void) -> Void { 
    // doSomething
}

// 0x01
Faraday.default.startFlutterEngine(navigatorDelegate: navigator, commonHandler: handle(_:_:_:))

```

### android

``` kotlin

// 0x00 首先需要实现这个接口 MethodChannel.MethodCallHandler
class CommonHandler: MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        print("Faraday-> ${call.method} not handle. argument: ${call.arguments}")
    }
}

// 0x01 Faraday 初始化以后，设置Handler给faraday即可
Faraday.setCommonHandler(CommonHandler())

```

## 自定义channel

你也可以完全自定义一个channel，用来处相应的逻辑

### flutter

``` dart
const _channel = MethodChannel('g_faraday_custom/common');

//
_channel.invokeMethod('method', 'arguments');
```
然后在ios/android端注册对应的channel 然后处理即可。