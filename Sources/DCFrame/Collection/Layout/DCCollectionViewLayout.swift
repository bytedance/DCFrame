//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import UIKit

class DCCollectionViewLayout: UICollectionViewLayout {
    private var layoutData = DCContainerLayoutData()

    override func prepare() {
        super.prepare()

        guard let collectionView = collectionView as? DCCollectionView else {
            return
        }
        
        let containerModel = collectionView.layoutContainerModel
        let tmpLayoutData = DCContainerLayoutData()
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
        return !newBounds.size.equalTo(collectionView.bounds.size)
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutData.attributes[dc_safe: indexPath.item]
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView as? DCCollectionView,
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
        
        layoutData.backgroundCellIndexPaths.forEach { indexPath in
            if let matchAttributes = layoutData.attributes[dc_safe: indexPath.item], matchAttributes.frame.intersects(rect) {
                attributesArray.append(matchAttributes)
            }
        }

        return attributesArray
    }
    
    private func binSearch(_ rect: CGRect, _ collectionView: DCCollectionView, start: Int, end: Int, hoverStyle: Bool = false) -> Int? {
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
            let isAfter = collectionView.scrollDirection == .vertical ? (targetFrame.maxY < rect.minY) : (targetFrame.maxX < rect.minX)
            if isAfter {
                return binSearch(rect, collectionView, start: (mid + 1), end: end, hoverStyle: hoverStyle)
            } else {
                return binSearch(rect, collectionView, start: start, end: (mid - 1), hoverStyle: hoverStyle)
            }
        }
    }
}
