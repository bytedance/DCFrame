//
//  CategoryCartData.swift
//  DCFrame_Example
//

import UIKit
import DCFrame

class CategoryData {
    var categries = DCProtector<[CategoryProducts]>([CategoryProducts]())

    init() {
        categries.directValue.append(contentsOf: [
            CategoryProducts(title: "Accessories", num: 8),
            CategoryProducts(title: "Women's Clothing", num: 9),
            CategoryProducts(title: "Men's Clothing", num: 8),
            CategoryProducts(title: "Home & Garden", num: 13),
            CategoryProducts(title: "Bags & Shoes", num: 7),
            CategoryProducts(title: "Mobile Phones", num: 4),
            CategoryProducts(title: "Beauty & Health", num: 5),
            CategoryProducts(title: "Electronics", num: 5),
            CategoryProducts(title: "Outdoor & Sports", num: 7),
            CategoryProducts(title: "Pet Supplies", num: 2),
            CategoryProducts(title: "Maternity, Kids & Toys", num: 10),
            CategoryProducts(title: "Office & School", num: 5),
            CategoryProducts(title: "Automotive", num: 4)
        ])
    }
}

class CategoryProducts {
    var title = ""
    var products = [String]()

    init(title: String, num: Int) {
        self.title = title

        for index in 1...num {
            products.append("\(index)")
        }
    }
}
