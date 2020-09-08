//
//  SimpleLabelCell.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/9/7.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import UIKit
import DCFrame

class SimpleLabelModel: DCCellModel {
    var text: String = ""
    
    required init() {
        super.init()
        cellClass = SimpleLabelCell.self
        cellHeight = 50
    }
}

class SimpleLabelCell: DCCell<SimpleLabelModel> {
    private static let insets = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
    private static let font = UIFont.systemFont(ofSize: 17)
    
    static let touch = DCEventID()
    
    let label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.font = SimpleLabelCell.font
        return label
    }()

    private let separator: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor(red: 200 / 255.0, green: 199 / 255.0, blue: 204 / 255.0, alpha: 1).cgColor
        return layer
    }()
    
    override func setupUI() {
        super.setupUI()
        
        contentView.addSubview(label)
        contentView.layer.addSublayer(separator)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        label.frame = bounds.inset(by: Self.insets)
        let height: CGFloat = 0.5
        let left = Self.insets.left
        separator.frame = CGRect(x: left, y: bounds.height - height, width: bounds.width - left, height: height)
    }

    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()
        
        label.text = cellModel.text
        selectionStyle = .default
    }
    
    override func didSelect() {
        super.didSelect()
        sendEvent(Self.touch, data: label.text)
    }
}
