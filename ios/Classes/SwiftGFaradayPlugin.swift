import Flutter
import UIKit

public class SwiftGFaradayPlugin: NSObject, FlutterPlugin {
    
    var netChannel: FlutterMethodChannel?
    var commonChannel: FlutterMethodChannel?
       
    public static func register(with registrar: FlutterPluginRegistrar) {
        //
        let channel = FlutterMethodChannel(name: "g_faraday", binaryMessenger: registrar.messenger())
        let netChannel = FlutterMethodChannel(name: "g_faraday/net", binaryMessenger: registrar.messenger())
        let commonChannel = FlutterMethodChannel(name: "g_faraday/common", binaryMessenger: registrar.messenger())
        
        let instance = SwiftGFaradayPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        Faraday.sharedInstance.setup(channel: channel)
        
        instance.netChannel = netChannel
        netChannel.setMethodCallHandler { (call, r) in
            Faraday.sharedInstance.netHandler?.handle(call.method, arguments: call.arguments, completion: r)
        }
        
        instance.commonChannel = commonChannel
        commonChannel.setMethodCallHandler { (call, r) in
            Faraday.sharedInstance.commonHandler?.handle(call.method, arguments: call.arguments, completion: r)
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
