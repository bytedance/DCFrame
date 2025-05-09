//
//  DemosViewController.swift
//  DCContainerView_Example
//

import UIKit
import DCFrame

class DemosViewController: UIViewController {
    public lazy var EDC: DCEventDataController = {
        let EDC = DCEventDataController()
        EDC.tag = String(describing: Self.self)
        return EDC
    }()

    public lazy var containerView = DCContainerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        EDC.addChildEDC(containerView.eventDataController)

        containerView.dcViewController = self
        containerView.frame = view.frame
        containerView.contentInset = UIEdgeInsets(top: DemoUtil.navbarHeight(), left: 0, bottom: DemoUtil.safeBottomMargin(), right: 0)

        view.backgroundColor = .white
        view.addSubview(containerView)
    }

    public func loadContainerModel(_ containerModel: DCContainerModel) {
        containerView.loadContainerModel(containerModel)
    }
}
