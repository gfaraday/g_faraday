//
//  FirstViewController.swift
//  Runner
//
//  Created by gix on 2020/9/2.
//

import UIKit
import g_faraday

class FirstViewController: UIViewController {

    @IBOutlet weak var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func openFlutter(sender: UIButton) {
        let vc = FPage.flutter.flutterViewController { r in
            debugPrint(r.debugDescription)
        }
        if (fa.isModal) {
            present(vc, animated: true, completion: nil)
        } else {
            navigationController?.fa.popViewController(withResult: ["id": 234], animated: true)
        }
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func back(sender: UIButton) {
        if (fa.isModal) {
            fa.dismiss(withResult: ["id": 2345], animated: true, completion: nil)
        } else {
            navigationController?.fa.popViewController(withResult: ["id": 234], animated: true)
        }
    }

}
