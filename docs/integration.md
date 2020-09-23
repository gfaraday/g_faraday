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