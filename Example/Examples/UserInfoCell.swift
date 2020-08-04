//
//  UserInfoCell.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/9.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import DCFrame

class UserInfoCellModel: DCCellModel {
    var name: String
    
    init(name: String) {
        self.name = name
        super.init()
        cellHeight = 41
        cellClass = UserInfoCell.self
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}

class UserInfoCell: DCCell<UserInfoCellModel> {
    lazy var avatarView: UIView = {
        let avatarView = UIView()
        avatarView.backgroundColor = UIColor(red: 210/255.0, green: 65/255.0, blue: 64/255.0, alpha: 1)
        contentView.addSubview(avatarView)
        return avatarView
    }()
    
    lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = UIFont.boldSystemFont(ofSize: 15)
        nameLabel.textColor = UIColor.darkText
        nameLabel.textAlignment = .left
        contentView.addSubview(nameLabel)
        return nameLabel
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = contentView.bounds
        let avatarViewWidth: CGFloat = 25.0
        let avatarTopSpace: CGFloat = (bounds.height - avatarViewWidth) / 2.0
        let avatarLeftSpace: CGFloat = 8.0
        
        avatarView.frame = CGRect(x: avatarLeftSpace, y: avatarTopSpace, width: avatarViewWidth, height: avatarViewWidth)
        avatarView.layer.cornerRadius = avatarViewWidth / 2.0
        avatarView.layer.masksToBounds = true
        
        nameLabel.frame = CGRect(
            x: avatarView.frame.maxX + 8.0,
            y: avatarView.frame.minY,
            width: bounds.width - avatarView.frame.maxX - 8.0 * 2,
            height: avatarView.frame.height)
    }
    
    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()
        
        nameLabel.text = cellModel.name
    }
}
