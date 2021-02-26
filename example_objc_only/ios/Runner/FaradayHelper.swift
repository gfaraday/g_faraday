//
//  Test.swift
//  Runner
//
//  Created by gix on 2021/2/25.
//

import Foundation
import g_faraday

@objc class FaradayHelper: NSObject {
    
    @objc static func enableAutomaticallyExtension() {
        // 自动处理导航栏
        UINavigationController.fa.automaticallyHandleNavigationBarHidden()
        // 自动回调空值到flutter侧，避免flutter侧 await 一直不返回
        UIViewController.fa.automaticallyCallbackNullToFlutter()
    }
    
    @objc static func startFlutterEngine(navigatorDelegate: FaradayNavigationDelegate,
                                         httpProvider: FaradayHttpProvider? = nil,
                                         commonHandler: FaradayHandler? = nil) {
        Faraday.default.startFlutterEngine(navigatorDelegate: navigatorDelegate, httpProvider: httpProvider, commonHandler: commonHandler)
    }
    
    @objc static var currentFlutterViewController: FaradayFlutterViewController? {
        return Faraday.default.currentFlutterViewController
    }
    
    @objc static func postNotification(_ name: String, arguments: Any? = nil) {
        Faraday.default.postNotification(name, arguments: arguments)
    }
    
    @objc static func enableCallback(_ viewController: FaradayFlutterViewController, callback token: CallbackToken) {
        viewController.fa.enableCallback(with: token)
    }
}
