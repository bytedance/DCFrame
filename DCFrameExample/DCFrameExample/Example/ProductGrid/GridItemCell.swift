//
//  GridItemCell.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2021/12/31.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import DCFrame
import Then

class GridItemCellModel: DCCellModel {
    var text = ""
    var color = UIColor.systemBlue
}

class GridItemCell: DCCell<GridItemCellModel> {
    private var label = UILabel().then {
        $0.textAlignment = .center
        $0.font = .boldSystemFont(ofSize: 18)
        $0.textColor = .white
    }

    override func setupUI() {
        super.setupUI()

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
