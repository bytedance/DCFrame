//
//  DemosLabelCell.swift
//  DCFrame_Example
//

import UIKit
import DCFrame

class DemosLabelCellModel: SimpleLabelCellModel {
    var classInstance: Any?
}

class DemosLabelCell: SimpleLabelCell {
    static let touch = DCEventID()

    override func didSelect() {
        super.didSelect()
        sendEvent(Self.touch, data: cellModel)
    }
}
