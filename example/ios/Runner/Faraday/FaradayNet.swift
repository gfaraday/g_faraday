//
//  FaradayNet.swift
//  Runner
//
//  Created by gix on 2020/9/22.
//

import Foundation

func flutterNetBridge(_ name: String, _ arguments: Any?, _ completion: @escaping (_ result: Any?) -> Void) -> Void {
    
    let args = arguments as? [String: Any]
    
    let method = name.uppercased(); // REQUEST/GET/PUT/POST/DELETE
    let query = args?["query"] as? [String: Any]
    let body = args?["body"] as? [String: Any]
    let additions = args?["additions"]
  
    completion(FlutterMethodNotImplemented);
}
