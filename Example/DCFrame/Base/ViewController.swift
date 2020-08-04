//
//  ViewController.swift
//  DCFrame
//
//  Created by zhangzhengzhen on 02/22/2019.
//  Copyright (c) 2019 zhangzhengzhen. All rights reserved.
//

import UIKit
import DCFrame

class ViewController: DCViewController {
    
    private let button = UIButton()
    
    private let demosList: [(String, AnyClass)] = [
        ("Simple List", SimpleListViewController.self),
        ("Pull Down Refreshing & Pull Up Loading", RefreshViewController.self),
        ("Search Autocomplete", SearchAutoCompleteViewController.self),
        ("Mixed Data", MixedDataViewController.self),
        ("Empty View", EmptyViewController.self),
        ("Working Range", WorkingRangeViewController.self),
        ("Diff Algorithm", DiffTableViewController.self),
        ("Calendar", CalendarViewController.self),
        ("Share Data", ShareDataViewController.self),
        ("Post List", PostListViewController.self),
        ("Merge Other ContainerModels", MergeViewController.self)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Demos"

        EDC.subscribeEvent(LabelCell.touch, target: self) { [weak self] (title: String) in
            guard let `self` = self else {
                return
            }
            for item in self.demosList where item.0 == title {
                if let vcClass = item.1 as? UIViewController.Type {
                    let vc = vcClass.init()
                    vc.title = title
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                }
            }
        }
        
        let cm = DCContainerModel()
        for item in demosList {
            cm.addXibCell(LabelCell.self, data: item.0) { (model) in
                model.selectionStyle = .default
            }
        }
        loadCM(cm)
    }
}
