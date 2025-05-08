//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import UIKit

public final class DCSeparatorCellModel: DCCellModel {
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
        } else if let height = dcContainerModel?.dcContainerView?.cellSeparatorHeight {
            return height
        } else {
            return DCContainerConfig.cellSeparatorHeight
        }
    }
}

public final class DCSeparatorCell: DCCell<DCSeparatorCellModel> {
    public override func cellModelDidUpdate() {
        super.cellModelDidUpdate()

        if let color = cellModel.color {
            backgroundColor = color
        } else if let color = dcContainerView?.cellSeparatorColor {
            backgroundColor = color
        } else {
            backgroundColor = DCContainerConfig.cellSeparatorColor
        }
    }
}
