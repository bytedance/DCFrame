//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

@objc public protocol DCTableViewDelegate: NSObjectProtocol {
    /// tableView related protocol inheritance
    @objc optional func dc_tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell?
    @objc optional func dc_tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    @objc optional func dc_tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
    @objc optional func dc_tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    @objc optional func dc_tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath)
    @objc optional func dc_tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath)
    @objc optional func dc_tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    @objc optional func dc_tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    
    @objc optional func dc_scrollViewDidScroll(_ scrollView: UIScrollView)
    @objc optional func dc_scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    @objc optional func dc_scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    @objc optional func dc_scrollViewWillBeginDecelerating(_ scrollView: UIScrollView)
    @objc optional func dc_scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    @objc optional func dc_scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
    @objc optional func dc_scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool
    @objc optional func dc_scrollViewDidScrollToTop(_ scrollView: UIScrollView)
    
    /// Custom protocols
    @objc optional func dc_scrollViewDidEndScroll()
    @objc optional func dc_didSelectedCellModel(_ cellModel: DCBaseCellModel)
    @objc optional func dc_gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    @objc optional func dc_tableViewDataWillReload(_ tableView: UITableView)
    @objc optional func dc_beginAnimateUpdate(_ tableView: UITableView)
    @objc optional func dc_endAnimateUpdate(_ tableView: UITableView)
}
