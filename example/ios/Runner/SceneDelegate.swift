import Flutter
import UIKit

// 混合栈宿主：AppDelegate 为纯 UIApplicationDelegate（引擎由 Faraday 手动创建），
// SceneDelegate 直接继承 FlutterSceneDelegate 即可，它只负责把 scene 事件转发给 Flutter 插件。
class SceneDelegate: FlutterSceneDelegate {
}
