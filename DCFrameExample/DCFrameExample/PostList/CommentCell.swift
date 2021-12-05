//
//  CommentCell.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/9.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import DCFrame

class CommentCellModel: DCCellModel {
    var comment: String!
    
    required init() {
        super.init()
        cellClass = CommentCell.self
        cellHeight = 25
    }
}

class CommentCell: DCCell<CommentCellModel> {
    lazy var commentLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 0.59, green: 0.59, blue: 0.57, alpha: 1.0)
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 11)
        contentView.addSubview(label)
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let left: CGFloat = 8.0
        let bounds = contentView.bounds
        commentLabel.frame = CGRect(x: left, y: 0, width: bounds.size.width - left * 2.0, height: bounds.size.height)
    }
    
    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()
        
        commentLabel.text = cellModel.comment
    }
}
