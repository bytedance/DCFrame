//
//  PhotoAlbumMonthContainerModel.swift
//  DCFrame_Example
//

import UIKit
import DCFrame

class PhotoAlbumMonthContainerModel: DCContainerModel {
    let showAllModel = PhotoAlbumShowAllCellModel()
    var leftPhotos = [String]()

    init(with data: PhotoMonthData) {
        super.init()

        showAllModel.cellSize = CGSize(width: 80, height: 20)
        showAllModel.isNewLine = true

        layoutContext.leftMargin = 100
        layoutContext.horizontalInterval = 5
        layoutContext.verticalInterval = 5
        layoutContext.bottomMargin = 20

        handleData(data)
    }

    override func containerModelDidLoad() {
        super.containerModelDidLoad()

        subscribeEvent(PhotoAlbumShowAllCell.didSelect) { [weak self] in
            guard let self = self, !self.leftPhotos.isEmpty else {
                return
            }

            self.removeSubmodel(self.showAllModel)

            for item in self.leftPhotos {
                let model = GridItemCellModel()
                model.text = item
                model.color = UIColor(red: 237 / 255.0, green: 73 / 255.0, blue: 86 / 255.0, alpha: 1)
                model.cellSize = CGSize(width: 80, height: 80)
                self.addSubModel(model)
            }

            self.leftPhotos.removeAll()

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.6, options: [], animations: {
                self.containerViewHandler?.needUpdateLayoutAnimated()
            })
        }
    }

    private func handleData(_ data: PhotoMonthData) {
        let monthTitle = GridTitleCellModel()
        monthTitle.cellSize = CGSize(width: 80, height: 20)
        monthTitle.isBackgroundCell = true
        monthTitle.title = data.month
        addSubModel(monthTitle)

        for (index, item) in data.photos.enumerated() {
            if index < 6 {
                let model = GridItemCellModel()
                model.text = item
                model.color = UIColor(red: 56 / 255.0, green: 151 / 255.0, blue: 240 / 255.0, alpha: 1)
                model.cellSize = CGSize(width: 80, height: 80)
                addSubModel(model)
            } else {
                leftPhotos.append(item)
            }
        }
        
        if data.photos.count > 6 {
            addSubModel(showAllModel)
        }
    }
}
