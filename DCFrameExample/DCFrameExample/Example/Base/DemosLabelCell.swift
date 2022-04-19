//
//  DemosLabelCell.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2021/12/30.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import DCFrame

class DemosLabelCellModel: SimpleLabelCellModel {
    var vcClass: UIViewController.Type?
}

class DemosLabelCell: SimpleLabelCell {
    static let touch = DCEventID()

    override func didSelect() {
        super.didSelect()
        sendEvent(Self.touch, data: cellModel)
    }
}
