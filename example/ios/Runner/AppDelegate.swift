import UIKit
import g_faraday

@UIApplicationMain
@objc class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // 自动处理导航栏
        UINavigationController.fa.automaticallyHandleNavigationBarHidden()
        // 自动回调空值到flutter侧，避免flutter侧 await 一直不返回
        UIViewController.fa.automaticallyCallbackNullToFlutter()
        
        Faraday.default.startFlutterEngine(navigatorDelegate: self, httpProvider: nil, commonHandler: nil, automaticallyRegisterPlugins: true)
        
        return true
    }
}

extension AppDelegate: FaradayNavigationDelegate {
    
    func push(_ name: String, arguments: Any?, options: Options, callback token: CallbackToken) {
        var vc: UIViewController!
        
        switch name {
            case "flutter2native":
                vc = Flutter2NativeViewController()
            case "native2flutter":
                vc = Native2FlutterViewController()
            case "tabContainer":
                vc = UIStoryboard(name: "TabContainer", bundle: nil).instantiateInitialViewController()
            case "navigationBar":
                vc = UIStoryboard(name: "Other", bundle: nil).instantiateInitialViewController()
            default:
                vc = options.isFlutterRoute ? FaradayFlutterViewController(name, arguments: arguments) : Flutter2NativeViewController()
        }
        
        let topMost = UIViewController.fa.topMost
        if (options.present) {
            topMost?.present(vc, animated: options.animated, completion: nil)
        } else {
            topMost?.navigationController?.pushViewController(vc, animated: options.animated)
        }
        
        // 非常重要
        // 如果此处不调用 `enableCallback` 那么flutter侧`await Navigator`则永远不会返回
        vc.fa.enableCallback(with: token)
    }   

}
