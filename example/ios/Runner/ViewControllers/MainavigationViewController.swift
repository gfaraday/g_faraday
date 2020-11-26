//
//  MainavigationViewController.swift
//  Runner
//
//  Created by gix on 2020/11/26.
//

import UIKit
import g_faraday

class MainavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBarHidden(true, animated: false)
        let vc = FaradayFlutterViewController("home", arguments: nil)
        setViewControllers([vc], animated: false)
    }
}
