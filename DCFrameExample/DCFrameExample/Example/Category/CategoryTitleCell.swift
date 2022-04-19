//
//  ShoppingCartTitleCell.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2022/1/5.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import DCFrame
import Then

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

    private var titleLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .darkText
        $0.numberOfLines = 2
    }

    override func setupUI() {
        super.setupUI()

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
