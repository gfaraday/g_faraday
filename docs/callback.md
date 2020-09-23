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