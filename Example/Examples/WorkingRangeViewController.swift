//
//  WorkingRangeViewController.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/10.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import DCFrame

class WorkingRangeViewController: DCViewController {
    private let heights: [Int] = {
        var set = Set<Int>() // only use unique values
        while set.count < 20 {
            set.insert( Int(arc4random_uniform(200)) + 200 )
        }
        return Array(set)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let listCM = DCContainerModel()
        
        for height in heights {
            let urlString = mockUrlString(height)
            listCM.addXibCell(LabelCell.self, data: urlString)
            
            let model = ImageCellModel()
            model.cellHeight = CGFloat(height)
            model.urlString = urlString
            listCM.addSubmodel(model)
        }
        
        loadCM(listCM)
    }
    
    private func mockUrlString(_ height: Int) -> String {
        let width = Int(UIScreen.main.bounds.width)
        return "https://unsplash.it/" + width.description + "/" + height.description
    }
}
