//
//  FaradayFlutterViewController.swift
//  g_faraday
//
//  Created by gix on 2020/9/2.
//

import UIKit

open class FaradayFlutterViewController: FlutterViewController {
    
    public let name: String
    public let arguments: Any?
    
    private var callback: ((Any?) -> ())?
    
    private var isShowing = false
    private weak var previousFlutterViewController: FaradayFlutterViewController?
    
    var seq: Int?
    
    public init(_ name: String, arguments: Any? = nil, callback: ((Any?) -> ())? = nil) {
        self.name = name
        self.arguments = arguments
        self.callback = callback
        guard let engine = Faraday.sharedInstance.engine else {
            fatalError("Please Start Faraday Flutter Engine")
        }
        previousFlutterViewController = engine.viewController as? FaradayFlutterViewController
        engine.viewController = nil
        super.init(engine: engine, nibName: nil, bundle: nil)
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
        navigationController?.interactivePopGestureRecognizer?.isEnabled = !disable
    }
    
    func callbackValueToCreator(_ value: Any?) {
        guard let cb = callback else {
            fatalError("don't support callback or did callback-ed")
        }
        cb(value)
        callback = nil
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
        interactivePopGestureRecognizerDelegate = navigationController?.interactivePopGestureRecognizer?.delegate
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        super.viewDidAppear(animated)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        if let p = previousFlutterViewController, p.isShowing {
            Faraday.refreshViewController(p)
        }
        super.viewWillDisappear(animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.delegate = interactivePopGestureRecognizerDelegate
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        if let s = seq {
            isShowing = false
            Faraday.sendPageState(.hiden(s)) { r in
                let succeed = r as? Bool ?? false
                debugPrint("seq: \(s) send pageState `hiden` \(succeed ? "succeed" : "failed")")
            }
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

