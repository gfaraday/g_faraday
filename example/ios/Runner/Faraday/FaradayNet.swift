import Foundation

//  Created by faraday_cli on 2020-09-23 18:47:14.233496.
//
//    ___                   _
//   / __\_ _ _ __ __ _  __| | __ _ _   _
//  / _\/ _` | '__/ _` |/ _` |/ _` | | | |
// / / | (_| | | | (_| | (_| | (_| | |_| |
// \/   \__,_|_|  \__,_|\__,_|\__,_|\__, |
//                                  |___/
//
// GENERATED CODE BY FARADAY CLI - DO NOT MODIFY BY HAND


func flutterNetBridge(_ name: String, _ arguments: Any?, _ completion: @escaping (_ result: Any?) -> Void) -> Void {
    
    let args = arguments as? [String: Any]
    
    let method = name.uppercased(); // REQUEST/GET/PUT/POST/DELETE
    let query = args?["query"] as? [String: Any]
    let body = args?["body"] as? [String: Any]
    let additions = args?["additions"]
  
    completion(FlutterMethodNotImplemented);
}
