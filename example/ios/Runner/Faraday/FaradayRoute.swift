import Foundation
import g_faraday

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


enum FaradayRoute {
    // ---> enum

    var page: (name: String, arguments: Any?) {
        switch self {
            // ---> enum_page
        }
    }
}

extension Faraday {
    
    static func createFlutterViewController(route: FaradayRoute, callback:  @escaping (Any?) -> () = { r in debugPrint("result don't be used (String(describing: r))")}) -> FaradayFlutterViewController {
        let page = route.page
        return Faraday.createFlutterViewController(page.name, arguments: page.arguments, callback: callback)
    }
}

