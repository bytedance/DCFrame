//
//  PostListViewController.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/9.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import DCFrame

class PostListViewController: DCViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dcTableView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        loadCM(PostListContainerModel())
    }
}
