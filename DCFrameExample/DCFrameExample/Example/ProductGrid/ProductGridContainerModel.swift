//
//  Untitled.swift
//  DCContainerView_Example
//

import DCFrame

class ProductGridContainerModel: DCContainerModel {
    override func containerModelDidLoad() {
        super.containerModelDidLoad()

        let rewardsModel = GridNewUserContainerModel()

        let categoryModel = GridCategoryGroudModel(with: GridsMockData.getCategoryData())
        categoryModel.layoutContext.topMargin = 50

        let pickedModel = GridPickedContainerModel()
        pickedModel.layoutContext.topMargin = 50

        addSubModels([
            rewardsModel,
            categoryModel,
            pickedModel
        ])
    }
}
