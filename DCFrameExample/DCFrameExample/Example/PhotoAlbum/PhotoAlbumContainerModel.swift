//
//  PhotoAlbumContainerModel.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2021/12/31.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import DCFrame

class PhotoAlbumContainerModel: DCContainerModel {
    let data = PhotoAlbumData()

    override func containerModelDidLoad() {
        super.containerModelDidLoad()

        for yearData in data.years {
            let yearTitleModel = GridTitleCellModel()
            yearTitleModel.title = yearData.year
            yearTitleModel.isHoverTop = true

            let yearContainerModel = DCContainerModel()
            yearContainerModel.addSubmodel(yearTitleModel)

            for monthData in yearData.months {
                yearContainerModel.addSubmodel(PhotoAlbumMonthContainerModel(with: monthData))
            }

            yearContainerModel.layoutContext.bottomMargin = 50

            addSubmodel(yearContainerModel)
        }
    }
}
