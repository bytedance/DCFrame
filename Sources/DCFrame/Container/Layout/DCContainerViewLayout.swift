//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import UIKit

class DCContainerViewLayout: UICollectionViewLayout {
    private var layoutData = DCContainerViewLayoutData()

    override func prepare() {
        super.prepare()

        guard let collectionView = collectionView as? DCContainerView else {
            return
        }
        
        let containerModel = collectionView.layoutContainerModel
        let tmpLayoutData = DCContainerViewLayoutData()
        containerModel.getCustomLayout().layoutAttributes(tmpLayoutData, collectionView, containerModel: containerModel, startOrigin: .zero)
        self.layoutData = tmpLayoutData

        if collectionView.scrollDirection == .vertical {
            layoutData.contentBounds.size.width = min(layoutData.contentBounds.size.width, collectionView.bounds.size.width)
        } else {
            layoutData.contentBounds.size.height = min(layoutData.contentBounds.size.height, collectionView.bounds.size.height)
        }
    }

    override var collectionViewContentSize: CGSize {
        return layoutData.contentBounds.size
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else {
            return false
        }
        
        if layoutData.hoverAttributes.isEmpty {
            return !newBounds.size.equalTo(collectionView.bounds.size)
        } else {
            return true
        }
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds)
        
        if let visibleHoverIndexPaths = (collectionView as? DCContainerView)?.indexPathsForVisibleSupplementaryElements(ofKind: DCContainerView.elementKindHoverTop), !visibleHoverIndexPaths.isEmpty {
            context.invalidateSupplementaryElements(ofKind: DCContainerView.elementKindHoverTop, at: visibleHoverIndexPaths)
        }
        return context
    }

    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)

        guard let indexPaths = context.invalidatedSupplementaryIndexPaths?[DCContainerView.elementKindHoverTop], !indexPaths.isEmpty else { return }
        
        handleHoverIndexPaths(indexPaths)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutData.attributes[dc_safe: indexPath.item]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard elementKind == DCContainerView.elementKindHoverTop else { return nil }
        
        return layoutData.hoverAttributes[dc_safe: indexPath.item]
    }
    
    override func indexPathsToInsertForSupplementaryView(ofKind elementKind: String) -> [IndexPath] {
        guard let collectionView = collectionView as? DCContainerView, elementKind == DCContainerView.elementKindHoverTop else { return [IndexPath]() }
                
        return collectionView.indexPathsToInsertForSupplementaryView
    }
    
    override func indexPathsToDeleteForSupplementaryView(ofKind elementKind: String) -> [IndexPath] {
        guard let collectionView = collectionView as? DCContainerView, elementKind == DCContainerView.elementKindHoverTop else { return [IndexPath]() }
                
        return collectionView.indexPathsToDeleteForSupplementaryView
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView as? DCContainerView,
              let lastIndex = layoutData.lineAttributesArray.indices.last,
              let firstMatchLineIndex = binSearch(rect, collectionView, start: 0, end: lastIndex) else {
                  return nil
              }

        var attributesArray = [UICollectionViewLayoutAttributes]()
        
        func handleLineAttributes(lineIndexPaths: [IndexPath]) {
            lineIndexPaths.forEach { indexPath in
                if let attributes = layoutData.attributes[dc_safe: indexPath.item], attributes.frame.intersects(rect) {
                    attributesArray.append(attributes)
                }
            }
        }
        
        for lineAttributes in layoutData.lineAttributesArray[..<firstMatchLineIndex].reversed() {
            guard lineAttributes.lineFrame.intersects(rect) else { break }
            
            handleLineAttributes(lineIndexPaths: lineAttributes.itemIndexPaths)
        }
        
        for lineAttributes in layoutData.lineAttributesArray[firstMatchLineIndex...] {
            guard lineAttributes.lineFrame.intersects(rect) else { break }
            
            handleLineAttributes(lineIndexPaths: lineAttributes.itemIndexPaths)
        }
        
        if let lastHoverIndex = layoutData.hoverAttributes.indices.last, let firstMatchHoverIndex = binSearch(rect, collectionView, start: 0, end: lastHoverIndex, hoverStyle: true) {
            for hoverAttributes in layoutData.hoverAttributes[..<firstMatchHoverIndex].reversed() {
                guard hoverAttributes.frame.intersects(rect) else { break }
                
                attributesArray.append(hoverAttributes)
            }
            
            for hoverAttributes in layoutData.hoverAttributes[firstMatchHoverIndex...] {
                guard hoverAttributes.frame.intersects(rect) else { break }
                
                attributesArray.append(hoverAttributes)
            }
        }
        
        layoutData.backgroundCellIndexPaths.forEach { indexPath in
            if let matchAttributes = layoutData.attributes[dc_safe: indexPath.item], matchAttributes.frame.intersects(rect) {
                attributesArray.append(matchAttributes)
            }
        }

        return attributesArray
    }
    
    private func handleHoverIndexPaths(_ indexPaths: [IndexPath]) {
        guard let collectionView = collectionView as? DCContainerView else { return }
        
        if collectionView.scrollDirection == .vertical {
            handleVerticalHover(collectionView, indexPaths)
        } else if collectionView.scrollDirection == .horizontal {
            handleHorizontalHover(collectionView, indexPaths)
        }
    }
    
    private func handleVerticalHover(_ collectionView: DCContainerView, _ indexPaths: [IndexPath]) {
        let offsetY = collectionView.contentOffset.y + (collectionView.hoverViewOffset ?? collectionView.contentInset.top)
        
        var tmpCur: IndexPath?
        var tmpNext: IndexPath?
        for indexPath in indexPaths {
            guard let attributes = layoutData.originHoverAttributes[dc_safe: indexPath.item] else { continue }
            
            if attributes.frame.origin.y >= offsetY { // search next
                if let _tmpNext = tmpNext, _tmpNext.item <= indexPath.item {
                    continue
                }
                tmpNext = indexPath
            } else { // search cur
                if let _tmpCur = tmpCur, _tmpCur.item >= indexPath.item {
                    continue
                }
                tmpCur = indexPath
            }
        }
        
        if let oldCurHoverAttributes = layoutData.currentHoverAttributes, let originAttributes = layoutData.originHoverAttributes[dc_safe: oldCurHoverAttributes.indexPath.item] {
            if let nextHoverIndexPath = tmpNext, oldCurHoverAttributes.indexPath == nextHoverIndexPath {
                oldCurHoverAttributes.frame.origin.y = originAttributes.frame.origin.y
            }
            if tmpCur == nil {
                layoutData.currentHoverAttributes = nil
            }
        }
        
        if let curHoverIndexPath = tmpCur, let curHoverAttributes = layoutData.hoverAttributes[dc_safe: curHoverIndexPath.item] {
            layoutData.currentHoverAttributes = curHoverAttributes
            if let nextIndexPath = tmpNext, let nextTopY = layoutData.originHoverAttributes[dc_safe: nextIndexPath.item]?.frame.origin.y, let hoverViewHeight = layoutData.originHoverAttributes[dc_safe: curHoverIndexPath.item]?.frame.height, nextTopY < hoverViewHeight + offsetY {
                curHoverAttributes.frame.origin.y = nextTopY - hoverViewHeight
            } else {
                curHoverAttributes.frame.origin.y = offsetY
            }
        }
    }
    
    private func handleHorizontalHover(_ collectionView: DCContainerView, _ indexPaths: [IndexPath]) {
        let offsetX = collectionView.contentOffset.x + (collectionView.hoverViewOffset ?? collectionView.contentInset.left)
        
        var tmpCur: IndexPath?
        var tmpNext: IndexPath?
        for indexPath in indexPaths {
            guard let attributes = layoutData.originHoverAttributes[dc_safe: indexPath.item] else { continue }
            if attributes.frame.origin.x >= offsetX { // search next
                if let _tmpNext = tmpNext, _tmpNext.item <= indexPath.item {
                    continue
                }
                tmpNext = indexPath
            } else { // search cur
                if let _tmpCur = tmpCur, _tmpCur.item >= indexPath.item {
                    continue
                }
                tmpCur = indexPath
            }
        }
        
        if let oldCurHoverAttributes = layoutData.currentHoverAttributes, let originAttributes = layoutData.originHoverAttributes[dc_safe: oldCurHoverAttributes.indexPath.item] {
            if let nextHoverIndexPath = tmpNext, oldCurHoverAttributes.indexPath == nextHoverIndexPath {
                oldCurHoverAttributes.frame.origin.x = originAttributes.frame.origin.x
            }
            if tmpCur == nil {
                layoutData.currentHoverAttributes = nil
            }
        }
        
        if let curHoverIndexPath = tmpCur, let curHoverAttributes = layoutData.hoverAttributes[dc_safe: curHoverIndexPath.item] {
            layoutData.currentHoverAttributes = curHoverAttributes
            if let nextIndexPath = tmpNext, let nextTopX = layoutData.originHoverAttributes[dc_safe: nextIndexPath.item]?.frame.origin.x, let hoverViewWidth = layoutData.originHoverAttributes[dc_safe: curHoverIndexPath.item]?.frame.width, nextTopX < hoverViewWidth + offsetX {
                curHoverAttributes.frame.origin.y = nextTopX - hoverViewWidth
            } else {
                curHoverAttributes.frame.origin.x = offsetX
            }
        }
    }
    
    private func binSearch(_ rect: CGRect, _ collectionView: DCContainerView, start: Int, end: Int, hoverStyle: Bool = false) -> Int? {
        guard end >= start else {
            return nil
        }
        
        let mid = (start + end) / 2
        let targetFrame: CGRect?
        if hoverStyle {
            targetFrame = layoutData.hoverAttributes[dc_safe: mid]?.frame
        } else {
            targetFrame = layoutData.lineAttributesArray[dc_safe: mid]?.lineFrame
        }
        
        guard let targetFrame = targetFrame else {
            return nil
        }
        
        if targetFrame.intersects(rect) {
            return mid
        } else {
            let isAfter = collectionView.scrollDirection == .vertical ? (targetFrame.maxY <= rect.minY) : (targetFrame.maxX <= rect.minX)
            if isAfter {
                return binSearch(rect, collectionView, start: (mid + 1), end: end, hoverStyle: hoverStyle)
            } else {
                return binSearch(rect, collectionView, start: start, end: (mid - 1), hoverStyle: hoverStyle)
            }
        }
    }
}
