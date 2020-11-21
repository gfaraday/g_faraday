//
//  FlutterEngine+Identifier.swift
//  g_faraday
//
//  Created by gix on 2020/11/19.
//

import Flutter

private struct AssociatedKeys {
    static var IdentifierKeyName = "faraday_IdentifierKeyName"
}

extension FaradayExtension where ExtendedType: FlutterEngine {
    
    internal var id: Int? {
        get {
            return objc_getAssociatedObject(UIViewController.self, &AssociatedKeys.IdentifierKeyName) as? Int
        }
        nonmutating set {
            if let newValue = newValue {
                objc_setAssociatedObject(UIViewController.self, &AssociatedKeys.IdentifierKeyName, newValue as Int?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    func generateNewId() -> Int {
        id = (id ?? 0) + 1
        return id!
    }
}

extension FlutterEngine: FaradayExtended { }
