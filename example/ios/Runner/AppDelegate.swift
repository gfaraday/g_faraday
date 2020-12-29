import UIKit
import g_faraday

@UIApplicationMain
@objc class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        UINavigationController.fa.automaticallyHandleNavigationBarHidden()
        UIViewController.fa.automaticallyCallbackNullToFlutter()
        
        Faraday.default.startFlutterEngine(navigatorDelegate: self, httpProvider: nil, commonHandler: self.handle(_:_:_:), automaticallyRegisterPlugins: true)
        
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

public protocol FlutterPage {
    
    var name: String { get }
    var arguments: Any? { get }
}

enum FPage: FlutterPage {
    
    case flutterTab1
    case flutterTab2
    case flutter
    case home
    case native2flutter
    
    var name: String {
        switch self {
            case .home:
                return "home"
            case .native2flutter:
                return "native2flutter"
            case .flutterTab1:
                return "flutter_tab_1"
            case .flutterTab2:
                return "flutter_tab_2"
            default:
                return "flutter"
        }
    }
    
    var arguments: Any? { return Date().description }
}

extension FlutterPage {
    
    func flutterViewController(callback: @escaping (Any?) -> Void) -> UIViewController {
        return FaradayFlutterViewController(name, arguments: arguments, callback: callback)
    }
}


extension AppDelegate: FaradayCommonHandler {
    func showLoading(_ message: String) -> Any? {
        return nil
    }
    
    func getSomeData(_ id: String, _ optionalArg: Bool?) -> Any? {
        return ["name": "test"]
    }
    
    func setSomeData(_ data: Any, _ id: String) -> Any? {
        //
        return true
    }
    
}
