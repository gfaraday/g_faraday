String _header = '''//  Created by faraday_cli on ${DateTime.now()}.
//
//    ___                   _
//   / __\\_ _ _ __ __ _  __| | __ _ _   _
//  / _\\/ _` | '__/ _` |/ _` |/ _` | | | |
// / / | (_| | | | (_| | (_| | (_| | |_| |
// \\/   \\__,_|_|  \\__,_|\\__,_|\\__,_|\\__, |
//                                  |___/
//
// GENERATED CODE BY FARADAY CLI - DO NOT MODIFY BY HAND
''';

String k_common = '''import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

$_header

interface Common: MethodChannel.MethodCallHandler {
    // ---> interface

    fun defaultHandle(call: MethodCall, result: MethodChannel.Result): Boolean {
        val args: Map<*, *> = call.arguments as? Map<*, *> ?: emptyMap<Any, Any>()
        // ---> impl

        return false
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (!defaultHandle(call, result)) {
            print("Faraday->Warning \${call.method} not handle. argument: \${call.arguments}")
        }
    }
}
''';

String k_route = '''import android.app.Activity
import com.yuxiaor.flutter.g_faraday.FaradayActivity

$_header

sealed class FlutterRoute(val routeName: String, val routeArguments: HashMap<String, Any>?) {
// ---> sealed
}

/**
 * Navigate to flutter
 * @param route flutter router
 *
 * override [Activity.onActivityResult] in your Activity to got the result
 */
fun Activity.openFlutter(route: FlutterRoute, requestCode: Int) {
    startActivityForResult(FaradayActivity.build(this, route.routeName, route.routeArguments), requestCode)
}
''';

String s_route = '''import Foundation
import g_faraday

$_header

enum FaradayRoute {
    // ---> enum

    var page: (name: String, arguments: Any?) {
        switch self {
            // ---> enum_page
        }
    }
}

extension Faraday {
    
    static func createFlutterViewController(route: FaradayRoute, callback:  @escaping (Any?) -> () = { r in debugPrint("result don't be used \(String(describing: r))")}) -> FaradayFlutterViewController {
        let page = route.page
        return Faraday.createFlutterViewController(page.name, arguments: page.arguments, callback: callback)
    }
}

''';

String s_common = '''import Foundation

$_header

protocol FaradayCommonHandler {
    
    // ---> protocol
    
    func handle(_ name: String, _ arguments: Any?, _ completion: @escaping (_ result: Any?) -> Void) -> Void
}

extension FaradayCommonHandler {
    
    func handle(_ name: String, _ arguments: Any?, _ completion: @escaping (_ result: Any?) -> Void) -> Void {
        if (!defaultHandle(name,arguments,completion)) {
            debugPrint("Faraday->Warning \\(name) not handle. argument: \\(arguments ?? "")")
        }
    }
    
    func defaultHandle(_ name: String, _ arguments: Any?, _ completion: @escaping (_ result: Any?) -> Void) -> Bool {
        let args = arguments as? Dictionary<String, Any>
        // ---> impl
        return false
    }
    
}

''';
