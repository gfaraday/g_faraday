import Foundation
import g_faraday

//  Created by faraday_cli on 2020-09-23 17:16:33.109903.
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
    // ---> enum cli_demo/demo.dart|DemoApp
    case demoHome
    case demoHome1(_ id: String)
    case demoHome2(_ name: String)
    /// comments open demo home
    case demoHome3
    // <--- enum cli_demo/demo.dart|DemoApp

    var page: (name: String, arguments: Any?) {
        switch self {
            // ---> enum_page
            // ---> enum_page cli_demo/demo.dart|DemoApp
            case .demoHome:
                return ("demo_home", nil)
            case let .demoHome1(id):
                return ("demo_home1", ["id": id])
            case let .demoHome2(name):
                return ("demo_home2", ["name": name])
            case .demoHome3:
                return ("demo_home3", nil)
            // <--- enum_page cli_demo/demo.dart|DemoApp
        }
    }
}

extension Faraday {
    
    static func createFlutterViewController(route: FaradayRoute, callback:  @escaping (Any?) -> () = { r in debugPrint("result don't be used (String(describing: r))")}) -> FaradayFlutterViewController {
        let page = route.page
        return Faraday.createFlutterViewController(page.name, arguments: page.arguments, callback: callback)
    }
}