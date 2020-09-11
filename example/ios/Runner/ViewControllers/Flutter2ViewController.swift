//
//  Flutter2ViewController.swift
//  Runner
//
//  Created by gix on 2020/9/11.
//

import UIKit

class Flutter2ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc = FPage.flutterTab2.flutterViewController() { _ in
            
        }
        
        vc.willMove(toParent: self)
        addChild(vc)
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        
        vc.view.frame = view.frame;
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleWidth]
    }
   
}
