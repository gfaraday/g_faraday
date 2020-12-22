//
//  UIViewController+Faraday.swift
//  g_faraday
//
//  Created by gix on 2020/9/21.
//

import UIKit

private struct AssociatedKeys {
    static var CallbackName = "faraday_CallbackName"
    static var DeallocatorName = "faraday_DeallocatorName"
}

public typealias CallbackToken = UUID

extension UIViewController {
    internal var callbackToken: CallbackToken? {
        get {
            return objc_getAssociatedObject(UIViewController.self, &AssociatedKeys.CallbackName) as? CallbackToken
        }
        set {
            objc_setAssociatedObject(UIViewController.self, &AssociatedKeys.CallbackName, newValue as CallbackToken?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

public extension FaradayExtension where ExtendedType: UIViewController {
           
    static func automaticallyCallbackNullToFlutter() {
        swizzle(UIViewController.self, #selector(UIViewController.viewDidLoad), #selector(UIViewController.faraday_viewDidLoad))
    }
        
    var isModal: Bool {
        if let index = type.navigationController?.viewControllers.firstIndex(of: type), index > 0 {
            return false
        } else if type.presentingViewController != nil {
            if let parent = type.parent, !(parent is UINavigationController || parent is UITabBarController) {
               return false
            }
            return true
        } else if let navController = type.navigationController, navController.presentingViewController?.presentedViewController == navController {
            return true
        } else if type.tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        return false
    }
    
    var callbackToken: CallbackToken? {
        set {
            if (newValue == nil) {
                debugPrint("⚠️ [g_faraday] set callback token to nil is not needed.")
            }
            if (type.callbackToken != nil && type.callbackToken == newValue) {
                debugPrint("⚠️ [g_faraday] update callback token will be lost callback.")
            }
            type.callbackToken = newValue
        }
        get {
            return type.callbackToken
        }
    }
       
    func callback(result: Any?) {
        if (type.callbackToken != nil) {
            Faraday.callback(type.callbackToken, result: result)
            // 只回调一次
            type.callbackToken = nil
        }
    }
    
    func dismiss(withResult result: Any?, animated flag: Bool, completion: (() -> Void)? = nil) {
        type.fa.callback(result: result)
        type.dismiss(animated: flag, completion: completion)
    }
}

final class Deallocator {

    var closure: () -> Void

    init(_ closure: @escaping () -> Void) {
        self.closure = closure
    }

    deinit {
        closure()
    }
}

extension UIViewController {
    
    @objc fileprivate func faraday_viewDidLoad() {
        
        let token = callbackToken
        let deallocator = Deallocator {
            // 如果是滑动返回，或者点击左上角back键返回 则需要告诉flutter 没有返回值
            Faraday.callback(token, result: nil)
        }
        
        objc_setAssociatedObject(self, &AssociatedKeys.DeallocatorName, deallocator, .OBJC_ASSOCIATION_RETAIN)
        
        faraday_viewDidLoad()
    }
}
