//
//  MainTabBarController.swift
//  Runner
//
//  Created by gix on 2020/9/2.
//

import UIKit
import g_faraday

class MainViewController: UIViewController, FaradayNavigationBarHiddenProtocol {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        let vc = FaradayFlutterViewController("home", arguments: nil)
        
        vc.willMove(toParent: self)
        addChild(vc)
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        
        vc.view.frame = view.frame;
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleWidth]
        
    }
}
