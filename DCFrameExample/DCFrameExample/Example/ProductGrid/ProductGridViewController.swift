//
//  ProductGridViewController.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2021/12/31.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import DCFrame

class ProductGridViewController: DCCollectionController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let containerModel = DCContainerModel()

        for (index, data) in GridsMockData.getGridsData().enumerated() {
            let subContainerModel = getContainerModel(data)
            subContainerModel.layoutContext.topMargin = index != 0 ? 50 : 0
            
            containerModel.addSubmodel(subContainerModel)
        }

        loadContainerModel(containerModel)
    }

    private func getContainerModel(_ data: GridItemsData) -> DCContainerModel {
        switch data.type {
        case .new:
            return GridNewUserContainerModel(with: data)
        case .category:
            return GridCategoryGroudModel(with: data)
        case .picked:
            return GridPickedContainerModel(with: data)
        }
    }
}
