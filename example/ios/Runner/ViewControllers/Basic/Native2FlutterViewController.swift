//
//  Native2FlutterViewController.swift
//  Runner
//
//  Created by gix on 2020/11/26.
//

import UIKit
import g_faraday

class Native2FlutterViewController: BaseViewController {

    
    @IBOutlet var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onTap(sender: UIButton) {
        
        let vc = FaradayFlutterViewController("native2flutter") { [weak self] r in
            self?.label.text = r.debugDescription
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func onTap1(sedner: UIButton) {
        
        let vc = FaradayFlutterViewController("transparent_flutter", backgroundClear: true)
        
        navigationController?.present(vc, animated: false, completion: nil)
    }
}
