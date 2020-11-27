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
        setViewControllers([HomeFlutterViewController()], animated: false)
        
        //
        
        NotificationCenter.default.addObserver(forName: .init(rawValue: "GlobalNotification"), object: nil, queue: OperationQueue.main) { [weak self] _ in
            
            let vc = UIAlertController(title: "收到 GlobalNotification", message: "点击确定5s后发送通知到Flutter <这是一个Native的UIAlertController>", preferredStyle: .alert)
            
            vc.addAction(UIAlertAction(title: "取消", style: .destructive, handler: nil))
            
            vc.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    NotificationCenter.fa.post(name: "NotificationFromNative", object: "from ios native systemVersion: \(UIDevice.current.systemVersion)")
                }
            }))
            
            self?.present(vc, animated: true, completion: nil)
        }
    }
}
