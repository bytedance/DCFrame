//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import UIKit

@objc public protocol DCContainerViewDelegate: AnyObject {
    /// collectionView related protocol inheritance
    @objc optional func dcContainerView(_ collectionView: UICollectionView, cellForRowAt indexPath: IndexPath) -> UICollectionViewCell?
    @objc optional func dcContainerView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forRowAt indexPath: IndexPath)
    @objc optional func dcContainerView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forRowAt indexPath: IndexPath)
    @objc optional func dcContainerView(_ collectionView: UICollectionView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    @objc optional func dcContainerView(_ collectionView: UICollectionView, didHighlightRowAt indexPath: IndexPath)
    @objc optional func dcContainerView(_ collectionView: UICollectionView, didUnhighlightRowAt indexPath: IndexPath)
    @objc optional func dcContainerView(_ collectionView: UICollectionView, didSelectRowAt indexPath: IndexPath)
    @objc optional func dcContainerView(_ collectionView: UICollectionView, didDeselectRowAt indexPath: IndexPath)

    @objc optional func dcContainerView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool
    @objc optional func dcContainerView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)

    @objc optional func dcScrollViewDidScroll(_ scrollView: UIScrollView)
    @objc optional func dcScrollViewWillBeginDragging(_ scrollView: UIScrollView)
    @objc optional func dcScrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    @objc optional func dcScrollViewWillBeginDecelerating(_ scrollView: UIScrollView)
    @objc optional func dcScrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    @objc optional func dcScrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
    @objc optional func dcScrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool
    @objc optional func dcScrollViewDidScrollToTop(_ scrollView: UIScrollView)

    /// Custom protocols
    @objc optional func dcScrollViewDidEndScroll()
    @objc optional func dcDidSelectedCellModel(_ cellModel: DCCellModel)
    @objc optional func dcGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    @objc optional func dcContainerViewWillUpdate(_ collectionView: UICollectionView)
    @objc optional func dcContainerViewDidUpdate(_ collectionView: UICollectionView)
    @objc optional func dcBeginAnimateUpdate(_ collectionView: UICollectionView)
    @objc optional func dcEndAnimateUpdate(_ collectionView: UICollectionView)
}
