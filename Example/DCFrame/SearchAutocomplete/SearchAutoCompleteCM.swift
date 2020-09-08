//
//  SearchAutoCompleteCM.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/8.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import Foundation
import DCFrame

class SearchAutoCompleteCM: DCContainerModel {
    private let listCM = DCContainerModel()
    
    private lazy var words: [String] = {
        // swiftlint:disable:next
        let str = "Humblebrag skateboard tacos viral small batch blue bottle, schlitz fingerstache etsy squid. Listicle tote bag helvetica XOXO literally, meggings cardigan kickstarter roof party deep v selvage scenester venmo truffaut. You probably haven't heard of them fanny pack austin next level 3 wolf moon. Everyday carry offal brunch 8-bit, keytar banjo pinterest leggings hashtag wolf raw denim butcher. Single-origin coffee try-hard echo park neutra, cornhole banh mi meh austin readymade tacos taxidermy pug tattooed. Cold-pressed +1 ethical, four loko cardigan meh forage YOLO health goth sriracha kale chips. Mumblecore cardigan humblebrag, lo-fi typewriter truffaut leggings health goth."
        var unique = Set<String>()
        var words = [String]()
        let range = str.startIndex ..< str.endIndex
        str.enumerateSubstrings(in: range, options: .byWords) { (substring, _, _, _) in
            guard let substring = substring else { return }
            if !unique.contains(substring) {
                unique.insert(substring)
                words.append(substring)
            }
        }
        return words
    }()
    
    override func cmDidLoad() {
        super.cmDidLoad()
        addSubCell(SearchCell.self) { (model) in
            model.cellHeight = 44
        }
        addSubmodel(listCM)
        
        handleEvents()
        
        loadWords(words)
    }
    
    private func handleEvents() {
        subscribeEvent(SearchCell.textChanged) { [weak self] (text: String) in
            guard let `self` = self else {
                return
            }
            if text.isEmpty {
                self.loadWords(self.words)
            } else {
                let words = self.words.filter { $0.lowercased().contains(text.lowercased()) }
                self.loadWords(words)
            }
        }
    }
    
    private func loadWords(_ words: [String]) {
        listCM.removeAllSubmodels()
        for word in words {
            let model = DiffLabelCellModel()
            model.text = word
            listCM.addSubmodel(model)
        }
        needAnimateUpdate()
    }
}
