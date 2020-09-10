//
//  Faraday.swift
//  g_faraday
//
//  Created by gix on 2020/9/2.
//

import Foundation
import Flutter

public typealias CallbackToken = UUID

public protocol FaradayNavigationDelegate: NSObjectProtocol {
    
    // open native view controller
    func push(_ callbackToken: CallbackToken, name: String, isFlutterRoute: Bool, isPresent: Bool, arguments: Dictionary<String, Any>?)
    
    // close native view controller
    func pop() -> FaradayFlutterViewController?
}

public protocol FaradayNetProvider {
    
    func request(_ url: String, method: String, queryParameters: [String: Any]?, body: Any?, addtionArguments: [String: Any]?, completionHandler: @escaping (Any?) -> Void)
}

public protocol FaradayCommonHandler {
    
    func canHandle(_ method: String, arguments: Any?) -> Bool
    
    func handle(_ method: String, arguments: Any?,  completion: @escaping (Any?) -> Void)
}

public enum PageState {
    
    case create(String, Any?) // name, arguments
    case show(Int) // seq
    case hiden(Int) // seq
    case dealloc(Int) //seq
    
    var info: (String, Any?) {
        switch self {
        case .create(let name, let arguments):
            return ("pageCreate", ["name": name, "args": arguments])
        case .show(let seq):
            return ("pageShow", seq)
        case .hiden(let seq):
            return ("pageHidden", seq)
        case .dealloc(let seq):
            return ("pageDealloc", seq)
        }
    }
}

public class Faraday {
    
    public static let sharedInstance = Faraday()
    
    public var currentFaradayViewController: FaradayFlutterViewController? {
        return wrapper.engine.viewController as? FaradayFlutterViewController
    }
    
    private init() {
        debugPrint("Faraday `sharedInstance` initailed !")
    }
    
    private weak var navigatorDelegate: FaradayNavigationDelegate? // not retain
    private(set) var netProvider: FaradayNetProvider? // will be retained
    private(set) var commonHandler: FaradayCommonHandler? // will be retained
    
    private var channel: FlutterMethodChannel?
    
    let wrapper = EngineWrapper()
    
    private var callbackCache = [UUID: FlutterResult]()
    
    func setup(channel: FlutterMethodChannel) {
        self.channel = channel;
    }
    
    public func startFlutterEngine(navigatorDelegate: FaradayNavigationDelegate, netProvider: FaradayNetProvider? = nil, commonHandler: FaradayCommonHandler? = nil) -> Bool {
        self.navigatorDelegate = navigatorDelegate
        self.netProvider = netProvider
        self.commonHandler = commonHandler
        wrapper.warm()
        return true
    }
    
    // create new flutter view controller
    public static func createFlutterViewController(_ name: String, arguments: Any? = nil, callback:  @escaping (Any?) -> () = { r in debugPrint("result not be used \(String(describing: r))")}) -> FlutterViewController {
        
        let faraday = Faraday.sharedInstance;
        
        let vc = FaradayFlutterViewController(name, arguments: arguments, engine: faraday.wrapper.engine, callback: callback)
        
        return vc
    }
    
    public static func sendPageState(_ state: PageState, result: @escaping (Any?) -> Void) {
        let info = state.info;
        Faraday.sharedInstance.channel?.invokeMethod(info.0, arguments: info.1, result: { r in
            result(r)
        })
    }
    
    public static func refreshViewController(_ viewController: FaradayFlutterViewController) {
        viewController.engine?.viewController = nil
        
        viewController.viewWillAppear(false)
        viewController.viewDidLayoutSubviews()
        viewController.viewDidAppear(false)
    }
        
    public static func callback(_ token: CallbackToken?, result: Any?) {
        if let t = token {
            if let cb = Faraday.sharedInstance.callbackCache.removeValue(forKey: t) {
                cb(result)
            }
        }
    }
       
    func push(native arguments: Any?, callback: @escaping FlutterResult) {
        let uuid = UUID()
        callbackCache[uuid] = callback
        
        guard let arg = arguments as? Dictionary<String, Any>, let name = arg["name"] as? String else {
            fatalError("arguments invalid")
        }
        
        let isFlutterRoute = arg["isFlutterRoute"] as? Bool ?? false
        let isPresent = arg["present"] as? Bool ?? false
        
        navigatorDelegate?.push(uuid, name: name, isFlutterRoute: isFlutterRoute, isPresent: isPresent, arguments: arg["arguments"] as? [String: Any])
    }
    
    func pop(flutterContainer arguments: Any?, callback: FlutterResult) {
        let vc = navigatorDelegate?.pop()
        vc?.callback?(arguments)
        callback(nil)
    }
    
}
