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
public protocol FaradayNavigationBarHiddenProtocol where Self: UIViewController {
    var isFaradayNavigationBarHidden: Bool { get }
}

extension FaradayNavigationBarHiddenProtocol {
    public var isFaradayNavigationBarHidden: Bool {
        return true
    }
}
// 给 NavigationController 设置默认的bar hidden
public protocol FaradayNavigationControllerBarHiddenProtocol where Self: UINavigationController {
    var isFaradayNavigationBarHidden: Bool { get }
}

extension FaradayFlutterViewController: FaradayNavigationBarHiddenProtocol { }

public extension FaradayExtension where ExtendedType: UINavigationController {
        
   static func automaticallyHandleNavigationBarHidden() {
        swizzle(UINavigationController.self, #selector(UINavigationController.pushViewController(_:animated:)), #selector(UINavigationController.faraday_pushViewController(_:animated:)))
        swizzle(UINavigationController.self, #selector(UINavigationController.popViewController(animated:)), #selector(UINavigationController.faraday_popViewController(animated:)))
        swizzle(UINavigationController.self, #selector(UINavigationController.popToViewController(_:animated:)), #selector(UINavigationController.faraday_popToViewController(_:animated:)))
        swizzle(UINavigationController.self, #selector(UINavigationController.popToRootViewController(animated:)), #selector(UINavigationController.faraday_popToRootViewController(animated:)))
    }
    
    @discardableResult
    func popViewController(withResult result: Any?, animated: Bool) -> UIViewController? {
        let vc = type.popViewController(animated: animated)
        vc?.fa.callback(result: result)
        return vc
    }
}

extension UINavigationController {
    func isNavigationBarHidden(at viewController: UIViewController?) -> Bool {
        if let vc = viewController as? FaradayNavigationBarHiddenProtocol {
            return vc.isFaradayNavigationBarHidden
        } else if let nav = self as? FaradayNavigationControllerBarHiddenProtocol {
            return nav.isFaradayNavigationBarHidden
        } else {
            return false
        }
    }
    
    @objc fileprivate func faraday_pushViewController(_ viewController: UIViewController, animated: Bool) {
        let fromHidden = isNavigationBarHidden(at: viewControllers.last)
        let toHidden = isNavigationBarHidden(at: viewController)
        
        faraday_pushViewController(viewController, animated: animated)
        if fromHidden != toHidden {
            setNavigationBarHidden(toHidden, animated: animated)
        }
    }
    
    @objc fileprivate func faraday_popViewController(animated: Bool) -> UIViewController? {
        if viewControllers.count <= 1 {
            return nil
        }
        let fromHidden = isNavigationBarHidden(at: viewControllers.last)
        let toHidden = isNavigationBarHidden(at: viewControllers[viewControllers.count - 2])
        
        defer {
            if fromHidden != toHidden {
                setNavigationBarHidden(toHidden, animated: animated)
            }
        }
        
        return faraday_popViewController(animated: animated)
    }
    
    @objc fileprivate func faraday_popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if viewControllers.count <= 1 {
            return nil
        }
        let fromHidden = isNavigationBarHidden(at: viewControllers.last)
        let toHidden = isNavigationBarHidden(at: viewController)
        
        defer {
            if fromHidden != toHidden {
                setNavigationBarHidden(toHidden, animated: animated)
            }
        }
        
        return faraday_popToViewController(viewController, animated: animated)
    }
    
    @objc fileprivate func faraday_popToRootViewController(animated: Bool) -> [UIViewController]? {
        if viewControllers.count <= 1 {
            return nil
        }
        let fromHidden = isNavigationBarHidden(at: viewControllers.last)
        let toHidden = isNavigationBarHidden(at: viewControllers.first)
        
        defer {
            if fromHidden != toHidden {
                setNavigationBarHidden(toHidden, animated: animated)
            }
        }
        return faraday_popToRootViewController(animated: animated)
    }
}
