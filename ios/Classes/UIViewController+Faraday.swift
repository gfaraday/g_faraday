//
//  UIViewController+Faraday.swift
//  g_faraday
//
//  Created by gix on 2020/9/21.
//

import UIKit

private struct AssociatedKeys {
    static var CallbackName = "faraday_CallbackName"
}


//
typealias CallbackToken = UUID

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
    
    static func automaticallyCallbackNullToFlutter() {
        swizzle(UIViewController.self, #selector(UIViewController.viewDidDisappear(_:)), #selector(UIViewController.faraday_viewDidDisappear(_:)))
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
            // 只回调一次
            callbackToken = nil
        }
    }
    
    func dismiss(withResult result: Any?, animated flag: Bool, completion: (() -> Void)? = nil) {
        type.fa.callback(result: result)
        type.dismiss(animated: flag, completion: completion)
    }
}

extension UIViewController {
    
    @objc fileprivate func faraday_viewDidDisappear(_ animated: Bool) {
        faraday_viewDidDisappear(animated)
        // 如果是滑动返回，或者点击左上角back键返回 则需要告诉flutter 没有返回值
        fa.callback(result: nil)
    }
}
