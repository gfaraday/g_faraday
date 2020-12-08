//
//  NeedNavigationBarViewController.swift
//  Runner
//
//  Created by gix on 2020/11/27.
//

import UIKit

class NeedNavigationBarViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(false, animated: true)
    }

}
