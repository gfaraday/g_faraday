集成

## 0x00 前置条件准备

- faraday cli 工具
- 文件服务器
- cocoapods private spec

### faraday cli 工具

faraday是我们为了方便后续开发测试所开发的一款命令行程序，用下面的命令即可安装 

``` shell

pub global active faraday

# print version
faraday version

```
我们也开发了对应的`vscode extension`您可以选择安装。在`vscode extensions tab`搜索 `faraday` 即可。

### 文件服务器

为了无感集成flutter模块至现有的ios和android工程，需要一个所有团队成员均可访问的文件服务器(支持文件上传下载)来存储编译产物(ios为`cocoapods framework`，`android` 为`maven`仓库)
> 如果暂时没有文件服务器可以下载 [simple-http-server.py](tools/http-server/simple-http-server.py)启动一个用于测试的文件服务器。需要安装`python3`

### cocoapods private spec

ios选择使用`cocoapods`来集成，为了让native开的同学无感我们需要创建私有`repo`。
具体步骤参见 [Private Pods](https://guides.cocoapods.org/making/private-cocoapods.html)

## 0x02 创建`module`

首先需要创建和原生app集成的`flutter module` (这里大家需要明确flutter app plugin module package之间的异同)

``` shell

cd some/path/to/flutter_module/

flutter create -t module [APP_NAME] .

# 参数用`help`命令来查看用法
flutter create --help

```

## 0x03 修改 `pubspec.yaml`

#### 添加`g_faraday`依赖
``` yaml
dependencies:
  g_faraday: ^version
```

#### 添加faraday配置信息

``` yaml

...

faraday:
  static_file_server_address: "http://localhost:8000"
  pod_repo_name: "faraday"

...

```


## 0x03 Tag

接下来我们尝试打包上传一次flutter产物，以验证环境配置是否正确

``` shell
# 注意这里的 version为固定格式必须用+分割, +后面的可以是git提交次数/hash 或者ci/cd job序号等等
# --release 或 --no--release 用来标记是否为release产物
# 其他用法详见 faraday tag --help

faraday tag --version 0.0.1+1 --no-release
faraday tag --version 0.0.1+2 --release

```

如果一切顺利 你应该会看到以下日志

```
Consuming the Module:

For iOS Developer:
  1. Open <native-project>/Podfile
  2. Ensure you have the faraday source configured, otherwise add them: 

    source [YOUR REPO URL]

  3. Make the host app depend on IntegrateExample pod

    pod '[MODULE NAME]Debug', '~> 0.0.1+1', :configuration => ['Debug'], :inhibit_warnings => true
    pod '[MODULE NAME]', '~> 0.0.1+2', :configuration => ['Release'], :inhibit_warnings => true


For Android Developer:
  1. Open <native-project>/app/build.gradle
  2. Ensure you have the repositories configured, otherwise add them:
      
      String storageUrl = System.env.FLUTTER_STORAGE_BASE_URL ?: "https://storage.googleapis.com"
      repositories {
        maven {
           url '[YOUR STATIC FILE ADDRESS]/android-aar-repo'
        }
        maven {
           url '$storageUrl/download.flutter.io'
        }
      }
  3. Make the host app depend on the Flutter module:

    dependencies {
      debugImplementation '[YOUR ANDROID PACKAGE]:flutter_release:0.0.1+1'
      releaseImplementation '[YOUR ANDROID PACKAGE]:flutter_release:0.0.1+2'
    }

```
根据以上日志提示，分别在ios和android原生项目中集成module。

到此为止整个`g_faraday`已经成功集成，开始写代码吧
