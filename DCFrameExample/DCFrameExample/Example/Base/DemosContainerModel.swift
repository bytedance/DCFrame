//
//  DemosContainerModel.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2021/12/30.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import DCFrame

class DemosContainerModel: DCContainerModel {
    override func containerModelDidLoad() {
        super.containerModelDidLoad()

        loadData()

        subscribeEvent(DemosLabelCell.touch) {  [weak self] (cellModel: DemosLabelCellModel) in
            guard let vcClass = cellModel.vcClass else {
                return
            }
            let vc = vcClass.init()
            vc.title = cellModel.text
            self?.dcViewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }

    private func loadData() {
        for item in DemosData.items {
            let model = DemosLabelCellModel()
            model.isSelectionStyle = true
            model.text = item.0
            model.vcClass = item.1

            addSubmodel(model)
        }
    }
}
