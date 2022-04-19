//
//  ViewController.swift
//  DCFrame
//
//  Created by zhangzhengzhen on 02/22/2019.
//  Copyright (c) 2019 zhangzhengzhen. All rights reserved.
//

import UIKit
import DCFrame

class ViewController: DCCollectionController {
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Demos"

        loadContainerModel(DemosContainerModel())
    }
}
