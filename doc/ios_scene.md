# iOS UIScene 支持

Apple 在 WWDC25 宣布：**iOS 26 之后的版本，任何用最新 SDK 构建的 UIKit App 必须使用 UIScene 生命周期，否则无法启动。**

Flutter 自 3.38 起提供 UIScene 支持（`FlutterSceneDelegate` 等），3.41 起默认开启。官方迁移指南：[UIScene adoption](https://docs.flutter.dev/release/breaking-changes/uiscenedelegate)。

`g_faraday` 自 1.2.0 起支持 UIScene。插件本身不监听 App 生命周期事件，因此插件侧无需额外接入；**需要迁移的是宿主 App**。本文档说明混合栈宿主的迁移步骤。

## 迁移步骤

### 1. Info.plist 添加 Scene Manifest

```xml
<key>UIApplicationSceneManifest</key>
<dict>
    <key>UIApplicationSupportsMultipleScenes</key>
    <false/>
    <key>UISceneConfigurations</key>
    <dict>
        <key>UIWindowSceneSessionRoleApplication</key>
        <array>
            <dict>
                <key>UISceneConfigurationName</key>
                <string>Default Configuration</string>
                <key>UISceneDelegateClassName</key>
                <string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
                <!-- 如果之前用 UIMainStoryboardFile 指定入口 storyboard，迁移到这里 -->
                <key>UISceneStoryboardFile</key>
                <string>Main</string>
            </dict>
        </array>
    </dict>
</dict>
```

> ⚠️ `UIApplicationSupportsMultipleScenes` 必须为 `NO`，Flutter 尚不支持多 scene。
>
> ⚠️ 配置 Scene Manifest 后，顶层 `UIMainStoryboardFile` 不再生效，入口 storyboard 通过 `UISceneStoryboardFile` 指定。

### 2. 创建 SceneDelegate

`g_faraday` 宿主的 AppDelegate 通常是纯 `UIApplicationDelegate`（引擎由 `Faraday.default.startFlutterEngine` 手动创建），此时 SceneDelegate **直接继承 `FlutterSceneDelegate`** 即可：

```swift
import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
}
```

`FlutterSceneDelegate` 会把 scene 生命周期事件转发给所有 Flutter 插件（例如 `local_auth` 等依赖 scene 事件的插件）。

如果你的 SceneDelegate 必须继承其他基类，则改用 `FlutterSceneLifeCycleProvider` 手动转发：

```swift
import Flutter
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, FlutterSceneLifeCycleProvider {

    var window: UIWindow?

    let sceneLifeCycleDelegate = FlutterPluginSceneLifeCycleDelegate()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        sceneLifeCycleDelegate.scene(scene, willConnectTo: session, options: connectionOptions)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        sceneLifeCycleDelegate.sceneDidDisconnect(scene)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        sceneLifeCycleDelegate.sceneWillEnterForeground(scene)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        sceneLifeCycleDelegate.sceneDidBecomeActive(scene)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        sceneLifeCycleDelegate.sceneWillResignActive(scene)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        sceneLifeCycleDelegate.sceneDidEnterBackground(scene)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        sceneLifeCycleDelegate.scene(scene, openURLContexts: URLContexts)
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        sceneLifeCycleDelegate.scene(scene, continue: userActivity)
    }

    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        sceneLifeCycleDelegate.windowScene(windowScene, performActionFor: shortcutItem, completionHandler: completionHandler)
    }
}
```

### 3. 清理 AppDelegate

- 删除 `var window: UIWindow?`（window 改由 scene 创建，AppDelegate 持有 window 会干扰 scene 生命周期）。
- `Faraday.default.startFlutterEngine(...)` **保留在 `didFinishLaunchingWithOptions`**，引擎创建不依赖 window，无需移动。

```swift
func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    UINavigationController.fa.automaticallyHandleNavigationBarHidden()
    UIViewController.fa.automaticallyCallbackNullToFlutter()
    Faraday.default.startFlutterEngine(navigatorDelegate: self)
    return true
}
```

## 插件提供的 scene 相关 API

### `UIViewController.fa.keyWindow`

scene 感知的 key window 访问器（1.2.0 新增）。查找顺序：

1. `foregroundActive` scene 中的 key window
2. `foregroundInactive` scene 中的 key window（覆盖启动早期/过渡态）
3. 任意 scene 中第一个非 hidden window
4. 兜底：`UIApplication.shared.windows`（兼容未迁移 scene 的老宿主）

### `UIViewController.fa.topMost`

内部已改为 scene 优先查找，`FaradayNavigationDelegate.push` 中的用法**无需修改**：

```swift
let topMost = UIViewController.fa.topMost
topMost?.navigationController?.pushViewController(vc, animated: options.animated)
```

## 注意

- 不要再使用 `UIApplication.shared.keyWindow` / `UIApplication.shared.windows` / `UIScreen.main` 等已废弃 API，scene 宿主中它们会返回空或错误值。
- 完整可运行的迁移示例见 [example](../example/ios/Runner/)（`SceneDelegate.swift` + `Info.plist`）。
