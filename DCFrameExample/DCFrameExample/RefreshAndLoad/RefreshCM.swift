//
//  RefreshCM.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/28.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import DCFrame

class RefreshCM: DCRefreshContainerModel {
    private var currentNumber = 0
    
    override func cmDidLoad() {
        super.cmDidLoad()
        loadData()
    }
    
    override func loadMore() {
        super.loadMore()
        mockLoad()
    }
    
    override func refresh() {
        super.refresh()
        removeAllSubmodels()
        currentNumber = 0
        mockLoad()
    }
    
    private func loadData() {
        for _ in 0...20 {
            currentNumber += 1
            let model = SimpleLabelModel()
            model.text = "\(currentNumber)"
            addSubmodel(model)
        }
        needReloadData()
    }
    
    private func mockLoad() {
        DispatchQueue.global(qos: .default).async {
            // fake background loading task
            sleep(1)
            DispatchQueue.main.async {
                self.loadData()
                self.refreshHandler?.endLoadMore()
                self.refreshHandler?.endRefresh()
            }
        }
    }
}
