//
//  PostListContainerModel.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/9.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import DCFrame

class PostListContainerModel: DCContainerModel {
    private let mockData = [
        PostData(username: "userA", comments: [
            "Luminous triangle",
            "Awesome",
            "Super clean",
            "Stunning shot",
        ]),
        PostData(username: "userB", comments: [
            "The simplicity here is superb",
            "thanks!",
            "That's always so kind of you!",
            "I think you might like this",
        ]),
        PostData(username: "userC", comments: [
            "So good",
        ]),
        PostData(username: "userD", comments: [
            "hope she might like it.",
            "I love it."
        ]),
    ]
    
    override func cmDidLoad() {
        super.cmDidLoad()
        
        for data in mockData {
            let infoCM = PostInfoContainerModel()
            infoCM.update(with: data)
            infoCM.bottomSeparator = DCSeparatorModel(color: .clear, height: 10)
            addSubmodel(infoCM)
        }
    }
}
