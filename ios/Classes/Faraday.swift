//
//  Faraday.swift
//  g_faraday
//
//  Created by gix on 2020/9/2.
//

import Foundation
import Flutter

/// Manager flutter native viewcontroller push&pop、present&dissmis
public protocol FaradayNavigationDelegate: AnyObject {
    
    
    /// flutter widget request `open`(push or present) a new native viewcontroller
    /// - Parameters:
    ///   - name: native or flutter route name
    ///   - arguments: route arguments
    /// - Returns: pushed viewController
    func push(_ name: String, arguments: Any?, options: Options, callback token: CallbackToken)
    
    /// flutter widget require disbale native swipeback func
    /// - Parameter disable: disable or not
    func disableHorizontalSwipePopGesture(_ disable: Bool)
    
    /// flutter widget request pop(dismiss) current FaradayFlutterViewcontroller
    /// - Parameters:
    ///   - viewController: current viewcontroller attached on engine
    /// - Returns: pop succeed or not
    func pop(_ viewController: FaradayFlutterViewController) -> Bool
}

public extension FaradayNavigationDelegate {
    
    func disableHorizontalSwipePopGesture(_ disable: Bool) {
        Faraday.default.currentFlutterViewController?.disableHorizontalSwipePopGesture(disable: disable)
    }
        
    func pop(_ viewController: FaradayFlutterViewController) -> Bool {
        if (viewController.fa.isModal) {
            viewController.dismiss(animated: true, completion: nil)
        } else {
            viewController.navigationController?.popViewController(animated: true)
        }
        return true
    }
}

public protocol FaradayHttpProvider: AnyObject {
    
    func request(method: String, url: String, parameters: [String: Any]?, headers: [String: String]?, completion: @escaping (_ result: Any?) -> Void) -> Void
}

public typealias FaradayHandler = (_ name: String, _ arguments: Any?, _ completion: @escaping (_ result: Any?) -> Void) -> Void

/**
 
    核心类，负责管理`Flutter Engine、ViewController`以及其他一些辅助功能主要包含`net、common`

*/
public class Faraday {
    
    public static let `default` = Faraday()
    
    private init() {
        debugPrint("🚀🚀Faraday default instance initailed !")
    }
    
    private weak var navigatorDelegate: FaradayNavigationDelegate? // not retain
    private weak var netProvider: FaradayHttpProvider?
    
    private var commonHandler: FaradayHandler?
    
    private var channel: FlutterMethodChannel?
    private var netChannel: FlutterMethodChannel?
    private var commonChannel: FlutterMethodChannel?
    
    fileprivate var notificationChannel: FlutterMethodChannel?
    
    public private(set) var engine: FlutterEngine?
    
    private var callbackCache = [UUID: FlutterResult]()
    
    /// 当前attach在Engine的viewController 不一定可见
    public var currentFlutterViewController: FaradayFlutterViewController? {
        return engine?.viewController as? FaradayFlutterViewController
    }
    
    //
    func setup(messenger: FlutterBinaryMessenger) {
        
        channel = FlutterMethodChannel(name: "g_faraday", binaryMessenger: messenger)
        channel?.resizeBuffer(2)
        
        channel?.setMethodCallHandler({ [unowned self] (call, result) in
            if (call.method == "pushNativePage") {
                self.push(native: call.arguments, callback: result)
            } else if (call.method == "popContainer") {
                self.pop(flutterContainer: call.arguments, callback: result)
            } else if (call.method == "disableHorizontalSwipePopGesture") {
                self.disableHorizontalSwipePopGesture(arguments: call.arguments, callback: result)
            } else if (call.method == "reCreateLastPage") {
                let vc = self.currentFlutterViewController
                result(vc?.id)
                vc?.createFlutterPage()
            }
        })
        
        notificationChannel = FlutterMethodChannel(name: "g_faraday/notification", binaryMessenger: messenger)
        notificationChannel?.setMethodCallHandler({ (call, result) in
            let args = call.arguments as? Dictionary<String, Any>
            NotificationCenter.default.post(name: .init(rawValue: call.method), object: args?["arguments"])
            result(true)
        })
        
        netChannel = FlutterMethodChannel(name: "g_faraday/net", binaryMessenger: messenger)
        netChannel?.setMethodCallHandler({ [unowned self] (call, r) in
            if let np = self.netProvider {
                let args = call.arguments as? [String: Any]
                
                let method = call.method; // REQUEST/GET/PUT/POST/DELETE
                guard let url = args?["url"] as? String else {
                    r(FlutterError(code: "1", message: "url must not be null", details: args))
                    return
                }
                
                let parameters = args?["parameters"] as? [String: Any]
                let headers = args?["headers"] as? [String: String]
                
                np.request(method: method, url: url, parameters: parameters, headers: headers, completion: r)
            }
        })
        
        
        if let h = commonHandler {
            commonChannel = FlutterMethodChannel(name: "g_faraday/common", binaryMessenger: messenger)
            commonChannel?.setMethodCallHandler({ (call, r) in
                h(call.method, call.arguments, r)
            })
        }
        
        if let rawEngine = messenger as? FlutterEngine {
            if (engine == nil || engine != rawEngine) {
                engine = rawEngine
            }
        }
    }
    
