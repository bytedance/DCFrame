//
//  ShoppingCartProductCell.swift
//  DCFrame_Example
//

import UIKit
import DCFrame

class ShoppingCartProductCellModel: DCCellModel {
    var product: ShoppingCartStoreProduct?

    required init() {
        super.init()

        cellHeight = 120
    }
}

class ShoppingCartProductCell: DCCell<ShoppingCartProductCellModel> {
    static let addCount = DCEventID()

    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let imageView = UIView()
    private let countLabel = UILabel()
    private let addButton = UIButton()
    private let reduceButton = UIButton()

    override func setupUI() {
        super.setupUI()

        titleLabel.font = .systemFont(ofSize: 15)
        titleLabel.textColor = .black

        priceLabel.font = .boldSystemFont(ofSize: 18)
        priceLabel.textColor = .black

        imageView.backgroundColor = UIColor.systemGray

        countLabel.font = .systemFont(ofSize: 12)
        countLabel.textColor = .black
        countLabel.textAlignment = .center
        countLabel.layer.backgroundColor = UIColor.lightGray.cgColor
        countLabel.layer.cornerRadius = 4

        addButton.setTitle("+", for: .normal)
        addButton.setTitleColor(.black, for: .normal)

        reduceButton.setTitle("-", for: .normal)
        reduceButton.setTitleColor(.black, for: .normal)

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
