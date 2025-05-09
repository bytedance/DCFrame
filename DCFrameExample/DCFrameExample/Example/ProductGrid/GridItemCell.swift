//
//  GridItemCell.swift
//  DCFrame_Example
//

import UIKit
import DCFrame

class GridItemCellModel: DCCellModel {
    var text = ""
    var color = UIColor.systemBlue
}

class GridItemCell: DCCell<GridItemCellModel> {
    private let label = UILabel()

    override func setupUI() {
        super.setupUI()

        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white

        contentView.addSubview(label)

        layoutUI()
    }

    private func layoutUI() {
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()

        label.text = cellModel.text
        contentView.backgroundColor = cellModel.color
    }
}
