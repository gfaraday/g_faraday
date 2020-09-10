//
//  FaradayFlutterViewController.swift
//  g_faraday
//
//  Created by gix on 2020/9/2.
//

import UIKit

public class FaradayFlutterViewController: FlutterViewController {
    
    public let name: String
    public let arguments: Any?
    public let callback: ((Any?) -> ())?
    
    private var isShowing = false
    private weak var previousFlutterViewController: FaradayFlutterViewController?
    
    var seq: Int?
    
    init(_ name: String, arguments: Any?, engine: FlutterEngine, callback: @escaping (Any?) ->()) {
        self.name = name
        self.arguments = arguments
        self.callback = callback
        previousFlutterViewController = engine.viewController as? FaradayFlutterViewController
        engine.viewController = nil
        super.init(engine: engine, nibName: nil, bundle: nil)
        isShowing = true
        Faraday.sendPageState(.create(name, arguments)) { [weak self] r in
            self?.seq = r as? Int
            debugPrint("seq: \(r!) create page succeed")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var interactivePopGestureRecognizerDelegate: UIGestureRecognizerDelegate?

    public override func viewDidLoad() {
        super.viewDidLoad()
    }
        
    public func disableHorizontalSwipePopGesture(disable: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = !disable
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        if engine?.viewController != self {
            if let s = seq {
                engine?.viewController = self
                isShowing = true
                Faraday.sendPageState(.show(s)) { r in
                    let succeed = r as? Bool ?? false
                    debugPrint("seq: \(s) send pageState `show` \(succeed ? "succeed" : "failed")")
                }
            }
        }
        super.viewWillAppear(animated)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        interactivePopGestureRecognizerDelegate = navigationController?.interactivePopGestureRecognizer?.delegate
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        super.viewDidAppear(animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        if let p = previousFlutterViewController, p.isShowing {
            Faraday.refreshViewController(p)
        }
        super.viewWillDisappear(animated)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
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

