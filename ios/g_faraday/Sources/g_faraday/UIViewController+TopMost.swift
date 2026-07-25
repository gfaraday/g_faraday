//
//  UIViewController+TopMost.swift
//  g_faraday
//
//  Created by gix on 2020/9/21.
//

import UIKit

public extension FaradayExtension where ExtendedType: UIViewController {

    /// 当前 App 的 key window（UIScene 感知）
    ///
    /// 查找顺序：
    /// 1. `foregroundActive` 状态 scene 中的 key window
    /// 2. `foregroundInactive` 状态 scene 中的 key window（覆盖启动早期/过渡态）
    /// 3. 任意 scene 中第一个非 hidden 的 window
    /// 4. 兜底：`UIApplication.shared.windows`（兼容未迁移 scene 的老宿主，以及 scene 尚未连接的启动早期）
    ///
    /// - Note: iOS 26 SDK 之后 `UIApplication.shared.windows` 在 scene 宿主中会静默返回空数组，
    ///   因此必须 scene 优先，老逻辑仅作兜底。
    static var keyWindow: UIWindow? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }

        for state in [UIScene.ActivationState.foregroundActive, .foregroundInactive] {
            let windows = scenes.filter { $0.activationState == state }.flatMap { $0.windows }
            if let keyWindow = windows.first(where: { $0.isKeyWindow }) ?? windows.first(where: { !$0.isHidden }) {
                return keyWindow
            }
        }

        if let window = scenes.flatMap({ $0.windows }).first(where: { !$0.isHidden }) {
            return window
        }

        // 兜底：未迁移 scene 的老宿主（或 scene 尚未连接的启动早期）
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
    }

    /// Returns the current application's top most view controller.
    static var topMost: UIViewController? {
        return self.topMost(of: self.keyWindow?.rootViewController)
    }
    
    /// Returns the top most view controller from given view controller's stack.
    static func topMost(of viewController: UIViewController?) -> UIViewController? {
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
