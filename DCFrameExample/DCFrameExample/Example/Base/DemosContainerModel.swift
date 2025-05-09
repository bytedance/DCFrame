//
//  DemosContainerModel.swift
//  DCFrame_Example
//

import UIKit
import DCFrame

class DemosContainerModel: DCContainerModel {
    override func containerModelDidLoad() {
        super.containerModelDidLoad()

        loadData()

        subscribeEvent(DemosLabelCell.touch) {  [weak self] (cellModel: DemosLabelCellModel) in
            if let vc = cellModel.classInstance as? UIViewController {
                vc.title = cellModel.text
                self?.dcViewController?.navigationController?.pushViewController(vc, animated: true)
            } else if let instance = cellModel.classInstance as? DemosHandleProtocol {
                instance.cellClicked(self?.dcViewController)
            }
        }
    }

    private func loadData() {
        for item in DemosData.items {
            let model = DemosLabelCellModel()
            model.isSelectionStyle = true
            model.text = item.0
            model.classInstance = item.1

            addSubModel(model)
        }
    }
}
