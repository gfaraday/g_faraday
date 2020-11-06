# Feature

混合应用使用flutter开发的功能模块，一般来说是比较独立的。如何正确的组织这些不同的功能模块是一个棘手的问题。`g_faraday`新增了模块支持，将每一组相似或相同的功能看作是一个`feature`，具体到代码层面就是可以把所有与当前功能相关的操作都集中在一个`feature`类中。我们先来看以下`Feature`的定义

``` dart

/// 一组业务需求的功能集合
abstract class Feature {
  /// 功能描述描述
  String get description => '';

  /// 作者
  String get author => 'Someone';

  /// 功能名称
  String get name;

  /// 注册feature中的所有页面
  Map<String, RouteFactory> get pageBuilders => {};
}
```

下面我们来看一个典型的`Feature`是什么样子的

``` dart

class DemoFeature extends Feature {

    String get description => 'demo feature';

    String get author => 'kevin';

    String get name => 'demo'

    ///
    /// 在这里我们需要注册所有需要从原生打开的flutter页面
    /// 以及想要通过 Navigator.of(context).pushNamed 打开的页面
    ///
    Map<String, RouteFactory> get pageBuilders => {
        'demo_add_customer': RouteFactory
    };


    ///
    /// 接下来我们需要标记出来，哪些页面可以从原生打开这样我们就可以通过
    /// cli 工具在原生端 生成相应的 接口文件
    ///
    /// 如果使用cli工具这里需要注意2件事情
    /// 1. method的名字必须从路由名字直接转成驼峰
    /// 2. 确认只有需要从原生打开flutter页面的method， 才可以使用`@entry`注解
    ///
    @entry
    static void demoAddCustomer(BuildContext context) {
        Navigator.of(context).pushNamed('demo_add_customer');
    }

    ///
    /// 当前`Feature`需要调用Common的方法可以用@common 进行注解，然后 [cli](https://github.com/gfaraday/cli) 工具可以自动生成
    /// 方法实现， 以及原生的接口文档
    ///
    @common
    static Future fetchPermissionCodes() {
        return FaradayCommon.invokeMethod('DemoFeature#fetchPermissionCodes');
    }
}

// 当我们定义了若干个`Feature`以后我们就可以使用以下方法来初始我们的route
CupertinoApp(onGenerateRoute: (_) => [DemoFeature(), feature1, feature2, ...]);

```