//
//  RemoveCell.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/9.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import DCFrame

class RemoveCell: DCBaseCell {
    static let click = DCEventID()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        self.contentView.addSubview(label)
        return label
    }()

    fileprivate lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Remove", for: UIControl.State())
        button.setTitleColor(.blue, for: UIControl.State())
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(RemoveCell.onButton(_:)), for: .touchUpInside)
        self.contentView.addSubview(button)
        return button
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = .white
        let bounds = contentView.bounds
        let divide = bounds.divided(atDistance: 100, from: .maxXEdge)
        label.frame = divide.slice.insetBy(dx: 15, dy: 0)
        button.frame = divide.remainder
    }
    
    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()
        label.text = "Cell: \((getCellData(default: 0)) + 1)"
    }

    @objc func onButton(_ button: UIButton) {
        sendEvent(Self.click, data: baseCellModel)
    }
}
