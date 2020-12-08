//
//  Tab2ViewController.swift
//  Runner
//
//  Created by gix on 2020/11/27.
//

import UIKit
import g_faraday

class Tab2ViewController: BaseViewController, FaradayNavigationBarHiddenProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        let vc = FaradayFlutterViewController("home")
        
        vc.willMove(toParent: self)
        addChild(vc)
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        
        vc.view.frame = view.frame;
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleWidth]
    }
}
