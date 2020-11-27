//
//  NoNavigationBarViewController.swift
//  Runner
//
//  Created by gix on 2020/11/27.
//

import UIKit
import g_faraday

class NoNavigationBarViewController: UIViewController, FaradayNavigationBarHiddenProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    @IBAction func onTabBack(sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
    }
}
