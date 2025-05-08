//
//  File.swift
//  DCFrame_Example
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
        removeAllSubModels()
        titleModelMap.removeAll()

        for (index, category) in data.categries.directValue.enumerated() {
            let model = CategoryTitleCellModel()
            model.title = category.title
            if index == 0 {
                model.isSelect = true
                preSelectedTitleModel = model
            }

            titleModelMap[category.title] = model

            addSubModel(model)
        }

        containerViewHandler?.needUpdateLayout()
    }

    func showTitle(_ title: String) {
        guard let model = titleModelMap[title], let indexPath = model.indexPath, let frame = dcContainerView?.layoutAttributesForItem(at: indexPath)?.frame else {
            return
        }

        selectModel(model)
        dcContainerView?.scrollRectToVisible(frame, animated: true)
    }

    private func selectModel(_ curModel: CategoryTitleCellModel) {
        preSelectedTitleModel?.isSelect = false
        preSelectedTitleModel?.needUpdateCellData()

        curModel.isSelect = true
        curModel.needUpdateCellData()

        preSelectedTitleModel = curModel
    }
}
