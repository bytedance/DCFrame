//
//  DCViewController.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2019/8/7.
//  Copyright © 2019 Bytedance. All rights reserved.
//

import UIKit
import DCFrame

class DCViewController: UIViewController {
    public lazy var EDC: DCEventDataController = {
        let EDC = DCEventDataController()
        EDC.tag = String(describing: Self.self)
        return EDC
    }()
    
    public let dcTableView = DCContainerTableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        EDC.addChildEDC(dcTableView.eventDataController)
        
        dcTableView.frame = view.frame
        dcTableView.contentInset = UIEdgeInsets(top: navbarHeight(), left: 0, bottom: safeBottomMargin(), right: 0)
        dcTableView.contentOffset = CGPoint(x: 0, y: -navbarHeight())

        view.addSubview(dcTableView)
    }
    
    public func loadCM(_ cm: DCContainerModel) {
        dcTableView.loadCM(cm)
    }
    
    public func isIPhoneX() -> Bool {
        if #available(iOS 11.0, tvOS 11.0, *), let window = UIApplication.shared.keyWindow {
            if window.safeAreaInsets.left > 0 || window.safeAreaInsets.bottom > 0 {
                return true
            }
        }
        return false
    }
    
    public func statusBarHeight() -> CGFloat {
        if isIPhoneX() {
            return 44
        }
        return 20
    }
    
    public func navbarHeight() -> CGFloat {
        return statusBarHeight() + 44
    }
    
    public func safeBottomMargin() -> CGFloat {
        if isIPhoneX() {
            return 34.0
        } else {
            return 0.0
        }
    }
}
