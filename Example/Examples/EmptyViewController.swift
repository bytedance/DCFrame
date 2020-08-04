//
//  EmptyViewController.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/9.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import UIKit
import DCFrame

class EmptyViewController: DCViewController {
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "No more data!"
        label.backgroundColor = .clear
        label.isHidden = true
        label.sizeToFit()
        return label
    }()
    
    private let emtyViewCM = EmptyViewContainerModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(EmptyViewController.onAdd))
        dcTableView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        dcTableView.dc_delegate = self
        view.addSubview(emptyLabel)
        
        loadCM(emtyViewCM)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        emptyLabel.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
    }
    
    @objc func onAdd() {
        emtyViewCM.addModel()
    }
}

extension EmptyViewController: DCTableViewDelegate {
    func dc_tableViewDataWillReload(_ tableView: UITableView) {
        self.emptyLabel.isHidden = self.emtyViewCM.modelArray.count != 0
    }
}
