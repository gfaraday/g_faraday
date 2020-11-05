# 通知

通过全局的通知来传递数据，或者驱动业务不是一个很好的软件模式，但是在某些特定的场景却可以节省大量的时间。我们对混合app通知做了部分封装方便大家开发业务时使用。


## flutter

``` dart

// 构造相应的通知对象
final notification = FaradayNotification('NotificationKey', {'id': 1234});

// 发送 （会同时发送到flutter和native）
notification.dispatchToGlobal(deliverToNative: true);

// 接收 (可以同时接收到native和flutter通知)
FaradayNotificationListener(
      ['NotificationKey'],
      onNotification: (n) => debugPrint('$n'),
      child: xxx,
    );
```

## ios

``` swift

// 发送 (只会发送到flutter，如需发送到native请自行广播)
NotificationCenter.fa.post(name: "NotificationKey", object: ["id": 1234])

// 接收 (可以同时接收到native和flutter通知)
let center = NSNotificationCenter.defaultCenter()
let mainQueue = NSOperationQueue.mainQueue()
var token: NSObjectProtocol?
token = center.addObserverForName("NotificationKey", object: nil, queue: mainQueue) { (note) in
    print("Received the notification! \(note)")
    center.removeObserver(token!)
}

```

## android

``` kotlin

// 发送 (只会发送到flutter，如需发送到native请自行广播)
Faraday.postNotification("NotificationKey", mapOf("id" to 1234))

// 接收 (只能接收flutter侧通知)
Faraday.registerNotification("NotificationKey") { params ->
    //解除注册
    Faraday.unregisterNotification("NotificationKey")
}

```