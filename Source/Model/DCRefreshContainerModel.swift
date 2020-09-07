//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import UIKit

public protocol DCRefreshExecuteProtocol: NSObjectProtocol {
    func refresh()
    func loadMore()
}

public protocol DCRefreshControlProtocol: NSObjectProtocol {
    var isRefreshing: Bool { get }
    var isLoading: Bool { get }
    var hasMoreData: Bool { get }
    
    func setRefresh(_ isOpen: Bool)
    func setLoadMore(_ isOpen: Bool)
    
    func beginRefreshing()
    func endReresh()
    func endLoadMore()
    func endWithNoMoreData()
}

open class DCRefreshContainerModel: DCContainerModel, DCRefreshExecuteProtocol {
    public weak var refreshHandler: DCRefreshControlProtocol?
    
    override public func addSubmodel(_ model: Any) {
        if let containerModel = model as? DCRefreshContainerModel {
            containerModel.refreshHandler = self.refreshHandler
        }
        super.addSubmodel(model)
    }
    
    public func refreshSubmodelHandler() {
        for item in modelArray {
            if let containerModel = item as? DCRefreshContainerModel {
                containerModel.refreshHandler = self.refreshHandler
                containerModel.refreshSubmodelHandler()
            }
        }
    }
    
    open func refresh() {
        for item in modelArray {
            guard let containerModel = item as? DCRefreshContainerModel else {
                continue
            }
            containerModel.refreshHandler = self.refreshHandler
            containerModel.refresh()
        }
        // override
    }
    
    open func loadMore() {
        for item in modelArray {
            guard let containerModel = item as? DCRefreshContainerModel else {
                continue
            }
            containerModel.loadMore()
        }
        // override
    }
}
