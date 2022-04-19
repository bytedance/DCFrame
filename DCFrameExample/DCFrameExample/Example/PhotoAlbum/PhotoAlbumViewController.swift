//
//  PhotoAlbumViewController.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2021/12/31.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import DCFrame

class PhotoAlbumViewController: DCCollectionController {
    override func viewDidLoad() {
        super.viewDidLoad()

        loadContainerModel(PhotoAlbumContainerModel())
    }
}
