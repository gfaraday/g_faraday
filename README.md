<pre>
    ___                   _
   / __\_ _ _ __ __ _  __| | __ _ _   _
  / _\/ _` | '__/ _` |/ _` |/ _` | | | |
 / / | (_| | | | (_| | (_| | (_| | |_| |
 \/   \__,_|_|  \__,_|\__,_|\__,_|\__, |
                                  |___/
</pre>

# g_faraday

一个Flutter混合开发解决方案

## 为什么会有这个库
Flutter凭借着优秀的跨平台能力迅速壮大了起来，但flutter对[Add Flutter to existing app](https://flutter.dev/docs/development/add-to-app)的支持并没有纯flutter项目那么友好。
所以有了这个库，我们尝试来解决这个问题。balabalabalab

## 混合开发会遇到哪些问题？

### 关于开发人员
引入flutter以后开发人员的角色会有一下三种
>
> - ios/android 纯native开发
> - 纯flutter开发
> - ios/android native/flutter 开发

团队成员不可能会全员进行`ios/android native/flutter`开发，所有我们需要尽可能的保证三种角色的相对独立性。而且也不能对现有的构建打包体系有太多的侵入。

[简单集成]()

[faraday全家桶(推荐)]()

[快速开始](docs/integration.md)

[混合栈路由](docs/route.md)

[网络](docs/net.md)

[Method Channel](docs/generate.md)

[CI/CD 支持](docs/deployment.md)