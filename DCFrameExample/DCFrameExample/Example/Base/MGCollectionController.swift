//
//  DCCollectionController.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2019/8/7.
//  Copyright © 2019 Bytedance. All rights reserved.
//

import UIKit
import DCFrame

class DCCollectionController: UIViewController {
    public lazy var EDC: DCEventDataController = {
        let EDC = DCEventDataController()
        EDC.tag = String(describing: Self.self)
        return EDC
    }()

    public lazy var dcCollectionView = DCCollectionView(frame: .zero, collectionViewLayout: self.customCollectionLayout())

    override func viewDidLoad() {
        super.viewDidLoad()
        EDC.addChildEDC(dcCollectionView.eventDataController)

        dcCollectionView.dcViewController = self
        dcCollectionView.frame = view.frame
        dcCollectionView.contentInset = UIEdgeInsets(top: navbarHeight(), left: 0, bottom: safeBottomMargin(), right: 0)

        view.backgroundColor = .white
        view.addSubview(dcCollectionView)
    }

    public func loadContainerModel(_ containerModel: DCContainerModel) {
        dcCollectionView.loadContainerModel(containerModel)
    }

    open func customCollectionLayout() -> UICollectionViewLayout? {
        return nil
    }
}

extension UIViewController {
    public func isIPhoneX() -> Bool {
        if #available(iOS 11.0, tvOS 11.0, *), let window = UIApplication.shared.keyWindow {
            if window.safeAreaInsets.left > 0 || window.safeAreaInsets.bottom > 0 {
                return true
            }
        }
        return false
    }

    public func navbarHeight() -> CGFloat {
        return UIApplication.shared.statusBarFrame.height + 44
    }

    public func safeBottomMargin() -> CGFloat {
        if isIPhoneX() {
            return 34.0
        } else {
            return 0.0
        }
    }
}
