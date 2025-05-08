//
//  File2.swift
//  DCFrame_Example
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

            addSubModel(storeModel)
        }

        addSubModel(ShoppingCartTotalCellModel())
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
