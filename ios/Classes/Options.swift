//
//  Options.swift
//  g_faraday
//
//  Created by gix on 2020/12/29.
//

import Foundation

public struct Options {
    
    let raw: [String: Any]?
    
    init(_ value: [String: Any]?) {
        raw = value
    }
    
    public var animated: Bool {
        return get(key: "_faraday.animated", defaultValue: false)
    }
    
    public var present: Bool {
        return get(key: "_faraday.present", defaultValue: false)
    }
    
    public var isFlutterRoute: Bool {
        return get(key: "_faraday.flutter", defaultValue: false)
    }
    
    public func get<T>(key: String, defaultValue: T) -> T {
        return raw?[key] as? T ?? defaultValue
    }
}
