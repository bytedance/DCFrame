//
//  PhotoAlbumShowAllCell.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2021/12/31.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import DCFrame
import Then

class PhotoAlbumShowAllCellModel: DCCellModel {
    var title = "Show All"

    required init() {
        super.init()

        isSelectionStyle = true
    }
}

class PhotoAlbumShowAllCell: DCCell<PhotoAlbumShowAllCellModel> {
    static let didSelect = DCEventID()

    private var titleLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .darkText
    }

    override func setupUI() {
        super.setupUI()

        contentView.addSubview(titleLabel)
        contentView.layer.cornerRadius = 5

        layoutUI()
    }

    private func layoutUI() {
        titleLabel.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.left.centerY.equalToSuperview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        isHidden = false
    }

    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()

        titleLabel.text = cellModel.title
    }

    override func didSelect() {
        super.didSelect()

        isHidden = true // Avoid flickering during animation
        sendEvent(Self.didSelect)
    }
}
