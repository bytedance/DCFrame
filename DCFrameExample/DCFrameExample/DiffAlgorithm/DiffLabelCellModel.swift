//
//  DiffLabelCellModel.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/9/8.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import UIKit
import DCFrame

class DiffLabelCellModel: SimpleLabelModel {
    override var hash: Int {
        return text.hashValue
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let model = object as? DiffLabelCellModel else {
            return false
        }
        return model.text == text
    }
}

