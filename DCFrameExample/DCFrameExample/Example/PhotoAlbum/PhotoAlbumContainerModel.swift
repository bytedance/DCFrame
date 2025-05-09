//
//  PhotoAlbumContainerModel.swift
//  DCFrame_Example
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
            yearContainerModel.addSubModel(yearTitleModel)

            for monthData in yearData.months {
                yearContainerModel.addSubModel(PhotoAlbumMonthContainerModel(with: monthData))
            }

            yearContainerModel.layoutContext.bottomMargin = 50

            addSubModel(yearContainerModel)
        }
    }
}
