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
    
    override var hash: Int {
        return text.hashValue
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let model = object as? LabelModel else {
            return false
        }
        return model.text == text
    }
}

class LabelCell: DCCell<LabelModel> {
    static let touch = DCEventID()
    static let text = DCSharedDataID()
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var separateLine: UIView!
    
    override func cellModelDidLoad() {
        super.cellModelDidLoad()
        
        subscribeData(Self.text) { [weak self] (text: String) in
            self?.label.text = text
        }
    }

    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()
        
        if cellModel.text.isEmpty {
            label.text = getCellData(default: "error")
        } else {
            label.text = cellModel.text
        }
    }
    
    override func didSelect() {
        super.didSelect()
        sendEvent(Self.touch, data: label.text)
    }
}
