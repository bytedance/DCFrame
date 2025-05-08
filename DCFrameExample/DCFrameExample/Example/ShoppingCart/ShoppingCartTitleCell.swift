//
//  ShoppingCartTitleCell.swift
//  DCFrame_Example
//

import UIKit
import DCFrame

class ShoppingCartTitleCellModel: DCCellModel {
    var title = ""

    required init() {
        super.init()

        cellHeight = 50
    }
}

class ShoppingCartTitleCell: DCCell<ShoppingCartTitleCellModel> {
    private let titleLabel = UILabel()

    override func setupUI() {
        super.setupUI()

        titleLabel.textAlignment = .left
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textColor = .darkText

        contentView.addSubview(titleLabel)

        layoutUI()
    }

    private func layoutUI() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.centerY.equalToSuperview()
        }
    }

    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()

        titleLabel.text = cellModel.title
    }
}
