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

    public func layoutAttributes(_ collectionView: DCCollectionView, containerModel: DCContainerModel, startOrigin: CGPoint) -> DCContainerLayoutData? {
        if collectionView.scrollDirection == .vertical {
            return verticalLayout(collectionView, containerModel: containerModel, startOrigin: startOrigin)
        } else {
            return horizontalLayout(collectionView, containerModel: containerModel, startOrigin: startOrigin)
        }
    }

    private func verticalLayout(_ collectionView: DCCollectionView, containerModel: DCContainerModel, startOrigin: CGPoint) -> DCContainerLayoutData? {
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

            curFrame.origin.x += curFrame.size.width + cellHorizontalSpacing
            curFrame.size = cellSize

            let isNewLine = (curFrame.maxX > (cvSize.width - rightMargin) && curFrame.minX != 0) || isNewContainerModel

            if isNewLine {
                assert(curFrame.width <= cvSize.width, "The item width exceeds the width of the `CollectionView`")

                let tmpLeftMargin = (leftMargin + curFrame.width) > cvSize.width ? 0 : leftMargin
                let tmpLineSpacing = isNewContainerModel ? 0 : cellVerticalSpacing

                curFrame.origin = CGPoint(x: tmpLeftMargin, y: curOrigin.y + tmpLineSpacing)
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

    private func horizontalLayout(_ collectionView: DCCollectionView, containerModel: DCContainerModel, startOrigin: CGPoint) -> DCContainerLayoutData? {
        var layoutData = DCContainerLayoutData()
        var curOrigin = startOrigin

        layoutData.contentBounds.origin = curOrigin
        layoutData.contentBounds.size.width += containerModel.getLeftMargin() ?? 0

        curOrigin.x += containerModel.getLeftMargin() ?? 0

        var curFrame: CGRect = CGRect(origin: curOrigin, size: .zero)
        var isNewContainerModel = true

        let cvSize = collectionView.bounds.size
        let cellHorizontalSpacing = containerModel.getHorizontalInterval(true) ?? 0
        let cellVerticalSpacing = containerModel.getVerticalInterval(true) ?? 0
        let topMargin = containerModel.getTopMargin(true) ?? 0
        let bottomMargin = containerModel.getBottomMargin(true) ?? 0

        func handleModelLayout(_ model: DCCellModel) {
            guard let indexPath = model.indexPath else { return }

            let cellSize = model.getCellSize()

            if model.isBackgroundCell {
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(origin: CGPoint(x: curOrigin.x, y: 0), size: cellSize)
                attributes.zIndex = -1

                layoutData.attributes.append(attributes)
                layoutData.contentBounds = layoutData.contentBounds.union(attributes.frame)

                return
            }

            curFrame.origin.y += curFrame.size.height + cellVerticalSpacing
            curFrame.size = cellSize

            let isNewLine = (curFrame.maxY > (cvSize.height - bottomMargin) && curFrame.minY != 0) || isNewContainerModel

            if isNewLine {
                assert(curFrame.height <= cvSize.height, "The item height exceeds the height of the `CollectionView`")

                let tmpTopMargin = (topMargin + curFrame.height) > cvSize.height ? 0 : topMargin
                let tmpLineSpacing = isNewContainerModel ? 0 : cellHorizontalSpacing

                curFrame.origin = CGPoint(x: curOrigin.x + tmpLineSpacing, y: tmpTopMargin)
            }

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = curFrame
            curOrigin.x = max(curOrigin.x, curFrame.maxX)

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
                        startOrigin: CGPoint(x: layoutData.contentBounds.maxX, y: curOrigin.y)) {
                layoutData.attributes.append(contentsOf: ld.attributes)
                layoutData.contentBounds = layoutData.contentBounds.union(ld.contentBounds)

                curOrigin.x = max(curOrigin.x, ld.contentBounds.maxX)
                isNewContainerModel = true
            }
        }

        layoutData.contentBounds.size.width += containerModel.getRightMargin() ?? 0
        containerModel.contentFrame = layoutData.contentBounds

        return layoutData
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
