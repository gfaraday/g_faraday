//
//  NotificationHandler.swift
//  g_faraday
//
//  Created by gix on 2020/9/24.
//

import Foundation

class NotificationHelper: NSObject, FlutterStreamHandler  {
    
    private var sink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        debugPrint("[Faraday warning] notification event canceled")
        return nil
    }
    
    func push(name: String, _ arguments: Any?) {
        assert(!name.isEmpty)
        var notification: [String: Any] = ["name": name]
        if let arg = arguments {
            notification["arguments"] = arg
        }
        
        sink?(notification)
    }
}
