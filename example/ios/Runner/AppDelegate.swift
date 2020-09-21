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
        (Faraday.sharedInstance.currentFlutterViewController as? FaradayFlutterViewController)?.disableHorizontalSwipePopGesture(disable: disable)
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

import UIKit

extension UIViewController {
  private class var sharedApplication: UIApplication? {
    return UIApplication.shared
  }

  /// Returns the current application's top most view controller.
  open class var topMost: UIViewController? {
    guard let currentWindows = self.sharedApplication?.windows else { return nil }
    var rootViewController: UIViewController?
    for window in currentWindows {
      if let windowRootViewController = window.rootViewController, window.isKeyWindow {
        rootViewController = windowRootViewController
        break
      }
    }

    return self.topMost(of: rootViewController)
  }

  /// Returns the top most view controller from given view controller's stack.
  open class func topMost(of viewController: UIViewController?) -> UIViewController? {
    // presented view controller
    if let presentedViewController = viewController?.presentedViewController {
      return self.topMost(of: presentedViewController)
    }

    // UITabBarController
    if let tabBarController = viewController as? UITabBarController,
      let selectedViewController = tabBarController.selectedViewController {
      return self.topMost(of: selectedViewController)
    }

    // UINavigationController
    if let navigationController = viewController as? UINavigationController,
      let visibleViewController = navigationController.visibleViewController {
      return self.topMost(of: visibleViewController)
    }

    // UIPageController
    if let pageViewController = viewController as? UIPageViewController,
      pageViewController.viewControllers?.count == 1 {
      return self.topMost(of: pageViewController.viewControllers?.first)
    }

    // child view controller
    for subview in viewController?.view?.subviews ?? [] {
      if let childViewController = subview.next as? UIViewController {
        return self.topMost(of: childViewController)
      }
    }

    return viewController
  }
}

