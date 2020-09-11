import UIKit
import g_faraday

@UIApplicationMain
@objc class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        Faraday.sharedInstance.startFlutterEngine(navigatorDelegate: self)
        
        return true
    }
}

extension AppDelegate: FaradayNavigationDelegate {
    
    var navigationController: UINavigationController? {
        return self.window?.rootViewController as? UINavigationController
    }
    
    func push(_ callbackToken: CallbackToken, name: String, isFlutterRoute: Bool, isPresent: Bool, arguments: Dictionary<String, Any>?) {
        let vc = isFlutterRoute ? FPage.flutter.flutterViewController(callback: { r in
            debugPrint(r.debugDescription)
        }) : FirstViewController()
        
        if (isPresent) {
            navigationController?.topViewController?.present(vc, animated: true, completion: nil)
        } else {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func disableHorizontalSwipePopGesture(_ disable: Bool) {
        Faraday.sharedInstance.currentFlutterViewController?.disableHorizontalSwipePopGesture(disable: disable)
    }
    
    func pop() -> FaradayFlutterViewController? {
        
        return navigationController?.popViewController(animated: true) as? FaradayFlutterViewController
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
    
    var name: String {
        switch self {
        case .flutterTab1:
            return "flutter_tab_1"
        case .flutterTab2:
            return "flutter_tab_2"
        default:
            return "flutter"
        }
    }
    
    var arguments: Any? { return [:] }
}

extension FlutterPage {
    
    func flutterViewController(callback: @escaping (Any?) -> Void) -> UIViewController {
        return Faraday.createFlutterViewController(name, arguments: arguments, callback: callback)
    }
}
