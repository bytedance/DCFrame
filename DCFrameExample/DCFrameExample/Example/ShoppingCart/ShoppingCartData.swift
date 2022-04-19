//
//  ShoppingCartMockData.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2022/1/5.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

class ShoppingCartData {
    var stores = [ShoppingCartStore]()

    init() {
        let store1 = ShoppingCartStore()
        store1.title = "Topsounds Store"
        store1.products.append(ShoppingCartStoreProduct(id: 1, image: UIColor.systemRed, title: "Wireless Earphone Bluetooth", price: 216, count: 1))
        store1.products.append(ShoppingCartStoreProduct(id: 2, image: UIColor.systemPink, title: "TWS Bluetooth 5.0 EarPhone", price: 191, count: 2))

        let store2 = ShoppingCartStore()
        store2.title = "instudio"
        store2.products.append(ShoppingCartStoreProduct(id: 3, image: UIColor.systemTeal, title: "Fairy house number resin ornaments", price: 1004, count: 1))

        stores.append(contentsOf: [store1, store2])
    }

    func totalPrice() -> Int64 {
        var price: Int64 = 0
        for store in stores {
            for product in store.products {
                price += product.totalPrice()
            }
        }
        return price
    }

    func addCount(_ id: Int64, count: Int) {
        for store in stores {
            for product in store.products where id == product.id {
                product.count += count
                if product.count < 1 {
                    product.count = 1
                }
            }
        }
    }
}

class ShoppingCartStore {
    var title = ""
    var products = [ShoppingCartStoreProduct]()
}

class ShoppingCartStoreProduct {
    var id: Int64 = 0
    var image = UIColor()
    var title = ""
    var price: Int64 = 0
    var count = 0

    init(id: Int64, image: UIColor, title: String, price: Int64, count: Int) {
        self.id = id
        self.image = image
        self.title = title
        self.price = price
        self.count = count
    }

    func totalPrice() -> Int64 {
        return price * Int64(count)
    }
}
