//
//  MonthTitleCell.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/9.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import DCFrame

class MonthTitleCell: DCBaseCell {
    fileprivate lazy var label: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .center
        view.textColor = UIColor(white: 0.7, alpha: 1)
        view.font = .boldSystemFont(ofSize: 13)
        self.contentView.addSubview(view)
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds
    }
    
    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()
        
        label.text = getCellData(default: "")
    }
}
