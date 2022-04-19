//
//  ShoppingCartContainerModel.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2022/1/5.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import DCFrame

class ShoppingCartContainerModel: DCContainerModel {
    static let dataUpdated = DCEventID()

    let mockData = ShoppingCartData()

    override func containerModelDidLoad() {
        super.containerModelDidLoad()

        subscribeEvent(ShoppingCartProductCell.addCount) { [weak self] (id: Int64, count: Int) in
            self?.mockData.addCount(id, count: count)

            self?.sendEvent(Self.dataUpdated, data: self?.mockData)

            self?.needUpdateCellsData()
        }
        
        sendEvent(Self.dataUpdated, data: mockData)

        for store in mockData.stores {
            let storeModel = generateStoreModel(store)
            storeModel.layoutContext.bottomMargin = 20

            addSubmodel(storeModel)
        }
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
