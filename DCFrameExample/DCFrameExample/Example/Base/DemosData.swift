//
//  DemosList.swift
//  DCFrame_Example
//

import UIKit

enum DemosData {
    static let items: [(String, Any)] = [
        ("Simple List", SimpleListViewController()),
        ("Refreshing & Loading", RefreshViewController()),
        ("Reorder", ReorderViewController()),
        ("Product Grid", ProductGridViewController()),
        ("Photo Album", PhotoAlbumViewController()),
        ("Shopping Cart", ShoppingCartViewController()),
        ("Shopping Cart2", ShoppingCartViewController2()),
        ("Category", CategoryViewController())
    ]
}
