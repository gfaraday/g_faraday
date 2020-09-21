import Flutter
import UIKit

public class SwiftGFaradayPlugin: NSObject, FlutterPlugin {
    
    var netChannel: FlutterMethodChannel?
    var commonChannel: FlutterMethodChannel?
       
    public static func register(with registrar: FlutterPluginRegistrar) {
        //
        let channel = FlutterMethodChannel(name: "g_faraday", binaryMessenger: registrar.messenger())
        
        let instance = SwiftGFaradayPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        Faraday.sharedInstance.setup(channel: channel)
        
        if let h = Faraday.sharedInstance.netHandler {
            instance.netChannel = FlutterMethodChannel(name: "g_faraday/net", binaryMessenger: registrar.messenger())
            instance.netChannel?.setMethodCallHandler({ (call, r) in
                h(call.method, call.arguments, r)
            })
        }
        
        if let h = Faraday.sharedInstance.commonHandler {
            instance.commonChannel = FlutterMethodChannel(name: "g_faraday/common", binaryMessenger: registrar.messenger())
            instance.commonChannel?.setMethodCallHandler({ (call, r) in
                h(call.method, call.arguments, r)
            })
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "pushNativePage") {
            Faraday.sharedInstance.push(native: call.arguments, callback: result)
        } else if (call.method == "popContainer") {
            Faraday.sharedInstance.pop(flutterContainer: call.arguments, callback: result)
        } else if (call.method == "disableHorizontalSwipePopGesture") {
            Faraday.sharedInstance.disableHorizontalSwipePopGesture(arguments: call.arguments, callback: result)
        }
    }
    
}
