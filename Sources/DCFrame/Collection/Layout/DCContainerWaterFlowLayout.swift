//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import UIKit

public class DCContainerWaterFlowLayout: DCContainerLayoutable {
    public init(columnCount: Int = 2) {
        fixedColumnCount = columnCount
    }

    public var fixedColumnCount = 2

    public func layoutAttributes(_ collectionView: DCCollectionView, containerModel: DCContainerModel, startOrigin: CGPoint) -> DCContainerLayoutData? {
        assert(collectionView.scrollDirection == .vertical, "WaterFlowLayout does not support horizontal")

        var layoutData = DCContainerLayoutData()
        var curOrigin = startOrigin

        layoutData.contentBounds.origin = curOrigin
        layoutData.contentBounds.size.height += containerModel.getTopMargin() ?? 0

        curOrigin.y += containerModel.getTopMargin() ?? 0
        
        var curFrame: CGRect = CGRect(origin: curOrigin, size: .zero)
        var isNewContainerModel = true

        let cvSize = collectionView.bounds.size
        let cellHorizontalSpacing = containerModel.getHorizontalInterval(true) ?? 0
        let cellVerticalSpacing = containerModel.getVerticalInterval(true) ?? 0
        let leftMargin = containerModel.getLeftMargin(true) ?? 0
        let rightMargin = containerModel.getRightMargin(true) ?? 0
        var preLineFrames = [CGRect]()

        func handleModelLayout(_ model: DCCellModel) {
            guard let indexPath = model.indexPath else { return }

            let cellSize = model.getCellSize()

            if model.isBackgroundCell {
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(origin: CGPoint(x: 0, y: curOrigin.y), size: cellSize)
                attributes.zIndex = -1

                layoutData.attributes.append(attributes)
                layoutData.contentBounds = layoutData.contentBounds.union(attributes.frame)

                return
            }

            if isNewContainerModel {
                curFrame.origin.x = leftMargin
            } else {
                curFrame.origin.x += curFrame.size.width + cellHorizontalSpacing
            }
            curFrame.size = model.getCellSize()

            if preLineFrames.count < fixedColumnCount {
                preLineFrames.append(curFrame)
                assert((curFrame.maxX + rightMargin) <= cvSize.width, "The item width exceeds the width of the `CollectionView`")
            } else {
                var minYIndex = 0
                var minFrame = preLineFrames[minYIndex]
                for (index, frame) in preLineFrames.enumerated() where index > 0 {
                    if minFrame.maxY > frame.maxY {
                        minFrame = frame
                        minYIndex = index
                    }
                }

                assert(cellSize.width == minFrame.width, "The width of the items in the `WaterFlowLayout` must be equal")

                curFrame = CGRect(origin: CGPoint(x: minFrame.minX, y: minFrame.maxY + cellVerticalSpacing), size: cellSize)
                preLineFrames[minYIndex] = curFrame
            }

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = curFrame
            curOrigin.y = max(curOrigin.y, curFrame.maxY)

            layoutData.attributes.append(attributes)
            layoutData.contentBounds = layoutData.contentBounds.union(attributes.frame)

            isNewContainerModel = false
        }

        for item in containerModel.modelArray {
            if let model = item as? DCCellModel, !model.isHidden {
                handleModelLayout(model)
            } else if let containerModel = item as? DCContainerModel, !containerModel.isHidden,
                      let ld = containerModel.getCustomLayout().layoutAttributes(
                        collectionView,
                        containerModel: containerModel,
                        startOrigin: CGPoint(x: curOrigin.x, y: layoutData.contentBounds.maxY)) {
                layoutData.attributes.append(contentsOf: ld.attributes)
                layoutData.contentBounds = layoutData.contentBounds.union(ld.contentBounds)

                curOrigin.y = max(curOrigin.y, ld.contentBounds.maxY)
                isNewContainerModel = true
            }
        }

        layoutData.contentBounds.size.height += containerModel.getBottomMargin() ?? 0
        containerModel.contentFrame = layoutData.contentBounds

        return layoutData
    }
}
