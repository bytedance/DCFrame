//
//  ShareDataViewController.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/9.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import DCFrame

class ShareDataViewController: DCViewController {
    private let listCM = DCContainerModel()
    private var numValue = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAdd))
        
        for _ in 0..<100 {
            let model = SimpleLabelModel()
            model.text = "init value"
            model.cellClass = ShareDataLabelCell.self
            listCM.addSubmodel(model)
        }
        
        loadCM(listCM)
    }
    
    @objc func onAdd() {
        numValue += 1
        EDC.shareData("value: \(numValue)", to: ShareDataLabelCell.text)
    }
}
