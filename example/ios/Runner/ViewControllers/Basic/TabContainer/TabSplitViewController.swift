//
//  TabSplitViewController.swift
//  Runner
//
//  Created by gix on 2020/12/25.
//

import Foundation
import g_faraday

class TabSplitViewController: UIViewController {
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let index = parent?.children.firstIndex(of: self), index == 0 {
            if let vc = children.first as? FaradayFlutterViewController {
                Faraday.refreshViewController(vc)
            }
        }
    }
    
}


