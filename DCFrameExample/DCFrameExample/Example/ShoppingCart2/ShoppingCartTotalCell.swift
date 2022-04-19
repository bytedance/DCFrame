//
//  ShoppingCartTotalCell.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2022/1/5.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import DCFrame
import Then

class ShoppingCartTotalCellModel: DCCellModel {
    static let totalPrice = DCSharedDataID()

    var priceText = "Total: $0"

    override func cellModelDidLoad() {
        super.cellModelDidLoad()

        subscribeData(Self.totalPrice) { [weak self] (price: Int64) in
            self?.priceText = String(format: "Total: $%.2f", Double(price) / 100)
            self?.needUpdateCellData()
        }
    }

    override func getCellHeight() -> CGFloat {
        return 50
    }
}

class ShoppingCartTotalCell: DCCell<ShoppingCartTotalCellModel> {
    private let priceLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 18)
        $0.textColor = .black
    }

    override func setupUI() {
        super.setupUI()

        contentView.backgroundColor = UIColor(red: 56 / 255.0, green: 151 / 255.0, blue: 240 / 255.0, alpha: 1)
        contentView.addSubview(priceLabel)

        layoutUI()
    }

    private func layoutUI() {
        priceLabel.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
        }
    }

    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()

        priceLabel.text = cellModel.priceText
    }
}