    /// 入口方法，用于启动Flutter Engine、 注册插件
    /// - Parameters:
    ///   - navigatorDelegate: native 侧路由代理
    ///   - automaticallyRegisterPlugins: 是否自动注册插件，如果不自动注册请及时手动注册所有插件
    ///
    public func startFlutterEngine(navigatorDelegate: FaradayNavigationDelegate,
                                   httpProvider: FaradayHttpProvider? = nil,
                                   commonHandler: FaradayHandler? = nil,
                                   automaticallyRegisterPlugins: Bool = true,
                                   entrypoint: String = "main") {
        self.navigatorDelegate = navigatorDelegate
        self.netProvider = httpProvider
        self.commonHandler = commonHandler
        
        engine = FlutterEngine(name: "io.flutter.faraday", project: nil, allowHeadlessExecution: true)
        
        // 1.1 run
        guard engine!.run(withEntrypoint: entrypoint) else {
            fatalError("run FlutterEngine failed")
        }
        
        if (automaticallyRegisterPlugins) {
            guard let clazz: AnyObject = NSClassFromString("GeneratedPluginRegistrant") else {
                fatalError("missing GeneratedPluginRegistrant")
            }
            
            let registerSelector: Selector = Selector(("registerWithRegistry:"))
            let _ = clazz.perform(registerSelector, with: engine)
        }
    }
   
    /// 强制刷新某个 `FaradayFlutterViewController` 实例的渲染状态。 一般情况下不需要调用此方法。
    /// 推荐在FaradayFlutterViewController生命周期没有按照预期执行的时候调用
    /// 例如 在iOS13 以上从FaradayFlutterViewController `present`新页面的时候 生命周期调用不符合预期
    /// - Parameter viewController: 需要刷新状态的FaradayFlutterViewController实例
    public static func refreshViewController(_ viewController: FaradayFlutterViewController) {
        viewController.engine?.viewController = nil
        
        viewController.viewWillAppear(false)
        viewController.viewDidLayoutSubviews()
        viewController.viewDidAppear(false)
    }
    
    static func callback(_ token: CallbackToken?, result: Any?) {
        if let t = token {
            if let cb = Faraday.default.callbackCache.removeValue(forKey: t) {
                cb(result)
            }
        }
    }
  
    func push(native arguments: Any?, callback: @escaping FlutterResult) {
        guard let arg = arguments as? Dictionary<String, Any>, let name = arg["name"] as? String else {
            fatalError("arguments invalid")
        }
        
        let token = UUID()
        // 这里是有可能打开一个 flutter页面的
        navigatorDelegate?.push(name, arguments: arg["arguments"], options: Options(arg["options"] as? [String: Any]), callback: token)
        callbackCache[token] = callback
    }
    
    func pop(flutterContainer arguments: Any?, callback: FlutterResult) {
        guard let viewController = currentFlutterViewController else {
            debugPrint("[Faraday] Error current flutter viewController not found. can't pop");
            callback(false)
            return
        }
        viewController.callbackValueToCreator(arguments)
        
        // callbackToken != nil 说明这是一个通过 flutter页面打开的一个新引擎， 需要手动调用callback以传值给flutter端
        if (viewController.callbackToken != nil) {
            viewController.fa.callback(result: arguments)
        }
        
        //
        callback(navigatorDelegate?.pop(viewController) ?? false)
    }
    
    func disableHorizontalSwipePopGesture(arguments: Any?, callback: FlutterResult) {
        Faraday.default.navigatorDelegate?.disableHorizontalSwipePopGesture(arguments as? Bool ?? false)
        callback(true)
    }
    
}

// 处理 page 生命周期相关内容
extension Faraday {

    enum PageState {
        
        case create(String, Any?, Int, Bool) // name, arguments, seq, backgroundmode
        case show(Int) // id
//        case hiden(Int) // id
        case dealloc(Int) //id
        
        var info: (String, Any?) {
            switch self {
            case .create(let name, let arguments, let id, let backgroundClear):
                return ("pageCreate", ["name": name, "args": arguments, "id": id, "background_mode": backgroundClear ? "transparent" : "opaque"])
            case .show(let id):
                return ("pageShow", id)
//            case .hiden(let seq):
//                return ("pageHidden", seq)
            case .dealloc(let id):
                return ("pageDealloc", id)
            }
        }
    }
    
    static func sendPageState(_ state: Faraday.PageState, result: @escaping (Bool) -> Void) {
        let faraday = Faraday.default
        let info = state.info;
        faraday.channel?.invokeMethod(info.0, arguments: info.1, result: { r in
            if (r is FlutterError) {
                fatalError((r as! FlutterError).message ?? "unkonwn error")
            } else {
                result(r as? Bool ?? false)
            }
        })
    }
}

// 发送通知
public extension Faraday {
    
    /// 发送通知到 Flutter
    /// Flutter 可以通过 NotificationListener<NotificationListener> 来监听
    func postNotification(_ name: String, arguments: Any? = nil) {
        guard notificationChannel != nil else {
            fatalError("start flutter engine before push notification.")
        }
        notificationChannel?.invokeMethod(name, arguments: arguments)
    }
}

