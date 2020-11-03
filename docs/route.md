# 路由

`g_faraday`是作为一个解决混合路由栈的框架而开发的，因此对路由的支持特别完备。`g_faraday`采用最小入侵的设计原则，不管是在`native`侧还是`flutter`侧，只需要在程序入口处做少量的注册即可完成集成。
同时页面跳转，页面间传值也不需要做任何自定义，也就是说一个纯flutter应用做很小量的改动即可无缝集成自现有应用。

# flutter 侧路由

在flutter侧我们只需要注册所有需要从原生打开的路由即可，其他不需要从原生直接进入的页面，不需要做任何改动。

## 打开页面

``` dart
    Navigator.of(context).push('/home' {'id': 1234});
```

## 关闭页面

``` dart
    Navigator.of(context).pop({'succeed': true});
```

## 获取`rootNavigator`
``` dart
    // 不能使用
    Navigator.of(context, userRootNavigator: true) 
    // 推荐使用
    FaradayNavigator.of(context);
```

## 关闭所有flutter页面
``` dart
    Navigator.of(context).nativePop('result');
```
以上只是部分`Navigator`方法示例，理论上`g_faraday`支持所有原生的路由方法。

# ios

ios端也特别类似只需要使用页面名称`name`和页面参数`arguments`来生成一个普通的`ViewController`即可，你可以使用`push`、`present`、`addChild`等任意方式将`ViewController`对象加入到页面栈即可

``` swift

    /// push
    let vc = FaradayFlutterViewController(name, arguments: arguments)
    navigatorController?.pushViewController(vc, animated: true)

    // add to Tab bar Controller
    let vc = FaradayFlutterViewController(name, arguments: arguments)    
    vc.willMove(toParent: self)
    addChild(vc)
    view.addSubview(vc.view)
    vc.didMove(toParent: self)
```

# android

同理android也可以作为一个独立的activity或者一个嵌入的fragment来使用

``` kotlin
    // 创建intent 然后start 即可
    val intent = FaradayActivity.build(context, routeName, params)
    context.startActivity(intent)

    //
    val fragment = FaradayFragment.newInstance(name, arguments)
    // add fragment to fragment manager
```