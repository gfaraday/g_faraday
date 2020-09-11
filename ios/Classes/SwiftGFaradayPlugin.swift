import Flutter
import UIKit

public class SwiftGFaradayPlugin: NSObject, FlutterPlugin {
       
    public static func register(with registrar: FlutterPluginRegistrar) {
        //
        let channel = FlutterMethodChannel(name: "g_faraday", binaryMessenger: registrar.messenger())
        
        let instance = SwiftGFaradayPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        Faraday.sharedInstance.setup(channel: channel)
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
