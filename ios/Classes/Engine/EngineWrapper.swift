//
//  FaradayEngine.swift
//  g_faraday
//
//  Created by gix on 2020/9/3.
//

import Foundation

class EngineWrapper {
    
    lazy var engine: FlutterEngine = {
        // 1. initial flutter engine
        let engine = FlutterEngine(name: "io.flutter.faraday", project: nil, allowHeadlessExecution: true)
        
        // 1.1 run
        engine.run(withEntrypoint: nil)
        
        // 2. regist all Plugins
        guard let clazz: AnyObject = NSClassFromString("GeneratedPluginRegistrant") else {
            fatalError("missing GeneratedPluginRegistrant")
        }
        
        let registerSelector: Selector = Selector(("registerWithRegistry:"))
        let _ = clazz.perform(registerSelector, with: engine)
        
        
        return engine
    }()
    
    var viewController: FaradayFlutterViewController? {
        return engine.viewController as? FaradayFlutterViewController
    }
    
    func warm() {
        debugPrint("\(engine) started")
//        let vc = FaradayFlutterViewController("", maintainState: false, arguments: "", engine: engine, callback: { _ in })
//        vc.pushRoute("/")
    }
}
