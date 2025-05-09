//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation

open class DCRefreshContainerModel: DCContainerModel {
    public weak var refreshHandler: DCRefreshControlProtocol?

    override public func addSubModel(_ model: DCBaseModel) {
        if let containerModel = model as? DCRefreshContainerModel {
            containerModel.refreshHandler = self.refreshHandler
        }
        super.addSubModel(model)
    }

    public func refreshSubModelHandler() {
        for item in modelArray {
            if let containerModel = item as? DCRefreshContainerModel {
                containerModel.refreshHandler = self.refreshHandler
                containerModel.refreshSubModelHandler()
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
