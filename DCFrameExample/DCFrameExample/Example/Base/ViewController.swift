//
//  ViewController.swift
//  DCFrame
//
//  Created by zhangzhengzhen on 02/11/2025.
//  Copyright (c) 2025 zhangzhengzhen. All rights reserved.
//

import UIKit
import DCFrame
import SnapKit

class ViewController: DemosViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Demos"

        loadContainerModel(DemosContainerModel())
    }
}
