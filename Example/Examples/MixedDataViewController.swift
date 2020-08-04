//
//  MixedDataViewController.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/8.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import UIKit
import DCFrame

class MixedDataViewController: DCViewController {
    private let data: [Any] = [
        ExpandableLabelModel(text: "Maecenas faucibus mollis interdum. Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit."),
        GridItemsModel(color: UIColor(red: 237 / 255.0, green: 73 / 255.0, blue: 86 / 255.0, alpha: 1), itemCount: 6),
        UserModel(name: "Ryan Olson", handle: "ryanolsonk"),
        ExpandableLabelModel(text: "Praesent commodo cursus magna, vel scelerisque nisl consectetur et."),
        UserModel(name: "Oliver Rickard", handle: "ocrickard"),
        GridItemsModel(color: UIColor(red: 56 / 255.0, green: 151 / 255.0, blue: 240 / 255.0, alpha: 1), itemCount: 5),
        ExpandableLabelModel(text: "Nullam quis risus eget urna mollis ornare vel eu leo. Praesent commodo cursus magna, vel scelerisque nisl consectetur et."),
        UserModel(name: "Jesse Squires", handle: "jesse_squires"),
        GridItemsModel(color: UIColor(red: 112 / 255.0, green: 192 / 255.0, blue: 80 / 255.0, alpha: 1), itemCount: 3),
        ExpandableLabelModel(text: "Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus."),
        GridItemsModel(color: UIColor(red: 163 / 255.0, green: 42 / 255.0, blue: 186 / 255.0, alpha: 1), itemCount: 7),
        UserModel(name: "Ryan Nystrom", handle: "_ryannystrom")
        ]

    private let segments: [(String, Any.Type?)] = [
        ("All", nil),
        ("Colors", GridItemsModel.self),
        ("Text", ExpandableLabelModel.self),
        ("Users", UserModel.self)
    ]
    
    private let mixedDataCM = DCContainerModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        let control = UISegmentedControl(items: segments.map { return $0.0 })
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(MixedDataViewController.onControl(_:)), for: .valueChanged)
        navigationItem.titleView = control

        mixedDataCM.addSubmodels(data)
        loadCM(mixedDataCM)
    }
    
    @objc func onControl(_ control: UISegmentedControl) {
        let selectedClass = segments[control.selectedSegmentIndex].1
        
        mixedDataCM.removeAllSubmodels()
        
        if selectedClass == nil {
            mixedDataCM.addSubmodels(data)
        } else {
            mixedDataCM.addSubmodels(data.filter { type(of: $0) == selectedClass })
        }
        
        dcTableView.needAnimateUpdate()
    }
}
