//
//  ShoppingCartContainerModel.swift
//  DCFrame_Example
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

            addSubModel(storeModel)
        }
    }

    private func generateStoreModel(_ store: ShoppingCartStore) -> DCContainerModel {
        let containerModel = DCContainerModel()

        let titleModel = ShoppingCartTitleCellModel()
        titleModel.title = store.title

        containerModel.addSubModel(titleModel)

        for product in store.products {
            let productModel = ShoppingCartProductCellModel()
            productModel.product = product

            containerModel.addSubModel(productModel)
        }

        return containerModel
    }
}
