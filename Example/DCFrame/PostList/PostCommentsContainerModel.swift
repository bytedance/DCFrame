//
//  PostCommentsContainerModel.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/9.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import DCFrame

class PostCommentsContainerModel: DCContainerModel {
    init(with comments: [String]) {
        super.init()
        for comment in comments {
            let model = CommentCellModel()
            model.comment = comment
            addSubmodel(model)
        }
    }
}
