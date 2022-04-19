//
//  ShoppingCartProductCell.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2022/1/5.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import DCFrame
import Then

class ShoppingCartProductCellModel: DCCellModel {
    var product: ShoppingCartStoreProduct?

    required init() {
        super.init()

        cellHeight = 120
    }
}

class ShoppingCartProductCell: DCCell<ShoppingCartProductCellModel> {
    static let addCount = DCEventID()

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15)
        $0.textColor = .black
    }

    private let priceLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 18)
        $0.textColor = .black
    }

    private let imageView = UIView().then {
        $0.backgroundColor = UIColor.systemGray
    }

    private let countLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.layer.backgroundColor = UIColor.lightGray.cgColor
        $0.layer.cornerRadius = 4
    }

    private let addButton = UIButton().then {
        $0.setTitle("+", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }

    private let reduceButton = UIButton().then {
        $0.setTitle("-", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }

    override func setupUI() {
        super.setupUI()

        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(imageView)
        contentView.addSubview(countLabel)
        contentView.addSubview(addButton)
        contentView.addSubview(reduceButton)

        addButton.addTarget(self, action: #selector(addCount), for: .touchUpInside)
        reduceButton.addTarget(self, action: #selector(reduceCount), for: .touchUpInside)

        layoutUI()
    }

    private func layoutUI() {
        imageView.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 80, height: 80))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(10)
            make.top.equalTo(imageView).offset(5)
            make.right.equalTo(-20)
        }

        priceLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.bottom.equalTo(imageView)
        }

        addButton.snp.makeConstraints { make in
            make.right.equalTo(titleLabel)
            make.size.equalTo(CGSize(width: 20, height: 20))
            make.centerY.equalTo(priceLabel)
        }

        countLabel.snp.makeConstraints { make in
            make.centerY.equalTo(addButton)
            make.right.equalTo(addButton.snp.left).offset(-5)
            make.size.equalTo(CGSize(width: 30, height: 20))
        }

        reduceButton.snp.makeConstraints { make in
            make.centerY.equalTo(addButton)
            make.right.equalTo(countLabel.snp.left).offset(-5)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
    }

    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()

        guard let product = cellModel.product else {
            return
        }

        imageView.backgroundColor = product.image
        titleLabel.text = product.title
        priceLabel.text = String(format: "$%.2f", Double(product.totalPrice()) / 100)
        countLabel.text = "\(product.count)"
    }

    @objc private func addCount() {
        guard let id = cellModel.product?.id else {
            return
        }
        sendEvent(Self.addCount, data: (id, 1))
    }

    @objc private func reduceCount() {
        guard let id = cellModel.product?.id else {
            return
        }
        sendEvent(Self.addCount, data: (id, -1))
    }
}
