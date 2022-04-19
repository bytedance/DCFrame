//
//  File.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2022/1/5.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import DCFrame

class CategoryTitlesContainerModel: DCContainerModel {
    var titleModelMap = [String: CategoryTitleCellModel]()
    var preSelectedTitleModel: CategoryTitleCellModel?

    override func containerModelDidLoad() {
        super.containerModelDidLoad()

        subscribeEvent(CategoryTitleCell.didSelect) { [weak self] (cellModel: CategoryTitleCellModel) in
            guard let self = self else {
                return
            }
            self.selectModel(cellModel)
        }
    }

    func handleData(data: CategoryData) {
        removeAllSubmodels()
        titleModelMap.removeAll()

        for (index, category) in data.categries.directValue.enumerated() {
            let model = CategoryTitleCellModel()
            model.title = category.title
            if index == 0 {
                model.isSelect = true
                preSelectedTitleModel = model
            }

            titleModelMap[category.title] = model

            addSubmodel(model)
        }

        dcHandler?.needUpdateLayout()
    }

    func showTitle(_ title: String) {
        guard let model = titleModelMap[title], let indexPath = model.indexPath, let frame = dcCollectionView?.layoutAttributesForItem(at: indexPath)?.frame else {
            return
        }

        selectModel(model)
        dcCollectionView?.scrollRectToVisible(frame, animated: true)
    }

    private func selectModel(_ curModel: CategoryTitleCellModel) {
        preSelectedTitleModel?.isSelect = false
        preSelectedTitleModel?.needUpdateCellData()

        curModel.isSelect = true
        curModel.needUpdateCellData()

        preSelectedTitleModel = curModel
    }
}
