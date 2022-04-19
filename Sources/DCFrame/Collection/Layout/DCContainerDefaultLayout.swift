//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import UIKit

public class DCContainerDefaultLayout: DCContainerLayoutable {
    public init() {
        // do nothing
    }

    public func layoutAttributes(_ layoutData: DCContainerLayoutData, _ collectionView: DCCollectionView, containerModel: DCContainerModel, startOrigin: CGPoint) {
        if collectionView.scrollDirection == .vertical {
            verticalLayout(layoutData, collectionView, containerModel: containerModel, startOrigin: startOrigin)
        } else {
            horizontalLayout(layoutData, collectionView, containerModel: containerModel, startOrigin: startOrigin)
        }
    }

    private func verticalLayout(_ layoutData: DCContainerLayoutData, _ collectionView: DCCollectionView, containerModel: DCContainerModel, startOrigin: CGPoint) {
        var curOrigin = startOrigin
        curOrigin.y += containerModel.getTopMargin() ?? 0
        layoutData.contentBounds.size.height += containerModel.getTopMargin() ?? 0

        var curFrame: CGRect = CGRect(origin: curOrigin, size: .zero)

        let cvSize = collectionView.bounds.size
        let cellHorizontalSpacing = containerModel.getHorizontalInterval(true) ?? 0
        let cellVerticalSpacing = containerModel.getVerticalInterval(true) ?? 0
        let leftMargin = containerModel.getLeftMargin(true) ?? 0
        let rightMargin = containerModel.getRightMargin(true) ?? 0
        
        var needResizeCellIndexs = [IndexPath]()
        var isNewContainerModel = true

        func handleModelLayout(_ model: DCCellModel) {
            guard let indexPath = model.indexPath else { return }

            let cellSize = model.getCellSize(collectionViewWidth: collectionView.dc_width)

            if model.isBackgroundCell {
                assert(!model.getIsHoverTop(), "The `isBackgroundCell` and `isHoverTop` cannot be set to true at the same time")
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(origin: CGPoint(x: 0, y: startOrigin.y), size: cellSize)
                attributes.zIndex = -1
                layoutData.attributes.append(attributes)
                layoutData.backgroundCellIndexPaths.append(indexPath)
                
                if cellSize == .zero {
                    needResizeCellIndexs.append(indexPath)
                } else {
                    layoutData.contentBounds = layoutData.contentBounds.union(attributes.frame)
                }

                return
            }

            curFrame.origin.x += curFrame.size.width + cellHorizontalSpacing
            curFrame.size = cellSize

            let isNewLine = (curFrame.maxX > (cvSize.width - rightMargin) && curFrame.minX != 0) || isNewContainerModel || model.isNewLine
            if isNewLine {
                assert(curFrame.width <= cvSize.width, "The item width exceeds the width of the `CollectionView`")

                let tmpLeftMargin = (leftMargin + curFrame.width) > cvSize.width ? 0 : leftMargin
                let tmpLineSpacing = isNewContainerModel ? 0 : cellVerticalSpacing

                curFrame.origin = CGPoint(x: tmpLeftMargin, y: curOrigin.y + tmpLineSpacing)
                
                layoutData.lineAttributesArray.append(DCContainerLayoutData.LineAttributes(lineFrame: curFrame))
            }
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = curFrame
            layoutData.attributes.append(attributes)
            layoutData.contentBounds = layoutData.contentBounds.union(curFrame)
            
            if let currentLineAttributes = layoutData.lineAttributesArray.last {
                currentLineAttributes.itemIndexPaths.append(indexPath)
                currentLineAttributes.lineFrame = currentLineAttributes.lineFrame.union(curFrame)
            }

            curOrigin.y = max(curOrigin.y, curFrame.maxY)
            isNewContainerModel = false
        }

        for item in containerModel.modelArray {
            if let model = item as? DCCellModel {
                handleModelLayout(model)
            } else if let containerModel = item as? DCContainerModel {
                containerModel.getCustomLayout().layoutAttributes(layoutData, collectionView, containerModel: containerModel, startOrigin: CGPoint(x: curOrigin.x, y: layoutData.contentBounds.maxY))
                curOrigin.y = max(curOrigin.y, layoutData.contentBounds.maxY)
                isNewContainerModel = true
            }
        }

        layoutData.contentBounds.size.height += containerModel.getBottomMargin() ?? 0
        
        needResizeCellIndexs.forEach { indexPath in
            if let bgCellAttributes = layoutData.attributes[dc_safe: indexPath.item] {
                bgCellAttributes.frame.size = CGSize(width: cvSize.width, height: layoutData.contentBounds.size.height - startOrigin.y)
            }
        }
    }

