//
//  Native2FlutterViewController.swift
//  Runner
//
//  Created by gix on 2020/11/26.
//

import UIKit

class Native2FlutterViewController: BaseViewController {

    
    @IBOutlet var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onTap(sender: UIButton) {
        
        let vc = FPage.native2flutter.flutterViewController { [weak self] r in
            self?.label.text = r.debugDescription
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }


}
