//
//  File2.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2022/1/5.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import DCFrame

class ShoppingCartContainerModel2: DCContainerModel {
    static let dataUpdated = DCEventID()

    let mockData = ShoppingCartData()

    override func containerModelDidLoad() {
        super.containerModelDidLoad()

        subscribeEvent(ShoppingCartProductCell.addCount) { [weak self] (id: Int64, count: Int) in
            self?.mockData.addCount(id, count: count)

            self?.shareData(self?.mockData.totalPrice(), to: ShoppingCartTotalCellModel.totalPrice)

            self?.needUpdateCellsData()
        }

        shareData(mockData.totalPrice(), to: ShoppingCartTotalCellModel.totalPrice)

        for store in mockData.stores {
            let storeModel = generateStoreModel(store)
            storeModel.layoutContext.bottomMargin = 20

            addSubmodel(storeModel)
        }

        addSubmodel(ShoppingCartTotalCellModel())
    }

    private func generateStoreModel(_ store: ShoppingCartStore) -> DCContainerModel {
        let containerModel = DCContainerModel()

        let titleModel = ShoppingCartTitleCellModel()
        titleModel.title = store.title

        containerModel.addSubmodel(titleModel)

        for product in store.products {
            let productModel = ShoppingCartProductCellModel()
            productModel.product = product

            containerModel.addSubmodel(productModel)
        }

        return containerModel
    }
}
