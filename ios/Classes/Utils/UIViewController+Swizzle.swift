//
//  NavigationController.swift
//  g_faraday
//
//  Created by gix on 2020/9/2.
//

import UIKit

let swizzle: (AnyClass, Selector, Selector) -> () = { fromClass, originalSelector, swizzledSelector in
    guard
        let originalMethod = class_getInstanceMethod(fromClass, originalSelector),
        let swizzledMethod = class_getInstanceMethod(fromClass, swizzledSelector)
        else { return }
    method_exchangeImplementations(originalMethod, swizzledMethod)
}

// 当前 ViewController 需要隐藏navigationBar时，需遵循此协议,此外如果是rootVC，则需要单独设置navigationBarHidden
public protocol FaradayNavigationBarHiddenProtocol {}

public protocol FaradayResultProvider: UIViewController {
    var result: Any? { get }
}

extension FaradayFlutterViewController: FaradayNavigationBarHiddenProtocol { }

public extension FaradayExtension where ExtendedType: UINavigationController {
        
    static func automaticallyHandleNavigationBarHidenAndValueCallback() {
        swizzle(UINavigationController.self, #selector(UINavigationController.pushViewController(_:animated:)), #selector(UINavigationController.faraday_pushViewController(_:animated:)))
        swizzle(UINavigationController.self, #selector(UINavigationController.popViewController(animated:)), #selector(UINavigationController.faraday_popViewController(animated:)))
        swizzle(UINavigationController.self, #selector(UINavigationController.popToViewController(_:animated:)), #selector(UINavigationController.faraday_popToViewController(_:animated:)))
        swizzle(UINavigationController.self, #selector(UINavigationController.popToRootViewController(animated:)), #selector(UINavigationController.faraday_popToRootViewController(animated:)))
        swizzle(UIViewController.self, #selector(UIViewController.dismiss(animated:completion:)), #selector(UIViewController.faraday_dismiss(animated:completion:)))
    }
}

extension UINavigationController {

    @objc fileprivate func faraday_pushViewController(_ viewController: UIViewController, animated: Bool) {
        var formHidden = false
        var toHidden = false
        
        if let _ = viewControllers.last as? FaradayNavigationBarHiddenProtocol {
            formHidden = true
        }
        if let _ = viewController as? FaradayNavigationBarHiddenProtocol {
            toHidden = true
        }
        
        faraday_pushViewController(viewController, animated: animated)
        if formHidden != toHidden {
            setNavigationBarHidden(toHidden, animated: animated)
        }
    }
    
    @objc fileprivate func faraday_popViewController(animated: Bool) -> UIViewController? {
        if viewControllers.count <= 1 {
            return nil
        }
        var formHidden = false
        var toHidden = false
        
        if let _ = viewControllers.last as? FaradayNavigationBarHiddenProtocol {
            formHidden = true
        }
        if let _ = viewControllers[viewControllers.count - 2] as? FaradayNavigationBarHiddenProtocol {
            toHidden = true
        }
        
        defer {
            if formHidden != toHidden {
                setNavigationBarHidden(toHidden, animated: animated)
            }
        }
        
        let vc = faraday_popViewController(animated: animated)
        let callbackToken = vc?.fa.callbackToken
        if let p = vc as? FaradayResultProvider {
            Faraday.callback(callbackToken, result: p.result)
        }
        return vc
    }
    
    @objc fileprivate func faraday_popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if viewControllers.count <= 1 {
            return nil
        }
        var formHidden = false
        var toHidden = false
        
        if let _ = viewControllers.last as? FaradayNavigationBarHiddenProtocol {
            formHidden = true
        }
        
        if let _ = viewController as? FaradayNavigationBarHiddenProtocol {
            toHidden = true
        }
        
        defer {
            if formHidden != toHidden {
                setNavigationBarHidden(toHidden, animated: animated)
            }
        }
        let vcs = faraday_popToViewController(viewController, animated: animated)
        vcs?.forEach({ vc in
            if let p = vc as? FaradayResultProvider {
                Faraday.callback(vc.fa.callbackToken, result: p.result)
            }
        })
        return vcs;
    }
    
    @objc fileprivate func faraday_popToRootViewController(animated: Bool) -> [UIViewController]? {
        if viewControllers.count <= 1 {
            return nil
        }
        var formHidden = false
        var toHidden = false
        
        if let _ = viewControllers.last as? FaradayNavigationBarHiddenProtocol {
            formHidden = true
        }
        if let _ = viewControllers.first as? FaradayNavigationBarHiddenProtocol {
            toHidden = true
        }
        
        defer {
            if formHidden != toHidden {
                setNavigationBarHidden(toHidden, animated: animated)
            }
        }
        let vcs = faraday_popToRootViewController(animated: animated)
        vcs?.forEach({ vc in
            if let p = vc as? FaradayResultProvider {
                Faraday.callback(vc.fa.callbackToken, result: p.result)
            }
        })
        return vcs;
    }
}

extension UIViewController {
      
    @objc fileprivate func faraday_dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        let callbackToken = self.fa.callbackToken
        if let p = self as? FaradayResultProvider {
            Faraday.callback(callbackToken, result: p.result)
        }
        faraday_dismiss(animated: flag, completion: completion)
    }
}
