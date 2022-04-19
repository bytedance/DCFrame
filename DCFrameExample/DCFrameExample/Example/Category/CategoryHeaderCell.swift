//
//  File.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2022/1/5.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import DCFrame
import Then

class CategoryHeaderCellModel: DCCellModel {
    var title = ""

    required init() {
        super.init()

        cellHeight = 30
        isHoverTop = true
    }
}

class CategoryHeaderCell: DCCell<CategoryHeaderCellModel> {
    private var titleLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = .boldSystemFont(ofSize: 15)
        $0.textColor = .gray
    }

    override func setupUI() {
        super.setupUI()

        contentView.addSubview(titleLabel)

        layoutUI()
    }

    private func layoutUI() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.centerY.equalToSuperview()
        }
    }

    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()

        titleLabel.text = cellModel.title
    }
}
