//
//  DiffTableViewController.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/10.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import DCFrame

class DiffTableViewController: DCViewController {
    let oldPeople = [
        "1 Kevin",
        "2 Mike",
        "3 Ann",
        "4 Jane",
        "5 Philip",
        "6 Mona",
        "7 Tami",
        "8 Jesse",
        "9 Jaed"
    ]
    let newPeople = [
        "2 Mike",
        "10 Marne",
        "5 Philip",
        "1 Kevin",
        "3 Ryan",
        "8 Jesse",
        "7 Tami",
        "4 Jane",
        "9 Chen"
    ]
    
    lazy var people: [String] = {
        return self.oldPeople
    }()
    
    let listCM = DCContainerModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play,
                                                            target: self,
                                                            action: #selector(DiffTableViewController.onDiff))
        loadCM(listCM)
        loadPeople()
        dcTableView.needReloadData()
    }
    
    @objc func onDiff() {
        people = people == oldPeople ? newPeople : oldPeople
        loadPeople()
        dcTableView.needAnimateUpdate()
    }
    
    private func loadPeople() {
        listCM.removeAllSubmodels()
        for item in people {
            let model = DiffLabelCellModel()
            model.text = item
            listCM.addSubmodel(model)
        }
    }
}
