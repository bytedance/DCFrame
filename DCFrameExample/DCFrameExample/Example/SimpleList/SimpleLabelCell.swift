//
//  SimpleLabelCell.swift
//  DCFrame_Example
//

import UIKit
import DCFrame
import SnapKit

class SimpleLabelCellModel: DCCellModel {
    var text: String = ""
    var isShowBottomLine = true

    required init() {
        super.init()
        cellHeight = 50
    }
}

class SimpleLabelCell: DCCell<SimpleLabelCellModel> {
    let label = UILabel()
    var line: UIView?

    override func setupUI() {
        super.setupUI()

        label.font = UIFont.systemFont(ofSize: 17)

        contentView.addSubview(label)
        line = contentView.addBottomLine(leftMargin: 15)

        layoutUI()
    }

    private func layoutUI() {
        label.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.centerY.equalToSuperview()
        }
    }

    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()

        label.text = cellModel.text
        line?.isHidden = !cellModel.isShowBottomLine
    }
}
