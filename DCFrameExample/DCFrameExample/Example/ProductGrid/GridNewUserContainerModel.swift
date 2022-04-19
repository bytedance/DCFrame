//
//  GridNewUserContainerModel.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2022/1/7.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import DCFrame

class GridNewUserContainerModel: DCContainerModel {
    let margin: CGFloat = 15
    let interval: CGFloat = 10
    let color: UIColor = UIColor(red: 237 / 255.0, green: 73 / 255.0, blue: 86 / 255.0, alpha: 1)
    let cellSize: CGSize = CGSize(width: 150, height: 150)

    init(with data: GridItemsData) {
        super.init()

        handleData(data)
    }

    private func handleData(_ data: GridItemsData) {
        let titleModel = GridTitleCellModel()
        titleModel.title = data.title

        let containerModel = DCContainerModel()

        for item in data.items {
            let model = GridItemCellModel()
            model.text = item
            model.color = color
            model.cellSize = cellSize
            containerModel.addSubmodel(model)
        }

        containerModel.layoutContext.leftMargin = margin
        containerModel.layoutContext.rightMargin = margin
        containerModel.layoutContext.horizontalInterval = interval

        addSubmodels([titleModel, DCHorizontalScrollCellModel(with: containerModel, height: 150)])
    }
}
