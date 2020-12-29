import Foundation

//  Created by faraday_cli on 2020-09-24 09:48:07.370618.
//
//    ___                   _
//   / __\_ _ _ __ __ _  __| | __ _ _   _
//  / _\/ _` | '__/ _` |/ _` |/ _` | | | |
// / / | (_| | | | (_| | (_| | (_| | |_| |
// \/   \__,_|_|  \__,_|\__,_|\__,_|\__, |
//                                  |___/
//
// GENERATED CODE BY FARADAY CLI - DO NOT MODIFY BY HAND


protocol FaradayCommonHandler {

    // ---> protocol

    func handle(_ name: String, _ arguments: Any?, _ completion: @escaping (_ result: Any?) -> Void) -> Void
}

extension FaradayCommonHandler {

    func handle(_ name: String, _ arguments: Any?, _ completion: @escaping (_ result: Any?) -> Void) -> Void {
        if (!defaultHandle(name,arguments,completion)) {
            debugPrint("Faraday->Warning \(name) not handle. argument: \(arguments ?? "")")
        }
    }

    func defaultHandle(_ name: String, _ arguments: Any?, _ completion: @escaping (_ result: Any?) -> Void) -> Bool {
//        let args = arguments as? Dictionary<String, Any>
        // ---> impl
        return false
    }

}

