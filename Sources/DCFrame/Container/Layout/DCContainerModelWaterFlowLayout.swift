//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import UIKit

public class DCContainerModelWaterFlowLayout: DCContainerModelLayoutDelegate {
    public init(columnCount: Int = 2) {
        fixedColumnCount = columnCount
    }

    public var fixedColumnCount = 2

    public func layoutAttributes(_ layoutData: DCContainerViewLayoutData, _ collectionView: DCContainerView, containerModel: DCContainerModel, startOrigin: CGPoint) {
        assert(collectionView.scrollDirection == .vertical, "WaterFlowLayout does not support horizontal")

        var curOrigin = startOrigin
        curOrigin.y += containerModel.getTopMargin() ?? 0
        layoutData.contentBounds.size.height += containerModel.getTopMargin() ?? 0
        
        var curFrame: CGRect = CGRect(origin: curOrigin, size: .zero)

        let cvSize = collectionView.bounds.size
        let cellHorizontalSpacing = containerModel.getHorizontalInterval(true) ?? 0
        let cellVerticalSpacing = containerModel.getVerticalInterval(true) ?? 0
        let leftMargin = containerModel.getLeftMargin(true) ?? 0
        let rightMargin = containerModel.getRightMargin(true) ?? 0
        var preLineFrames = [CGRect]()
        
        var preLineFrameMaxY = CGFloat.leastNormalMagnitude
        var preLineItemCount = 0
        
        var isNewContainerModel = true
        var needResizeCellIndex = [IndexPath]()

        func handleModelLayout(_ model: DCCellModel) {
            guard let indexPath = model.indexPath else { return }

            let cellSize = model.getCellSize(collectionViewWidth: collectionView.frame.size.width)

            if model.isBackgroundCell {
                assert(!model.getIsHoverTop(), "The `isBackgroundCell` and `isHoverTop` cannot be set to true at the same time")
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(origin: CGPoint(x: 0, y: startOrigin.y), size: cellSize)
                attributes.zIndex = -1
                layoutData.attributes.append(attributes)
                layoutData.backgroundCellIndexPaths.append(indexPath)
                
                if cellSize == .zero {
                    needResizeCellIndex.append(indexPath)
                } else {
                    layoutData.contentBounds = layoutData.contentBounds.union(attributes.frame)
                }
                
                return
            }

            if isNewContainerModel {
                curFrame.origin.x = leftMargin
            } else {
                curFrame.origin.x += curFrame.size.width + cellHorizontalSpacing
            }
            curFrame.size = cellSize

            if preLineFrames.count < fixedColumnCount {
                preLineFrames.append(curFrame)
                assert((curFrame.maxX + rightMargin) <= cvSize.width, "The item width exceeds the width of the `CollectionView`")
            } else {
                var minYIndex = 0
                var minFrame = preLineFrames[dc_safe: minYIndex] ?? CGRect.zero
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
            
            let isNewLine = (preLineItemCount >= fixedColumnCount && curFrame.maxY > preLineFrameMaxY) || isNewContainerModel
            if isNewLine {
                layoutData.lineAttributesArray.append(DCContainerViewLayoutData.LineAttributes(lineFrame: curFrame))
                preLineItemCount = 0
            }

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = curFrame
            layoutData.attributes.append(attributes)
            layoutData.contentBounds = layoutData.contentBounds.union(curFrame)
            
            if model.getIsHoverTop(), let hoverIndexPath = model.hoverIndexPath {
                attributes.isHidden = true
                let hoverAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: DCContainerView.elementKindHoverTop, with: hoverIndexPath)
                hoverAttributes.zIndex = 10
                hoverAttributes.frame = curFrame
                layoutData.hoverAttributes.append(hoverAttributes)
                layoutData.originHoverAttributes.append(hoverAttributes.copy() as? UICollectionViewLayoutAttributes ?? hoverAttributes)
                let offsetY = collectionView.contentOffset.y + (collectionView.hoverViewOffset ?? collectionView.contentInset.top)
                if let curHoverAttributes = layoutData.currentHoverAttributes, curFrame.origin.y < curHoverAttributes.frame.height + offsetY {
                    curHoverAttributes.frame.origin.y = curFrame.origin.y - curHoverAttributes.frame.height
                }
                if curFrame.origin.y < offsetY {
                    hoverAttributes.frame.origin.y = offsetY
                    layoutData.currentHoverAttributes = hoverAttributes
                }
            }
            
            if let currentLineAttributes = layoutData.lineAttributesArray.last {
                currentLineAttributes.itemIndexPaths.append(indexPath)
                currentLineAttributes.lineFrame = currentLineAttributes.lineFrame.union(curFrame)
                preLineFrameMaxY = currentLineAttributes.lineFrame.maxY
                preLineItemCount += 1
            }

            curOrigin.y = max(curOrigin.y, curFrame.maxY)
            isNewContainerModel = false
        }

        for item in containerModel.modelArray {
            if let model = item as? DCCellModel {
                handleModelLayout(model)
            } else if let containerModel = item as? DCContainerModel {
                containerModel.getCustomLayout().layoutAttributes(
                    layoutData,
                    collectionView,
                    containerModel: containerModel,
                    startOrigin: CGPoint(x: curOrigin.x, y: layoutData.contentBounds.maxY))
                curOrigin.y = max(curOrigin.y, layoutData.contentBounds.maxY)
                isNewContainerModel = true
            }
        }

        layoutData.contentBounds.size.height += containerModel.getBottomMargin() ?? 0
        
        needResizeCellIndex.forEach { indexPath in
            if let bgCellAttributes = layoutData.attributes[dc_safe: indexPath.item] {
                bgCellAttributes.frame.size = CGSize(width: cvSize.width, height: layoutData.contentBounds.size.height - startOrigin.y)
            }
        }
    }
}
