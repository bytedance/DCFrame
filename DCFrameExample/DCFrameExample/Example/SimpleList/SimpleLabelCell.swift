//
//  SimpleLabelCell.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/9/7.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import UIKit
import DCFrame
import SnapKit
import Then

class SimpleLabelCellModel: DCCellModel {
    var text: String = ""
    var isShowBottomLine = true

    required init() {
        super.init()
        cellHeight = 50
    }
}

class SimpleLabelCell: DCCell<SimpleLabelCellModel> {
    let label = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17)
    }

    var line: UIView?

    override func setupUI() {
        super.setupUI()

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
