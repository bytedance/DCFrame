//
//  RefreshViewController.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/8.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import UIKit
import DCFrame

class RefreshViewController: DCRefreshViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        loadContainerModel(RefreshContainerModel())
    }
}
