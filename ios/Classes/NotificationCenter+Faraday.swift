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
    static func post(name: String, _ object: Any? = nil) {
        Faraday.sharedInstance.postNotification(name: name, object)
    }
}
