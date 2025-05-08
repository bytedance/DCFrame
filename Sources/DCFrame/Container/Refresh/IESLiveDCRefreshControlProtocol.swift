//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation

public enum DCEndLoadMoreState {
    case hasMoreData
    case noMoreData
    case error
}

public protocol DCRefreshControlProtocol: AnyObject {
    var isRefreshing: Bool { get }
    var isLoading: Bool { get }
    var hasMoreData: Bool { get }

    func setRefresh(_ isOpen: Bool)
    func setLoadMore(_ isOpen: Bool)

    func beginRefreshing()
    func endRefresh()
    func endLoadMore(_ state: DCEndLoadMoreState)
}
