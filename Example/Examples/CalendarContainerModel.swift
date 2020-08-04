//
//  CalendarContainerModel.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/9.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import DCFrame

class CalendarContainerModel: DCContainerModel {
    
    private let listCM = DCContainerModel()
    
    override func cmDidLoad() {
        super.cmDidLoad()
        
        let date = Date()
        let currentMonth = Calendar.current.component(.month, from: date)
        let name = DateFormatter().monthSymbols[currentMonth - 1]
        let calendarVM = CalendarViewModel(
            name: name,
            days: 30,
            appointments: [
                2: ["Hair"],
                4: ["Nails"],
                7: ["Doctor appt", "Pick up groceries"],
                12: ["Call back the cable company", "Find a babysitter"],
                13: ["Dinner at The Smith"],
                17: ["Buy running shoes", "Buy a fitbit", "Start running"],
                20: ["Call mom"],
                21: ["Contribute to IGListKit"],
                25: ["Interview"],
                26: ["Quit running", "Buy ice cream"]
            ]
        )
        addSubCell(MonthTitleCell.self, data: name) { (model) in
            model.cellHeight = 30
        }
        addSubmodels([calendarVM, listCM])
        
        updateListCM(with: calendarVM.selectedDay)
        
        handleEvents()
    }
    
    private func handleEvents() {
        subscribeEvent(CalendarView.didSelected) { [weak self] (data) in
            self?.updateListCM(with: data)
            self?.needAnimateUpdate(with: .fade)
        }
    }
    
    private func updateListCM(with data: Any?) {
        listCM.removeAllSubmodels()
        if let items = data as? [String] {
            for item in items {
                listCM.addXibCell(LabelCell.self, data: item)
            }
        }
    }
}
