//
//  File.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2022/1/5.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import DCFrame

class ShoppingCartViewController: UIViewController {
    let collectionView = DCCollectionView()
    let totalView = ShoppingCartTotalView()

    let eventDataController = DCEventDataController()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        handleEvents()

        collectionView.loadContainerModel(ShoppingCartContainerModel())
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(collectionView)
        view.addSubview(totalView)

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navbarHeight())
            make.left.right.equalToSuperview()
            make.bottom.equalTo(totalView.snp.top)
        }

        totalView.snp.makeConstraints { make in
            make.height.equalTo(safeBottomMargin() + 80)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    private func handleEvents() {
        eventDataController.addChildEDC(collectionView.eventDataController)

        eventDataController.subscribeEvent(ShoppingCartContainerModel.dataUpdated, target: self) { [weak self] (data: ShoppingCartData) in
            self?.totalView.update(price: data.totalPrice())
        }
    }
}
