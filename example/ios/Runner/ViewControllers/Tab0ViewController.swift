//
//  Tab0ViewController.swift
//  Runner
//
//  Created by gix on 2020/9/4.
//

import UIKit
import g_faraday

class Tab0ViewController: UIViewController, FaradayNavigationBarHiddenProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc = FPage.tab.flutterViewController() { _ in
            
        }
        
        vc.willMove(toParent: self)
        addChild(vc)
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        
        vc.view.frame = view.frame;
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleWidth]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
