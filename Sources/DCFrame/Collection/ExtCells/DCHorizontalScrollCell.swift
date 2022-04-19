//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import UIKit

public class DCHorizontalScrollCellModel: DCCellModel {
    let containerModel: DCContainerModel

    public required init(with containerModel: DCContainerModel, height: CGFloat) {
        self.containerModel = containerModel
        super.init()

        cellHeight = height
        reuseIdentifier = "\(reuseIdentifier)_\(DCEDCUniqueID().ID)"
    }

    public required init() {
        fatalError("init() has not been implemented")
    }
}

open class DCHorizontalScrollCell: DCCell<DCHorizontalScrollCellModel> {
    let collectionView = DCCollectionView()

    open override func setupUI() {
        super.setupUI()

        collectionView.scrollDirection = .horizontal
        collectionView.alwaysBounceVertical = false
        collectionView.showsHorizontalScrollIndicator = false

        contentView.addSubview(collectionView)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        collectionView.frame = contentView.bounds
    }

    open override func cellModelDidUpdate() {
        super.cellModelDidUpdate()

        if collectionView.eventDataController.parentEDC !== eventDataController {
            eventDataController.addChildEDC(collectionView.eventDataController)
        }
        
        if cellModel.containerModel !== collectionView.containerModel {
            collectionView.frame = contentView.bounds
            collectionView.loadContainerModel(cellModel.containerModel)
        }
    }
}
