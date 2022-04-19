//
//  GridPickedContainerModel.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2022/1/7.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import DCFrame

class GridPickedContainerModel: DCContainerModel {
    let margin: CGFloat = 15
    let interval: CGFloat = 10

    let color: UIColor = UIColor(red: 112 / 255.0, green: 192 / 255.0, blue: 80 / 255.0, alpha: 1)

    var cellSize: CGSize {
        let width = (UIScreen.main.bounds.width - (2 * margin + interval)) / 2
        return CGSize(width: width, height: width + CGFloat(arc4random() % 50))
    }

    init(with data: GridItemsData) {
        super.init()

        handleData(data)
    }

    private func handleData(_ data: GridItemsData) {
        let titleModel = GridTitleCellModel()
        titleModel.title = data.title

        let containerModel = DCContainerModel()

        containerModel.layoutContext.leftMargin = margin
        containerModel.layoutContext.rightMargin = margin
        containerModel.layoutContext.horizontalInterval = interval
        containerModel.layoutContext.verticalInterval = interval
        containerModel.customLayout = DCContainerWaterFlowLayout(columnCount: 2)

        for item in data.items {
            let model = GridItemCellModel()
            model.text = item
            model.color = color
            model.cellSize = cellSize
            containerModel.addSubmodel(model)
        }

        addSubmodels([titleModel, containerModel])
    }
}
