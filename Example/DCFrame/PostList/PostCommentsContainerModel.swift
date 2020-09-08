//
//  PostCommentsContainerModel.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/9.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import DCFrame

class PostCommentsContainerModel: DCContainerModel {
    func update(with comments: [String]) {
        removeAllSubmodels()
        for comment in comments {
            let model = CommentCellModel(comment: comment)
            addSubmodel(model)
        }
    }
}
