//
//  SearchCell.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/8.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import UIKit
import DCFrame

class SearchCell: DCBaseCell {
    static let textChanged = DCEventID()
    
    private lazy var searchBar: UISearchBar = {
        let view = UISearchBar()
        self.contentView.addSubview(view)
        view.delegate = self
        return view
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        searchBar.frame = contentView.bounds
    }
    
    private func textChanged(_ text: String) {
        setCellData(text)
        sendEvent(Self.textChanged, data: text)
    }
    
    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()
        searchBar.text = getCellData(default: "")
    }
}

extension SearchCell: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        textChanged(searchText)
    }
}
