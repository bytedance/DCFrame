//
//  MixedMockData.swift
//  DCFrame_Example
//

import Foundation

enum ProductType {
    case new
    case category
    case picked
}

struct GridItemsData {
    var title = ""
    var items = [String]()
}

class GridsMockData {
    static func getRewardsData() -> GridItemsData {
        var item = GridItemsData()
        item.title = "New user rewards"
        for index in 1...6 {
            item.items.append("\(index)")
        }

        return item
    }

    static func getCategoryData() -> GridItemsData {
        var item = GridItemsData()
        item.title = "Trending Categories"
        for index in 1...8 {
            item.items.append("\(index)")
        }
        return item
    }

    static func getPickedData() -> GridItemsData {
        var item = GridItemsData()
        item.title = "Picked for you"
        for index in 1...50 {
            item.items.append("\(index)")
        }

        return item
    }

    static func getReorderData() -> GridItemsData {
        var item1 = GridItemsData()
        item1.title = "Drag Reorder"
        for index in 1...20 {
            item1.items.append("\(index)")
        }

        return item1
    }
}
