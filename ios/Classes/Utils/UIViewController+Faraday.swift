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
    
    var callbackToken: CallbackToken? {
        get {
            return objc_getAssociatedObject(UIViewController.self, &AssociatedKeys.CallbackName) as? CallbackToken
        }
        nonmutating set {
            if let newValue = newValue {
                objc_setAssociatedObject(UIViewController.self, &AssociatedKeys.CallbackName, newValue as CallbackToken?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    func present(_ viewControllerToPresent: UIViewController, with callbackToken: CallbackToken,  animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.fa.callbackToken = callbackToken
        type.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}

public extension FaradayExtension where ExtendedType: UINavigationController {
    
    func pushViewController(_ viewController: UIViewController, with callbackToken: CallbackToken, animated: Bool) {
        viewController.fa.callbackToken = callbackToken
        type.pushViewController(viewController, animated: animated)
    }
    
}
