//
//  PostInfoContainerModel.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/9.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import DCFrame

class PostData {
    var username: String
    var comments: [String]
    
    init(username: String, comments: [String]) {
        self.username = username
        self.comments = comments
    }
}

class PostInfoContainerModel: DCContainerModel {
    override func cmDidLoad() {
        super.cmDidLoad()
        
        subscribeEvent(InteractiveCell.likeTouch) { [weak self] (text: String) in
            self?.shareData((text, UIColor.red), to: PhotoCellModel.data)
        }.and(InteractiveCell.commentTouch) { [weak self] (text: String) in
            self?.shareData((text, UIColor.yellow), to: PhotoCellModel.data)
        }.and(InteractiveCell.shareTouch) { [weak self] (text: String) in
            self?.shareData((text, UIColor.blue), to: PhotoCellModel.data)
        }
    }
    
    func update(with post: PostData) {
        removeAllSubmodels()
        
        let userModel = UserInfoCellModel(name: post.username)
        userModel.isHoverTop = true
        
        let photoModel = PhotoCellModel()
        let interactiveModel = InteractiveCellModel()
        
        let commentsCM = PostCommentsContainerModel()
        commentsCM.update(with: post.comments)
        
        addSubmodels([userModel, photoModel, interactiveModel, commentsCM])
    }
}
