# g_faraday

一个足够灵活的Flutter混合开发解决方案

## 为什么会有这个库
Flutter凭借着优秀的跨平台能力迅速壮大了起来，但flutter对[Add-to-app](https://flutter.dev/docs/development/add-to-app)的支持并没有纯flutter项目那么友好。
我们试着考虑一下对现有app添加flutter支持需会遇到哪些问题?

### 混合栈路由
混合app肯定会存在`native page`和`flutter widget`交替出现的场景，所以我们处理了这种页面跳转以及传值。 目前社区比较知名的有闲鱼团队的 [flutter_boost](https://github.com/alibaba/flutter_boost)。

### 网络
native肯定已经有比较完善的网路层支持了，可能涉及到数据包加解密以及认证等等。这里我们就有2中处理方式，一是将native的认证消息通过[Method Channel](https://api.flutter.dev/flutter/services/MethodChannel-class.html)传递到flutter侧，另一种则是将flutter侧的所有网络请求全部代理至native

#### 数据字典
native一般都会在本地缓存一些基础数据，flutter侧肯定也会有读写这些数据的需求

#### 其他 
native可能会实现一些特定算法，或者特定功能的方法，flutter侧也必须有能力调用。flutter的错误日志收集等等

### 试一下
<!-- `g_faraday`是一个标准的`Flutter`插件，`flutter`侧集成与其他插件并无区别。 -->
首先你需要创建和原生app集成的`flutter module` (这里大家需要明确flutter app plugin module package之间的异同)

``` shell
flutter create -t module faraday_demo -i swift -a kotlin --org com.yuxiaor.mobile.flutter
```

`faraday_demo` 即项目名称，你需要换成即项目的名称。其他参数你可以用一下命令来查看用法
```shell
flutter create --help
```

`module` 创建完成以后你需要引入`g_faraday`依赖，在`pubspec.yaml`中添加然后执行`flutter pub get` 至此flutter侧集成完毕

``` yaml
dependencies:
  g_faraday: ^1.2.0
```

下面我们继续来看 native侧集成

#### iOS 开发

#### Android 开发


### 工程化

## 页面间传值

### Flutter侧
在flutter这边传值比较容易，不管是`flutter->flutter`还是`flutter->native`都和原生写法并无差异例如：

``` dart

// push 路由以后等待 被push的路由 pop时的result
final result = await Navigator.of(context).push(route);

// 关闭当前flutter页面，并将result传递到上一个页面
Navigator.of(context).pop(result);

```

### iOS侧
在ios侧传值有2中情况



> `flutter->native` 在native关闭的时候，需要将结果回调至flutter。目前的处理方式


``` swift
// 在flutter侧请求打开一个native vc时，会一并传递一个 callback token到 delegate

// FaradayNavigationDelegate
func push(_ callbackToken: CallbackToken, name: String, isFlutterRoute: Bool, isPresent: Bool, arguments: Dictionary<String, Any>?)

// 被flutter打开的native 页面在关闭时，如果需要回调数据，利用打开时flutter传递过来的 callback token 回调至flutter

// Faraday
public static func  callback(_ token: CallbackToken?, result: Any?)
```



> `native->flutter` native构造flutter vc的时候需要传递一个接受回调的block。注意如果 flutter vc 被native逻辑主动关闭，如果需要传值，需要手动调用 `FaradayFlutterViewController` 对象的`callbackValueToCreator`方法
### Android侧
##### TODO