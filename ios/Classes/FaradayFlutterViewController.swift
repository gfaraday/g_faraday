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
    
    let id: Int
    
    private var callback: ((Any?) -> ())?
    
    private var isShowing = false
    private weak var previousFlutterViewController: FaradayFlutterViewController?
        
    public init(_ name: String, arguments: Any? = nil, engine: FlutterEngine? = nil, callback: ((Any?) -> ())? = nil) {
        self.name = name
        self.arguments = arguments
        self.callback = callback
        
        guard let rawEngine = engine ?? Faraday.default.engine else {
            fatalError("Faraday engine must not be nil")
        }
                
        previousFlutterViewController = rawEngine.viewController as? FaradayFlutterViewController
        rawEngine.viewController = nil
        
        self.id = rawEngine.fa.generateNewId()
        super.init(engine: rawEngine, nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        isShowing = true
        createFlutterPage()
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createFlutterPage() {
        Faraday.sendPageState(.create(name, arguments, id)) { _ in }
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
        view.backgroundColor = .clear
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        engine?.viewController = self
        isShowing = true
        Faraday.sendPageState(.show(id)) { _ in }
        super.viewWillAppear(animated)
        if (isBeingPresented) {
            view.backgroundColor = .clear
        } else {
            view.backgroundColor = .white
        }
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
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
        
        isShowing = false
//        Faraday.sendPageState(.hiden(id)) { r in
//            let succeed = r as? Bool ?? false
//            debugPrint("id: \(id) send pageState `hiden` \(succeed ? "succeed" : "failed")")
//        }
        super.viewDidAppear(animated)
    }
            
    deinit {
        Faraday.sendPageState(.dealloc(id)) { _ in }
        debugPrint("faraday flutter deinit \(name) \(id)")
    }
}
