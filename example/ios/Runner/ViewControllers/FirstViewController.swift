//
//  FirstViewController.swift
//  Runner
//
//  Created by gix on 2020/9/2.
//

import UIKit
import g_faraday

class FirstViewController: UIViewController, FaradayResultProvider {

    var result: Any?
    
    @IBOutlet weak var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    @IBAction func openFlutter(sender: UIButton) {
        let vc = FPage.home.flutterViewController { r in
            debugPrint(r.debugDescription)
        }
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func back(sender: UIButton) {
        result = ["id": 2345]
        navigationController?.popViewController(animated: true)
    }

}
