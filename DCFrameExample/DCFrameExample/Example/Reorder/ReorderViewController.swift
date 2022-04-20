//
//  ReorderViewController.swift
//  DCFrame_Example
//
//  Created by zhoufeng on 2022/3/15.
//  Copyright © 2022 Bytedance. All rights reserved.
//

import UIKit
import DCFrame

class ReorderViewController: DCCollectionController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let containerModel = GridCategoryGroudModel(with: GridsMockData.getReorderData())
        loadContainerModel(containerModel)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture(gesture:)))
        dcCollectionView.addGestureRecognizer(longPressGesture)
        dcCollectionView.dcDelegate = self
    }

    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            let touchLocation = gesture.location(in: dcCollectionView)
            guard let selectedIndexPath = dcCollectionView.indexPathForItem(at: touchLocation) else {
                break
            }
            dcCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            if let view = gesture.view {
                let position = gesture.location(in: view)
                dcCollectionView.updateInteractiveMovementTargetPosition(position)
            }
        case .ended:
            dcCollectionView.endInteractiveMovement()
        default:
            dcCollectionView.cancelInteractiveMovement()
        }
    }
}

extension ReorderViewController: DCCollectionDelegate {
    func dcCollectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func dcCollectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = dcCollectionView.dataController.objects[sourceIndexPath.item]
        dcCollectionView.dataController.objects.remove(at: sourceIndexPath.item)
        dcCollectionView.dataController.objects.insert(item, at: destinationIndexPath.item)
    }
}
