//
//  CalendarView.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/9.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import DCFrame

class CalendarViewModel: DCCellModel {
    let name: String
    let days: Int
    
    lazy var today: Int = {
        let date = Date()
        let today = Calendar.current.component(.day, from: date)
        return today
    }()

    // day int mapped to an array of appointment names
    let appointments: [Int: [String]]
    
    let itemWidth = UIScreen.main.bounds.width / 7
    
    var selectedDay: Int = -1

    init(name: String, days: Int, appointments: [Int: [String]]) {
        self.name = name
        self.days = days
        self.appointments = appointments
        super.init()
        
        selectedDay = today
        cellHeight = itemWidth * 5
        cellClass = CalendarView.self
    }
    
    func selectedDayInfo() -> [String]? {
        return appointments[selectedDay]
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}

class CalendarView: DCCell<CalendarViewModel> {
    static let didSelected = DCEventID()
    
    private let cellIdentifier = "CalendarDayCell"
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.backgroundColor = .white
        
        contentView.addSubview(collectionView)
        
        return collectionView
    }()

    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()
        collectionView.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = contentView.bounds
    }
}

extension CalendarView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellModel.days
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? CalendarDayCell else {
            fatalError()
        }
        let day = indexPath.row + 1
        let dayData = DayData(
            day: day,
            today: day == cellModel.today,
            selected: day == cellModel.selectedDay,
            appointments: cellModel.appointments[day]?.count ?? 0
        )
        cell.update(dayData)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellModel.itemWidth, height: cellModel.itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let day = indexPath.row + 1
        cellModel.selectedDay = day
        collectionView.reloadData()
        sendEvent(Self.didSelected, data: cellModel.selectedDayInfo())
    }
}

final class DayData {
    let day: Int
    let today: Bool
    let selected: Bool
    let appointments: Int

    init(day: Int, today: Bool, selected: Bool, appointments: Int) {
        self.day = day
        self.today = today
        self.selected = selected
        self.appointments = appointments
    }
}

final class CalendarDayCell: UICollectionViewCell {

    lazy fileprivate var label: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .center
        view.textColor = .black
        view.font = .boldSystemFont(ofSize: 16)
        view.layer.borderWidth = 2
        view.clipsToBounds = true
        self.contentView.addSubview(view)
        return view
    }()

    lazy fileprivate var dotsLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .center
        view.textColor = .red
        view.font = .boldSystemFont(ofSize: 30)
        self.contentView.addSubview(view)
        return view
    }()

    var text: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }

    var dots: String? {
        get {
            return dotsLabel.text
        }
        set {
            dotsLabel.text = newValue
        }
    }
    
    func update(_ data: DayData) {
        label.text = data.day.description
        label.layer.borderColor = data.today ? UIColor.red.cgColor : UIColor.clear.cgColor
        label.backgroundColor = data.selected ? UIColor.red.withAlphaComponent(0.3) : UIColor.clear

        var dots = ""
        for _ in 0..<data.appointments {
            dots += "."
        }
        dotsLabel.text = dots
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        let half = bounds.height / 2
        label.frame = bounds
        label.layer.cornerRadius = half
        dotsLabel.frame = CGRect(x: 0, y: half - 10, width: bounds.width, height: half)
    }
}
