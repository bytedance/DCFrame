//
//  RefreshViewController.swift
//  DCFrame_Example
//

import UIKit
import DCFrame

class RefreshViewController: DemosRefreshViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        loadContainerModel(RefreshContainerModel())
    }
}
