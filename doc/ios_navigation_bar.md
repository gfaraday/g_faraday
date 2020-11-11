# iOS Navigation Bar

`FlutterViewController` 需要隐藏`navigation bar`,因此我们需要在这个vc显示隐藏的时候对应的处理`navigation bar`的隐藏显示逻辑。这里我们提供了一个扩展用来自动处理显示隐藏逻辑

``` swift
// 自动处理 Navigation bar逻辑，内部由method_swizzle实现， 请保证此方法只会调用一次
UINavigationController.fa.automaticallyHandleNavigationBarHidden()

```

如果你原生的页面也需要隐藏`navigation bar`，那么你只需要实现此协议即可

``` swift

extension SomeViewController: FaradayNavigationBarHiddenProtocol { }

```
