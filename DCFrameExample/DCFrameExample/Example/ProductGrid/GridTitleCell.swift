//
//  GridTitleCell.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2021/12/31.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import DCFrame
import Then

class GridTitleCellModel: DCCellModel {
    var title = ""

    required init() {
        super.init()

        cellHeight = 50
    }
}

class GridTitleCell: DCCell<GridTitleCellModel> {
    private var titleLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = .boldSystemFont(ofSize: 17)
        $0.textColor = .darkText
    }

    override func setupUI() {
        super.setupUI()

        contentView.addSubview(titleLabel)

        layoutUI()
    }

    private func layoutUI() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.centerY.equalToSuperview()
        }
    }

    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()

        titleLabel.text = cellModel.title
    }
}
