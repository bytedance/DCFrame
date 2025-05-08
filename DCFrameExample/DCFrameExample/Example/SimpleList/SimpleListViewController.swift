//
//  SimpleListViewController.swift
//  DCFrame_Example
//

import UIKit
import DCFrame

class SimpleListViewController: DemosViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let listContainerModel = DCContainerModel()

        for num in 0...100 {
            let model = SimpleLabelCellModel()
            model.text = "\(num)"
            if num == 100 {
                model.isShowBottomLine = false
            }
            listContainerModel.addSubModel(model)
        }
        
        loadContainerModel(listContainerModel)
    }
}
