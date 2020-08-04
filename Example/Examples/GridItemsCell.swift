//
//  GridItemsCell.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/8.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import DCFrame

class GridItemsModel: DCCellModel {
    var color: UIColor
    var itemCount: Int
    
    let itemWidth = UIScreen.main.bounds.width / 4

    init(color: UIColor, itemCount: Int) {
        self.color = color
        self.itemCount = itemCount
        super.init()
        
        self.cellClass = GridItemsCell.self
        self.cellHeight = CGFloat(((itemCount + 3) / 4)) * itemWidth
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}

class GridItemsCell: DCCell<GridItemsModel> {
    private let cellIdentifier = "CenterLabelCell"
    
    private lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CenterLabelCell.self, forCellWithReuseIdentifier: cellIdentifier)
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

extension GridItemsCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellModel.itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? CenterLabelCell else {
            fatalError()
        }
        cell.text = "\(indexPath.row + 1)"
        cell.backgroundColor = cellModel.color
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellModel.itemWidth - 1, height: cellModel.itemWidth - 1)
    }
}

final class CenterLabelCell: UICollectionViewCell {
    lazy private var label: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .center
        view.textColor = .white
        view.font = .boldSystemFont(ofSize: 18)
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

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds
    }
}
