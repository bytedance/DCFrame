//
//  ShoppingCartTitleCell.swift
//  DCFrame_Example
//

import UIKit
import DCFrame

class CategoryTitleCellModel: DCCellModel {
    var title = ""
    var isSelect = false

    required init() {
        super.init()

        cellHeight = 60
    }
}

class CategoryTitleCell: DCCell<CategoryTitleCellModel> {
    static let didSelect = DCEventID()

    private let titleLabel = UILabel()

    override func setupUI() {
        super.setupUI()

        titleLabel.textAlignment = .left
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .darkText
        titleLabel.numberOfLines = 2

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

        contentView.backgroundColor = cellModel.isSelect ? .white : UIColor.lightGray.withAlphaComponent(0.2)
    }

    override func didSelect() {
        super.didSelect()

        sendEvent(Self.didSelect, data: cellModel)
    }
}
