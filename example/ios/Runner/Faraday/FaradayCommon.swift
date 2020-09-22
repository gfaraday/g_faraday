//
//  FaradayCommon.swift
//  Runner
//
//  Created by gix on 2020/9/22.
//

//
//    ___                   _
//   / __\_ _ _ __ __ _  __| | __ _ _   _
//  / _\/ _` | '__/ _` |/ _` |/ _` | | | |
// / / | (_| | | | (_| | (_| | (_| | |_| |
// \/   \__,_|_|  \__,_|\__,_|\__,_|\__, |
//                                  |___/
//
// GENERATED CODE BY FARADAY CLI - DO NOT MODIFY BY HAND

import Foundation


protocol FaradayCommonHandler {
    
    // ---> protocol
    // ---> protocol cli_demo/demo.dart|DemoApp

    /// commnets
    /// will be
    /// send
    /// to native
    func getSomeData(_ id: String, _ optionalArg: Bool?) -> Any?

    /// NO COMMENTS
    func setSomeData(_ data: Any, _ id: String) -> Any?
    // <--- protocol cli_demo/demo.dart|DemoApp
    
    func handle(_ name: String, _ arguments: Any?, _ completion: @escaping (_ result: Any?) -> Void) -> Void
}

extension FaradayCommonHandler {
    
    func handle(_ name: String, _ arguments: Any?, _ completion: @escaping (_ result: Any?) -> Void) -> Void {
        if (!defaultHandle(name,arguments,completion)) {
            debugPrint("Faraday->Warning \(name) not handle. argument: \(arguments ?? "")")
        }
    }
    
    func defaultHandle(_ name: String, _ arguments: Any?, _ completion: @escaping (_ result: Any?) -> Void) -> Bool {
        let args = arguments as? Dictionary<String, Any>
        // ---> impl
        // ---> impl cli_demo/demo.dart|DemoApp
        if (name == "cli_demo/demo.dart|DemoApp#getSomeData") {
            guard let id = args?["id"] as? String else {
                fatalError("argument: id not valid")
            }
            let optionalArg = args?["optionalArg"] as? Bool 
            // invoke getSomeData
            completion(getSomeData(id, optionalArg))
            return true
        }
        if (name == "cli_demo/demo.dart|DemoApp#setSomeData") {
            guard let data = args?["data"] else {
                fatalError("argument: data not valid")
            }
            guard let id = args?["id"] as? String else {
                fatalError("argument: id not valid")
            }
            // invoke setSomeData
            completion(setSomeData(data, id))
            return true
        }
        // <--- impl cli_demo/demo.dart|DemoApp
        return false
    }
    
}
