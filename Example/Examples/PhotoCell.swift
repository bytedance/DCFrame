//
//  PhotoCell.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/9.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import DCFrame

class PhotoCellModel: DCCellModel {
    static let data = DCSharedDataID()
    
    var text = ""
    var color: UIColor = UIColor(red: 4/255.0, green: 170/255.0, blue: 166/255.0, alpha: 1.0)

    required init() {
        super.init()
        
        cellClass = PhotoCell.self
        cellHeight = 375
    }
    
    override func cellModelDidLoad() {
        super.cellModelDidLoad()
        
        subscribeData(Self.data) { [weak self] (text: String, color: UIColor) in
            self?.text = text
            self?.color = color
            self?.needReloadCellData()
        }
    }
}

class PhotoCell: DCCell<PhotoCellModel> {
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.darkText
        label.textAlignment = .center
        contentView.addSubview(label)
        return label
    }()

    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()
        
        infoLabel.text = cellModel.text
        contentView.backgroundColor = cellModel.color
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        infoLabel.frame = CGRect(x: 0, y: 0, width: bounds.width, height: infoLabel.font.lineHeight)
        infoLabel.center = CGPoint(x: contentView.bounds.width / 2, y: contentView.bounds.height / 2)
    }
}
