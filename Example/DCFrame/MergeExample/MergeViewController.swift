//
//  MergeViewController.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/9.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import DCFrame

class MergeViewController: DCViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mergeCM = DCContainerModel()
        mergeCM.addSubmodels([
            SearchAutoCompleteCM(),
            EmptyViewContainerModel(),
            CalendarContainerModel(),
            PostListContainerModel()
        ])
        
        loadCM(mergeCM)
    }
}
