import Flutter
import UIKit

public class SwiftGFaradayPlugin: NSObject, FlutterPlugin {
    
    var netChannel: FlutterMethodChannel?
    var commonChannel: FlutterMethodChannel?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        //
        let channel = FlutterMethodChannel(name: "g_faraday", binaryMessenger: registrar.messenger())
        let commonChannel = FlutterMethodChannel(name: "g_faraday/common", binaryMessenger: registrar.messenger())
        let netChannel = FlutterMethodChannel(name: "g_faraday/net", binaryMessenger: registrar.messenger())
        
        let instance = SwiftGFaradayPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        Faraday.sharedInstance.setup(channel: channel)
        
        //
        instance.netChannel = netChannel
        instance.netChannel?.setMethodCallHandler({ call, result in
            guard call.method == "request" else {
                result(FlutterMethodNotImplemented)
                return
            }
            guard let netProvider = Faraday.sharedInstance.netProvider else {
                result(FlutterMethodNotImplemented)
                return
            }
            guard var args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "1", message: "arguments not valid", details: "\(call.arguments ?? "")"))
                return
            }
            guard let url = args.removeValue(forKey: "url") as? String, !url.isEmpty else {
                result(FlutterError(code: "2", message: "url not valid", details: "\(call.arguments ?? "")"))
                return
            }
            guard let method = args.removeValue(forKey: "method") as? String, !method.isEmpty else {
                result(FlutterError(code: "3", message: "method not valid", details: "\(call.arguments ?? "")"))
                return
            }
            let queryParameters = args.removeValue(forKey: "queryParameters") as? [String: Any]
            let body = args.removeValue(forKey: "body")
            
            netProvider.request(url, method: method, queryParameters: queryParameters, body: body, addtionArguments: args.isEmpty ? nil : args) { r in
                result(r)
            }
        })
        
        //
        instance.commonChannel = commonChannel
        instance.commonChannel?.setMethodCallHandler({ call, result in
            guard let cp = Faraday.sharedInstance.commonHandler, cp.canHandle(call.method, arguments: call.arguments) else {
                result(FlutterMethodNotImplemented)
                return
            }
            cp.handle(call.method, arguments: call.arguments, completion: result)
        })
        
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "getPlatformVersion") {
            result("iOS " + UIDevice.current.systemVersion)
        } else if (call.method == "pushNativePage") {
            Faraday.sharedInstance.push(native: call.arguments, callback: result)
        } else if (call.method == "popContainer") {
            Faraday.sharedInstance.pop(flutterContainer: call.arguments, callback: result)
        } else if (call.method == "disableHorizontalSwipePopGesture") {
            Faraday.sharedInstance.wrapper.viewController?.disableHorizontalSwipePopGesture(disable: call.arguments as? Bool ?? false)
            result(nil)
        }
    }
    
}
