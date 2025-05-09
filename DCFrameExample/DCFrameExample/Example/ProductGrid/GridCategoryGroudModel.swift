//
//  GridTrendingGroudModel.swift
//  DCFrame_Example
//

import UIKit
import DCFrame

class GridCategoryGroudModel: DCContainerModel {
    let margin: CGFloat = 20
    let interval: CGFloat = 5
    let color = UIColor(red: 56 / 255.0, green: 151 / 255.0, blue: 240 / 255.0, alpha: 1)

    var cellSize: CGSize {
        let width = (UIScreen.main.bounds.width - (2 * margin + 3 * interval)) / 4
        return CGSize(width: width, height: width)
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

        for item in data.items {
            let model = GridItemCellModel()
            model.text = item
            model.color = color
            model.cellSize = cellSize
            containerModel.addSubModel(model)
        }

        addSubModels([titleModel, containerModel])
    }
}
