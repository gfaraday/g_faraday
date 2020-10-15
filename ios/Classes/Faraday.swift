//
//  Faraday.swift
//  g_faraday
//
//  Created by gix on 2020/9/2.
//

import Foundation
import Flutter

//
public typealias CallbackToken = UUID

/// Manager flutter native viewcontroller push&pop、present&dissmis
public protocol FaradayNavigationDelegate: NSObjectProtocol {
    
    
    /// flutter widget request `open`(push or present) a new native viewcontroller
    /// - Parameters:
    ///   - callbackToken: used callback result to flutter widget. ```Faraday.callback(token, result)```
    ///   - name: native or flutter route name
    ///   - isFlutterRoute: indicator this route is flutter route. if this is flutter route you need create a new `FaradayFlutterViewController` instance and `open` it
    ///   - isPresent: require present or push
    ///   - arguments: route arguments
    func push(_ callbackToken: CallbackToken, name: String, isFlutterRoute: Bool, isPresent: Bool, arguments: Dictionary<String, Any>?)
    
    
    /// flutter widget require disbale native swipe back func
    /// - Parameter disable: disable or not
    func disableHorizontalSwipePopGesture(_ disable: Bool)
    
    /// flutter widget request pop(dismiss) current FaradayFlutterViewcontroller
    func pop() -> FaradayFlutterViewController?
}

public protocol FaradayHttpProvider: NSObjectProtocol {
    
    func request(method: String, url: String, parameters: [String: Any]?, headers: [String: String]?, completion: @escaping (_ result: Any?) -> Void) -> Void
}

public protocol FaradayMethodHandler: NSObjectProtocol {

    func handle(_ method: String, arguments: Any?, completion: (Any?) -> Void);
}

enum PageState {
    
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

public typealias FaradayHandler = (_ name: String, _ arguments: Any?, _ completion: @escaping (_ result: Any?) -> Void) -> Void
/// Faraday 核心类，负责管理Flutter Engine 已经处理flutter侧的方法调用
public class Faraday {
    
    public static let sharedInstance = Faraday()
    
    private init() {
        debugPrint("Faraday `sharedInstance` initailed !")
    }
    
    private weak var navigatorDelegate: FaradayNavigationDelegate? // not retain
    private weak var netProvider: FaradayHttpProvider?
    
    private var commonHandler: FaradayHandler?
    
    private var channel: FlutterMethodChannel?
    private var netChannel: FlutterMethodChannel?
    private var commonChannel: FlutterMethodChannel?
    
    private var notificationChannel: FlutterMethodChannel?
    
    private(set) var engine: FlutterEngine!
    
    private var callbackCache = [UUID: FlutterResult]()
    
    /// 当前attach在Engine的viewController 不一定可见
    public var currentFlutterViewController: FaradayFlutterViewController? {
        return engine.viewController as? FaradayFlutterViewController
    }
    
    //
    func setup(messenger: FlutterBinaryMessenger) {
        
        channel = FlutterMethodChannel(name: "g_faraday", binaryMessenger: messenger)
        
        channel?.setMethodCallHandler({ [unowned self] (call, result) in
            if (call.method == "pushNativePage") {
                self.push(native: call.arguments, callback: result)
            } else if (call.method == "popContainer") {
                self.pop(flutterContainer: call.arguments, callback: result)
            } else if (call.method == "disableHorizontalSwipePopGesture") {
                self.disableHorizontalSwipePopGesture(arguments: call.arguments, callback: result)
            } else if (call.method == "reCreateLastPage") {
                let vc = self.currentFlutterViewController
                result(vc?.seq)
                vc?.createFlutterPage()
            }
        })
        
        notificationChannel = FlutterMethodChannel(name: "g_faraday/notification", binaryMessenger: messenger)
        notificationChannel?.setMethodCallHandler({ (call, result) in
            let args = call.arguments as? Dictionary<String, Any>
            NotificationCenter.default.post(name: .init(rawValue: call.method), object: args?["arguments"])
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
    }
    
    /// 发送通知到 Flutter
    /// Flutter 可以通过 NotificationListener<NotificationListener> 来监听
    func postNotification(name: String, _ arguments: Any? = nil) {
        guard notificationChannel != nil else {
            fatalError("start flutter engine before push notification.")
        }
        notificationChannel?.invokeMethod(name, arguments: arguments)
    }
    
    /// 入口方法，用于启动Flutter Engine、 注册插件
    /// - Parameters:
    ///   - navigatorDelegate: native 侧路由代理
    ///   - automaticallyRegisterPlugins: 是否自动注册插件，如果不自动注册请及时手动注册所有插件
    /// - Returns: 插件Registry 用于注册插件
    @discardableResult
    public func startFlutterEngine(navigatorDelegate: FaradayNavigationDelegate, httpProvider: FaradayHttpProvider? = nil, commonHandler: FaradayHandler? = nil, automaticallyRegisterPlugins: Bool = true) -> FlutterPluginRegistry {
        self.navigatorDelegate = navigatorDelegate
        self.netProvider = httpProvider
        self.commonHandler = commonHandler
        
        engine = FlutterEngine(name: "io.flutter.faraday", project: nil, allowHeadlessExecution: false)
        
        // 1.1 run
        engine.run(withEntrypoint: nil)
        
        if (automaticallyRegisterPlugins) {
            guard let clazz: AnyObject = NSClassFromString("GeneratedPluginRegistrant") else {
                fatalError("missing GeneratedPluginRegistrant")
            }
            
            let registerSelector: Selector = Selector(("registerWithRegistry:"))
            let _ = clazz.perform(registerSelector, with: engine)
        }
        
        return engine
    }
    
    
    /// 唯一创建 FaradayFlutterViewController实例的方法， 全局所有flutter容器必须由次方法创建
    /// - Parameters:
    ///   - name: flutter 侧路由信息
    ///   - arguments: route arguments
    ///   - callback: flutter测页面pop时会调用此block
    /// - Returns: FaradyViewController实例
    public static func createFlutterViewController(_ name: String, arguments: Any? = nil, callback:  @escaping (Any?) -> () = { r in debugPrint("result don't be used \(String(describing: r))")}) -> FaradayFlutterViewController {
        
        let faraday = Faraday.sharedInstance
        
        guard faraday.engine != nil else {
            fatalError("Please start engine before create any FaradayViewController")
        }
        
        let vc = FaradayFlutterViewController(name, arguments: arguments, engine: faraday.engine, callback: callback)
        
        return vc
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
    
    
    /// native侧页面回调数据给flutter widget
    /// - Parameters:
    ///   - token: flutter widget 请求打开native页面时，会携带callback token给native侧
    ///   - result: 回调信息
    public static func callback(_ token: CallbackToken?, result: Any?) {
        if let t = token {
            if let cb = Faraday.sharedInstance.callbackCache.removeValue(forKey: t) {
                cb(result)
            }
        }
    }
    
    static func sendPageState(_ state: PageState, result: @escaping (Any?) -> Void) {
        let faraday = Faraday.sharedInstance
        let info = state.info;
        faraday.channel?.invokeMethod(info.0, arguments: info.1, result: { r in
            if (r is FlutterError) {
                fatalError((r as! FlutterError).message ?? "unkonwn error")
            } else {
                result(r)
            }
        })
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
        vc?.callbackValueToCreator(arguments)
        callback(vc != nil)
    }
    
    func disableHorizontalSwipePopGesture(arguments: Any?, callback: FlutterResult) {
        Faraday.sharedInstance.navigatorDelegate?.disableHorizontalSwipePopGesture(arguments as? Bool ?? false)
        callback(true)
    }
    
}
