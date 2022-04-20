//
//  RefreshContainerModel.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/28.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import DCFrame

class RefreshContainerModel: DCRefreshContainerModel {
    private var currentOffset = 0

    override func containerModelDidLoad() {
        super.containerModelDidLoad()

        fetchData()
    }

    override func loadMore() {
        super.loadMore()

        fetchData()
    }

    override func refresh() {
        super.refresh()

        RefreshMockDataAPI.refreshData { data in
            self.currentOffset = data.count
            self.removeAllSubmodels()

            self.handleData(data)

            self.refreshHandler?.endRefresh()
        }
    }

    private func fetchData() {
        RefreshMockDataAPI.fetchData(offset: currentOffset) { data in
            self.currentOffset += data.count

            self.handleData(data)

            self.refreshHandler?.endLoadMore(.hasMoreData)
        }
    }

    private func handleData(_ data: [String]) {
        for text in data {
            let model = SimpleLabelCellModel()
            model.text = text
            addSubmodel(model)
        }

        dcHandler?.needUpdateLayoutAnimated()
    }
}
