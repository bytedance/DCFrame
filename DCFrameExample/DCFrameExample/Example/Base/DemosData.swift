//
//  DemosList.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2021/12/30.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

enum DemosData {
    static let items: [(String, UIViewController.Type)] = [
        ("Simple List", SimpleListViewController.self),
        ("Refreshing & Loading", RefreshViewController.self),
        ("Product Grid", ProductGridViewController.self),
        ("Photo Album", PhotoAlbumViewController.self),
        ("Shopping Cart", ShoppingCartViewController.self),
        ("Shopping Cart2", ShoppingCartViewController2.self),
        ("Category", CategoryViewController.self)
    ]
}
