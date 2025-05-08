//
//  GridTitleCell.swift
//  DCFrame_Example
//

import UIKit
import DCFrame

class GridTitleCellModel: DCCellModel {
    var title = ""

    required init() {
        super.init()

        cellHeight = 50
    }
}

class GridTitleCell: DCCell<GridTitleCellModel> {
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
