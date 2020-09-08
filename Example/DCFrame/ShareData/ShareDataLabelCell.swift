//
//  ShareDataLabelCell.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/9/8.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import UIKit
import DCFrame

class ShareDataLabelCell: SimpleLabelCell {
    static let text = DCSharedDataID()
    
    override func cellModelDidLoad() {
        super.cellModelDidLoad()
        subscribeData(Self.text) { [weak self] (text: String) in
            guard let `self` = self else { return }
            
            self.cellModel.text = text
            self.label.text = text
        }
    }
}
