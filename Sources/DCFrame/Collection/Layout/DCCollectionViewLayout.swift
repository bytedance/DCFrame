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

        let containerModel = collectionView.containerModel

        if let layoutData = containerModel
            .getCustomLayout()
            .layoutAttributes(collectionView, containerModel: containerModel, startOrigin: .zero) {
            self.layoutData = layoutData
        }

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
              let lastIndex = layoutData.attributes.indices.last,
              let firstMatchIndex = binSearch(rect, start: 0, end: lastIndex) else {
                  return nil
              }

        var attributesArray = [UICollectionViewLayoutAttributes]()

        for attributes in layoutData.attributes[..<firstMatchIndex].reversed() {
            guard (collectionView.scrollDirection == .vertical && attributes.frame.maxY >= rect.minY)
                    || (collectionView.scrollDirection == .horizontal && attributes.frame.maxX >= rect.minX) else {
                        break
                    }
            attributesArray.append(attributes)
        }

        for attributes in layoutData.attributes[firstMatchIndex...] {
            guard (collectionView.scrollDirection == .vertical && attributes.frame.minY <= rect.maxY)
                    || (collectionView.scrollDirection == .horizontal && attributes.frame.minX <= rect.maxX) else {
                        break
                    }
            attributesArray.append(attributes)
        }

        return attributesArray
    }

    private func binSearch(_ rect: CGRect, start: Int, end: Int) -> Int? {
        guard let collectionView = collectionView as? DCCollectionView, end >= start else {
            return nil
        }

        let mid = (start + end) / 2
        guard let attr = layoutData.attributes[dc_safe: mid] else {
            return nil
        }

        if attr.frame.intersects(rect) {
            return mid
        } else {
            let isRight = collectionView.scrollDirection == .vertical ? (attr.frame.maxY < rect.minY) : (attr.frame.maxX < rect.minX)
            if isRight {
                return binSearch(rect, start: (mid + 1), end: end)
            } else {
                return binSearch(rect, start: start, end: (mid - 1))
            }
        }
    }
}
