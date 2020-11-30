//
//  HomeFlutterViewController.swift
//  Runner
//
//  Created by gix on 2020/11/27.
//

import UIKit
import g_faraday

class HomeFlutterViewController: FaradayFlutterViewController {
    
    init() {
        super.init("home", arguments: nil, backgroundClear: false, engine: nil, callback: nil)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
//        let v = UIView()
//        v.backgroundColor = .red
//        v.frame = UIScreen.main.bounds
//
//        let imageView = UIImageView(image: UIImage(named: "logo"))
//        v.addSubview(imageView)
//        imageView.center = view.center
//        https://github.com/flutter/flutter/issues/37818
//        flutter engine 暂时有bug， 不推荐设置
//        splashScreenView = v
        
        // 直接将 launchScreen.storyboard 中的view 作为 splashView
        loadDefaultSplashScreenView()

    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
       
//    override func loadDefaultSplashScreenView() -> Bool {
//        return false
//    }
    
}
