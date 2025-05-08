//
//  File.swift
//  DCFrame_Example
//

import UIKit
import DCFrame

class CategoryHeaderCellModel: DCCellModel {
    var title = ""

    required init() {
        super.init()

        cellHeight = 30
        isHoverTop = true
    }
}

class CategoryHeaderCell: DCCell<CategoryHeaderCellModel> {
    private let titleLabel = UILabel()

    override func setupUI() {
        super.setupUI()

        titleLabel.textAlignment = .left
        titleLabel.font = .boldSystemFont(ofSize: 15)
        titleLabel.textColor = .gray

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
