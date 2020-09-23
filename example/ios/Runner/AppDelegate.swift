import UIKit
import g_faraday

@UIApplicationMain
@objc class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        UINavigationController.farady_automaticallyHandleNavigationBarHidenAndValueCallback()
        
        Faraday.sharedInstance.startFlutterEngine(navigatorDelegate: self, netHandler: flutterNetBridge(_:_:_:), commonHandler: self.handle(_:_:_:))
        
        return true
    }
}

extension AppDelegate: FaradayNavigationDelegate {
    
    func push(_ callbackToken: CallbackToken, name: String, isFlutterRoute: Bool, isPresent: Bool, arguments: Dictionary<String, Any>?) {
        let vc = isFlutterRoute ? FPage.flutter.flutterViewController(callback: { r in
            debugPrint(r.debugDescription)
        }) : FirstViewController()
        
        let topMost = UIViewController.fa.topMost
        if (isPresent) {
            topMost?.present(vc, animated: true, completion: nil)
        } else {
            topMost?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func disableHorizontalSwipePopGesture(_ disable: Bool) {
        Faraday.sharedInstance.currentFlutterViewController?.disableHorizontalSwipePopGesture(disable: disable)
    }
    
    func pop() -> FaradayFlutterViewController? {
        let vc = Faraday.sharedInstance.currentFlutterViewController;
        if (vc?.presentingViewController != nil) {
            vc?.dismiss(animated: true, completion: nil)
            return vc
        }
        
        return vc?.navigationController?.popViewController(animated: true) as? FaradayFlutterViewController
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
