//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import UIKit

public enum DCSeparatorPositionType {
    case top
    case bottom
}

public final class DCSeparatorModel: DCCellModel {
    public var color: UIColor?
    
    public required init(color: UIColor, height: CGFloat) {
        super.init()
        self.color = color
        self.cellHeight = height
        self.cellClass = DCSeparatorCell.self
    }
 
    public required init() {
        super.init()
        cellClass = DCSeparatorCell.self
    }
    
    public override func getCellHeight() -> CGFloat {
        if cellHeight > 0 {
            return cellHeight
        } else if let height = containerModel?.containerTableView?.cellSeparatorHeight {
            return height
        } else {
            return DCConfig.shared.cellSeparatorHeight
        }
    }
}

public final class DCSeparatorCell: DCCell<DCSeparatorModel> {
    public override func cellModelDidUpdate() {
        super.cellModelDidUpdate()
        if let color = cellModel.color {
            backgroundColor = color
        } else if let color = containerTableView?.cellSeparatorColor {
            backgroundColor = color
        } else {
            backgroundColor = DCConfig.shared.cellSeparatorColor
        }
    }
}
