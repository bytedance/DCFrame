//
//  PhotoAlbumShowAllCell.swift
//  DCFrame_Example
//

import UIKit
import DCFrame

class PhotoAlbumShowAllCellModel: DCCellModel {
    var title = "Show All"

    required init() {
        super.init()

        isSelectionStyle = true
    }
}

class PhotoAlbumShowAllCell: DCCell<PhotoAlbumShowAllCellModel> {
    static let didSelect = DCEventID()

    private let titleLabel = UILabel()

    override func setupUI() {
        super.setupUI()

        titleLabel.textAlignment = .left
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .darkText

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
