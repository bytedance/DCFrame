//
//  UserCell.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/8.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import DCFrame

class UserModel: DCCellModel {
    let name: String
    let handle: String

    init(name: String, handle: String) {
        self.name = name
        self.handle = handle
        super.init()
        
        cellClass = UserCell.self
        cellHeight = 55
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}

class UserCell: DCCell<UserModel> {
    fileprivate let padding: CGFloat = 15.0
    
    lazy private var titleLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .left
        view.font = .systemFont(ofSize: 17)
        view.textColor = .darkText
        self.contentView.addSubview(view)
        return view
    }()

    lazy private var detailLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .right
        view.font = .systemFont(ofSize: 17)
        view.textColor = .lightGray
        self.contentView.addSubview(view)
        return view
    }()
    
    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()
        
        titleLabel.text = cellModel.name
        detailLabel.text = "@" + cellModel.handle
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = contentView.bounds.insetBy(dx: padding, dy: 0)
        titleLabel.frame = frame
        detailLabel.frame = frame
    }
}