    private func horizontalLayout(_ layoutData: DCContainerLayoutData, _ collectionView: DCCollectionView, containerModel: DCContainerModel, startOrigin: CGPoint) {
        var curOrigin = startOrigin
        curOrigin.x += containerModel.getLeftMargin() ?? 0
        layoutData.contentBounds.size.width += containerModel.getLeftMargin() ?? 0

        var curFrame: CGRect = CGRect(origin: curOrigin, size: .zero)

        let cvSize = collectionView.bounds.size
        let cellHorizontalSpacing = containerModel.getHorizontalInterval(true) ?? 0
        let cellVerticalSpacing = containerModel.getVerticalInterval(true) ?? 0
        let topMargin = containerModel.getTopMargin(true) ?? 0
        let bottomMargin = containerModel.getBottomMargin(true) ?? 0
        
        var isNewContainerModel = true
        var needResizeCellIndexs = [IndexPath]()

        func handleModelLayout(_ model: DCCellModel) {
            guard let indexPath = model.indexPath else { return }

            let cellSize = model.getCellSize(collectionViewWidth: collectionView.dc_width)

            if model.isBackgroundCell {
                assert(!model.getIsHoverTop(), "The `isBackgroundCell` and `isHoverTop` cannot be set to true at the same time")
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(origin: CGPoint(x: startOrigin.x, y: 0), size: cellSize)
                attributes.zIndex = -1
                layoutData.attributes.append(attributes)
                layoutData.backgroundCellIndexPaths.append(indexPath)

                if cellSize == .zero {
                    needResizeCellIndexs.append(indexPath)
                } else {
                    layoutData.contentBounds = layoutData.contentBounds.union(attributes.frame)
                }
                
                return
            }

            curFrame.origin.y += curFrame.size.height + cellVerticalSpacing
            curFrame.size = cellSize

            let isNewLine = (curFrame.maxY > (cvSize.height - bottomMargin) && curFrame.minY != 0) || isNewContainerModel || model.isNewLine

            if isNewLine {
                assert(curFrame.height <= cvSize.height, "The item height exceeds the height of the `CollectionView`")

                let tmpTopMargin = (topMargin + curFrame.height) > cvSize.height ? 0 : topMargin
                let tmpLineSpacing = isNewContainerModel ? 0 : cellHorizontalSpacing

                curFrame.origin = CGPoint(x: curOrigin.x + tmpLineSpacing, y: tmpTopMargin)
                
                layoutData.lineAttributesArray.append(DCContainerLayoutData.LineAttributes(lineFrame: curFrame))
            }
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = curFrame
            layoutData.attributes.append(attributes)
            layoutData.contentBounds = layoutData.contentBounds.union(curFrame)
                
            if let currentLineAttributes = layoutData.lineAttributesArray.last {
                currentLineAttributes.itemIndexPaths.append(indexPath)
                currentLineAttributes.lineFrame = currentLineAttributes.lineFrame.union(curFrame)
            }
           
            curOrigin.x = max(curOrigin.x, curFrame.maxX)
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
                    startOrigin: CGPoint(x: layoutData.contentBounds.maxX, y: curOrigin.y))
                curOrigin.x = max(curOrigin.x, layoutData.contentBounds.maxX)
                isNewContainerModel = true
            }
        }

        layoutData.contentBounds.size.width += containerModel.getRightMargin() ?? 0
        
        needResizeCellIndexs.forEach { indexPath in
            if let bgCellAttributes = layoutData.attributes[dc_safe: indexPath.item] {
                bgCellAttributes.frame.size = CGSize(width: layoutData.contentBounds.size.width - startOrigin.x, height: cvSize.height)
            }
        }
    }
}


extension DCContainerModel {
    func getTopMargin(_ isInherit: Bool = false) -> CGFloat? {
        if isInherit {
            return getLayoutContext()?.topMargin ?? parentContainerModel?.getTopMargin(isInherit)
        }
        return getLayoutContext()?.topMargin
    }

    func getBottomMargin(_ isInherit: Bool = false) -> CGFloat? {
        if isInherit {
            return getLayoutContext()?.bottomMargin ?? parentContainerModel?.getBottomMargin(isInherit)
        }
        return getLayoutContext()?.bottomMargin
    }

    func getLeftMargin(_ isInherit: Bool = false) -> CGFloat? {
        if isInherit {
            return getLayoutContext()?.leftMargin ?? parentContainerModel?.getLeftMargin(isInherit)
        }
        return getLayoutContext()?.leftMargin
    }

    func getRightMargin(_ isInherit: Bool = false) -> CGFloat? {
        if isInherit {
            return getLayoutContext()?.rightMargin ?? parentContainerModel?.getRightMargin(isInherit)
        }
        return getLayoutContext()?.rightMargin
    }

    func getVerticalInterval(_ isInherit: Bool = false) -> CGFloat? {
        if isInherit {
            return getLayoutContext()?.verticalInterval ?? parentContainerModel?.getVerticalInterval(isInherit)
        }
        return getLayoutContext()?.verticalInterval
    }

    func getHorizontalInterval(_ isInherit: Bool = false) -> CGFloat? {
        if isInherit {
            return getLayoutContext()?.horizontalInterval ?? parentContainerModel?.getHorizontalInterval(isInherit)
        }
        return getLayoutContext()?.horizontalInterval
    }
}
