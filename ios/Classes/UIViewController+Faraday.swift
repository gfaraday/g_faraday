//
//  UIViewController+Faraday.swift
//  g_faraday
//
//  Created by gix on 2020/9/21.
//

import Foundation

private struct AssociatedKeys {
    static var CallbackName = "faraday_CallbackName"
}

public extension FaradayExtension where ExtendedType: UIViewController {
    
    internal var callbackToken: CallbackToken? {
        get {
            return objc_getAssociatedObject(UIViewController.self, &AssociatedKeys.CallbackName) as? CallbackToken
        }
        nonmutating set {
            if let newValue = newValue {
                objc_setAssociatedObject(UIViewController.self, &AssociatedKeys.CallbackName, newValue as CallbackToken?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
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
       
    func callback(result: Any?) {
        if (callbackToken != nil) {
            Faraday.callback(callbackToken, result: result)
        }
    }
    
    func dismiss(withResult result: Any?, animated flag: Bool, completion: (() -> Void)? = nil) {
        type.fa.callback(result: result)
        type.dismiss(animated: flag, completion: completion)
    }
}
