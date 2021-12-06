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
    static let touch = DCEventID()
    
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()

    let separateLine: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.lightGray.cgColor
        return layer
    }()
    
    override func setupUI() {
        super.setupUI()
        
        contentView.addSubview(label)
        contentView.layer.addSublayer(separateLine)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        let left: CGFloat = 15
        let height: CGFloat = 1.0 / UIScreen.main.scale
        
        label.frame = bounds.inset(by: UIEdgeInsets(top: 8, left: left, bottom: 8, right: 15))
        separateLine.frame = CGRect(x: left, y: bounds.height - height, width: bounds.width - left, height: height)
    }

    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()
        
        label.text = cellModel.text
    }
    
    override func didSelect() {
        super.didSelect()
        sendEvent(Self.touch, data: label.text)
    }
}
