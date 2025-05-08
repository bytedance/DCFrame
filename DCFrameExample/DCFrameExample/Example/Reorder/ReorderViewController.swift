//
//  ReorderViewController.swift
//  DCFrame_Example
//
//  Created by zhoufeng on 2022/3/15.
//  Copyright © 2022 Bytedance. All rights reserved.
//

import UIKit
import DCFrame

class ReorderViewController: DemosViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let containerModel = GridCategoryGroudModel(with: GridsMockData.getReorderData())
        loadContainerModel(containerModel)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture(gesture:)))
        containerView.addGestureRecognizer(longPressGesture)
        containerView.dcDelegate = self
    }

    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            let touchLocation = gesture.location(in: containerView)
            guard let selectedIndexPath = containerView.indexPathForItem(at: touchLocation) else {
                break
            }
            containerView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            if let view = gesture.view {
                let position = gesture.location(in: view)
                containerView.updateInteractiveMovementTargetPosition(position)
            }
        case .ended:
            containerView.endInteractiveMovement()
        default:
            containerView.cancelInteractiveMovement()
        }
    }
}

extension ReorderViewController: DCContainerViewDelegate {
    func dcContainerView(_ containerView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func dcContainerView(_ containerView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let containerView = containerView as? DCContainerView else {
            return
        }
        let item = containerView.dataController.objects[sourceIndexPath.item]
        containerView.dataController.objects.remove(at: sourceIndexPath.item)
        containerView.dataController.objects.insert(item, at: destinationIndexPath.item)
    }
}
