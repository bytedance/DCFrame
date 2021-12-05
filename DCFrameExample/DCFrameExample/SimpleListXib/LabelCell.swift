//
//  XibCell.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/3/27.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import UIKit
import DCFrame

class LabelModel: DCCellModel {
    var text: String = ""
    
    required init() {
        super.init()
        cellClass = LabelCell.self
        isXibCell = true
        isAutomaticDimension = true
    }
}

class LabelCell: DCCell<LabelModel> {
    static let touch = DCEventID()

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var separateLine: UIView!

    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()
        
        label.text = cellModel.text
    }
}
