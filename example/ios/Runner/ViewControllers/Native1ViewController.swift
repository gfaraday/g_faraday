//
//  Tab1ViewController.swift
//  Runner
//
//  Created by gix on 2020/9/2.
//

import UIKit
import g_faraday

class Native1ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Native2Flutter"
    }
    

    @IBAction func openFlutterDemo(sender: UIButton) {
        
        let vc = FPage.flutter.flutterViewController { r in
            sender.setTitle("result from flutter \(r ?? "none")", for: .normal)
        }
        
        navigationController?.pushViewController(vc, animated: true);
        
    }

}
