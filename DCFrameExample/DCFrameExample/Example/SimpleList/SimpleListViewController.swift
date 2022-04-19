//
//  SimpleListViewController.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/28.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import UIKit
import DCFrame

class SimpleListViewController: DCCollectionController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let listContainerModel = DCContainerModel()

        for num in 0...100 {
            let model = SimpleLabelCellModel()
            model.text = "\(num)"
            if num == 100 {
                model.isShowBottomLine = false
            }
            listContainerModel.addSubmodel(model)
        }
        
        loadContainerModel(listContainerModel)
    }
}
