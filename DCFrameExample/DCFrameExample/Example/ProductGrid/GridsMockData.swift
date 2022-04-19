//
//  MixedMockData.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2021/12/31.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

enum ProductType {
    case new
    case category
    case picked
}

struct GridItemsData {
    var title = ""
    var type = ProductType.new
    var items = [String]()
}

class GridsMockData {
    static func getGridsData() -> [GridItemsData] {
        var item1 = GridItemsData()
        item1.title = "New user rewards"
        item1.type = .new
        for index in 1...6 {
            item1.items.append("\(index)")
        }

        var item2 = GridItemsData()
        item2.title = "Trending Categories"
        item2.type = .category
        for index in 1...8 {
            item2.items.append("\(index)")
        }

        var item3 = GridItemsData()
        item3.title = "Picked for you"
        item3.type = .picked
        for index in 1...50 {
            item3.items.append("\(index)")
        }

        return [item1, item2, item3]
    }
    
    static func getReorderData() -> GridItemsData {
        var item1 = GridItemsData()
        item1.title = "Drag Reorder"
        item1.type = .category
        for index in 1...20 {
            item1.items.append("\(index)")
        }

        return item1
    }
}


