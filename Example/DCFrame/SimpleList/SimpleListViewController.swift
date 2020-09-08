//
//  SimpleListViewController.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/28.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import UIKit
import DCFrame

class SimpleListViewController: DCViewController {
    let listCM = DCContainerModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for num in 0...100 {
            let model = SimpleLabelModel()
            model.text = "\(num)"
            listCM.addSubmodel(model)
        }
        loadCM(listCM)
    }
}
