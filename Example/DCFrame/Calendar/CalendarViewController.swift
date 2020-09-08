//
//  CalendarViewController.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/9.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import DCFrame

class CalendarViewController: DCViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCM(CalendarContainerModel())
    }
}
