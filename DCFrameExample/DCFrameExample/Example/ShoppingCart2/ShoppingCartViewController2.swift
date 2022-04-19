//
//  File.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2022/1/5.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import DCFrame

class ShoppingCartViewController2: DCCollectionController {
    override func viewDidLoad() {
        super.viewDidLoad()

        loadContainerModel(ShoppingCartContainerModel2())
    }
}
