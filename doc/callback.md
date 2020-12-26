# 页面间传值

## Flutter侧

在`flutter`这边传值比较容易，不管是`flutter->flutter`还是`flutter->native`或者`native-flutter`都和`纯flutter`写法无任何差异例如：

``` dart

// push 路由以后等待 被push的路由 pop时的result
final result = await Navigator.of(context).push(route);

// 关闭当前flutter页面，并将result传递到上一个页面
Navigator.of(context).pop({'id': 1});

```

## iOS

> 需要在 applicationDidFinish 中调用 `UIViewController.fa.automaticallyCallbackNullToFlutter()`

一共有两种情况需要处理

- native 打开一个flutter页面然后等待返回值

``` swift

// 初始化一个 FaradayFlutterViewController 的对象
let vc = FaradayFlutterViewController(page.name, arguments: page.arguments) { result in
    /**
        这里的 result 即flutter侧关闭页面时的回调

        ``` dart
        // 关闭并且传值
        Navigator.of(context).pop({'id': 1});
        ```
    **/
    debugPrint(result.toString() ?? '') // print {'id': 1}
}
```

- 从flutter侧打开一个native页面， 然后等待native页面返回值

``` dart

// 从flutter打开native页面只需要调用
final result = await Navigator.of(context).nativePushNamed('native_page_name');

```

flutter侧调用`nativePushNamed(:)`以后，native侧的`FaradayNavigationDelegate` `push`方法会被调用，只需要在此方法中 `push`一个对应页面的控制器即可，那么这个控制器如何回调给flutter层呢

``` swift

// flutter打开native，native回调值给flutter一共有3种情况

// 假设被打开的控制器为：vc

// 1.控制器是被 push的
vc.navigatorController?.fa.popViewController(withResult: result, animation: true)

// 2. 控制器是被 present的
vc.fa.dismiss(withResult: result, animation: true)

// 3. 控制器是被 `addChild` 等其他方式加载到当前堆栈的
//    那么需要在 vc 移除堆栈时调用
vc.fa.callback(result: result)

```

## Android

- 从`native`打开一个`flutter`页面，然后等待`flutter`返回值,与打开原生页面无异

``` kotlin

   //以 startActivityForResult方式打开flutter页面,FaradayActivity为flutter页面容器
val intent = FaradayActivity.build(context, route,arguments)
startActivityForResult(intent, requestCode)

...
   //重写onActivityResult方法获得返回值
override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    super.onActivityResult(requestCode, resultCode, data)
    val value = data?.getStringExtra("key")
    //TODO ...
}

```

- 从`flutter`打开一个`native`页面， 然后等待`native`页面返回值

打开`native`页面,并等待返回值

```dart
Navigator.of(context).nativePushNamed('native route').then((result) {
      print('返回值：$result')
});
```

`native`页面返回值给`flutter`，只能传递flutter支持的数据类型

```kotlin
//传递基础数据类型
setResult(RESULT_OK, Intent().apply {
    putExtra("result", "data form native")
}
//传递HashMap，map泛型须为基础类型
setResult(RESULT_OK, Intent().apply {
    putExtra("result", hashMapOf("data" to 123))
}
//传递ArrayList,ArrayList中只能是String或Int
setResult(RESULT_OK, Intent().apply {
    putStringArrayListExtra("result", ArrayList())
})

//复杂数据建议转换成json字符串传递
});
```

## 其他特殊场景路由处理

### 在`flutter`中打开一个新的native页面用来`push` `flutter`路由

``` dart

// 在原生`ios|android`的`FaradayNavigationDelegate`中根据对应的`name`和`arguments`返回`FaradayFlutterViewController`即可
Navigator.of(context).nativePushNamed('native_page_name', options: {'flutter': true});

```

### 关闭当前`flutter`容器

``` dart

Navigator.of(context).nativePop(result);

```
