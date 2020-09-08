//
//  SimpleListXibViewController.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/9/8.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import UIKit
import DCFrame

class SimpleListXibViewController: DCViewController {
    let listCM = DCContainerModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dcTableView.isAutomaticDimension = true
        
        for num in 0...100 {
            let model = LabelModel()
            model.text = "\(num)"
            listCM.addSubmodel(model)
        }
        
        loadCM(listCM)
    }
}
