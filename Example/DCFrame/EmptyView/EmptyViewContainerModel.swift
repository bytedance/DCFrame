//
//  EmptyViewContainerModel.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/9.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import DCFrame

class EmptyViewContainerModel: DCContainerModel {
    private var tally = 4
    private var data = [1, 2, 3, 4]
    
    override func cmDidLoad() {
        super.cmDidLoad()
        
        for number in data {
            addSubCell(RemoveCell.self, data: number) { (model) in
                model.cellHeight = 40
                model.bottomSeparator = DCSeparatorModel(color: .clear, height: 10)
            }
        }
        
        subscribeEvent(RemoveCell.click) { [weak self] (model: DCBaseCellModel) in
            self?.removeSubmodel(model)
            self?.needAnimateUpdate(with: .right)
        }
    }
    
    public func addModel() {
        tally += 1
        addSubCell(RemoveCell.self, data: tally) { (model) in
            model.cellHeight = 40
            model.bottomSeparator = DCSeparatorModel(color: .clear, height: 10)
        }
        needAnimateUpdate(with: .left)
    }
}
