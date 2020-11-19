//
//  FaradayFlutterViewController.swift
//  g_faraday
//
//  Created by gix on 2020/9/2.
//

import UIKit
import Flutter

open class FaradayFlutterViewController: FlutterViewController {
    
    public let name: String
    public let arguments: Any?
    
    private var callback: ((Any?) -> ())?
    
    private var isShowing = false
    private weak var previousFlutterViewController: FaradayFlutterViewController?
    
    var seq: Int?
    
    public init(_ name: String, arguments: Any? = nil, engine: FlutterEngine? = nil, callback: ((Any?) -> ())? = nil) {
        self.name = name
        self.arguments = arguments
        self.callback = callback
        
        guard let rawEngine = engine ?? Faraday.default.engine else {
            fatalError("Faraday engine must not be nil")
        }
                
        previousFlutterViewController = rawEngine.viewController as? FaradayFlutterViewController
        rawEngine.viewController = nil
        super.init(engine: rawEngine, nibName: nil, bundle: nil)
        isShowing = true
        createFlutterPage()
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createFlutterPage() {
        Faraday.sendPageState(.create(name, arguments, seq)) { [weak self] r in
            self?.seq = r as? Int
            debugPrint("seq: \(r!) create page succeed")
        }
    }
    
    weak var interactivePopGestureRecognizerDelegate: UIGestureRecognizerDelegate?
        
    public func disableHorizontalSwipePopGesture(disable: Bool) {
        //
        // 这里不能无脑设置为 !disable 具体原因：
        //
        // ref: https://stackoverflow.com/questions/36503224/ios-app-freezes-on-pushviewcontroller
        //
        if ((navigationController?.viewControllers.count ?? 0) > 1) {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = !disable
        }
    }
    
    public func callbackValueToCreator(_ value: Any?) {
        if let cb = callback {
          cb(value)
          callback = nil
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        if let s = seq {
            engine?.viewController = self
            isShowing = true
            Faraday.sendPageState(.show(s)) { r in
                let succeed = r as? Bool ?? false
                debugPrint("seq: \(s) send pageState `show` \(succeed ? "succeed" : "failed")")
            }
        }
        super.viewWillAppear(animated)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        if ((navigationController?.viewControllers.count ?? 0) > 1) {
            interactivePopGestureRecognizerDelegate = navigationController?.interactivePopGestureRecognizer?.delegate
            navigationController?.interactivePopGestureRecognizer?.delegate = nil
        }
        
        super.viewDidAppear(animated)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        if let p = previousFlutterViewController, p.isShowing {
            Faraday.refreshViewController(p)
        }
        super.viewWillDisappear(animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        //
        // ref: https://stackoverflow.com/questions/36503224/ios-app-freezes-on-pushviewcontroller
        //
        if (interactivePopGestureRecognizerDelegate != nil) {
            navigationController?.interactivePopGestureRecognizer?.delegate = interactivePopGestureRecognizerDelegate
            navigationController?.interactivePopGestureRecognizer?.isEnabled = (navigationController?.viewControllers.count ?? 0) > 1
        }
        
        if seq != nil {
            isShowing = false
//            Faraday.sendPageState(.hiden(s)) { r in
//                let succeed = r as? Bool ?? false
//                debugPrint("seq: \(s) send pageState `hiden` \(succeed ? "succeed" : "failed")")
//            }
        }
        super.viewDidAppear(animated)
    }
            
    deinit {
        if let s = seq {
            Faraday.sendPageState(.dealloc(s)) { r in
                let succeed = r as? Bool ?? false
                debugPrint("seq: \(s) send pageState `dealloc` \(succeed ? "succeed" : "failed")")
            }
        }
        debugPrint("faraday flutter deinit")
    }
}

