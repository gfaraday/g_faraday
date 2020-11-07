//
//  NotificationCenter+Faraday.swift
//  g_faraday
//
//  Created by gix on 2020/9/24.
//

import Foundation

public extension FaradayExtension where ExtendedType: NotificationCenter {
    
    // post notification to flutter engine
    // Flutter 可以通过 FaradayNotificationListener 来监听
    static func post(name: String, object arguments: Any? = nil) {
        Faraday.default.postNotification(name, arguments: arguments)
    }
}
