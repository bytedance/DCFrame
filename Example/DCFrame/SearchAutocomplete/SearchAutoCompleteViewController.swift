//
//  SearchAutoCompleteViewController.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/8.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import Foundation

class SearchAutoCompleteViewController: DCViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchCM = SearchAutoCompleteCM()
        loadCM(searchCM)
    }
}
