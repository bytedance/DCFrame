//
//  File.swift
//  DCFrame_Example
//

import UIKit
import DCFrame

class ShoppingCartViewController: UIViewController {
    let containerView = DCContainerView()
    let totalView = ShoppingCartTotalView()

    let eventDataController = DCEventDataController()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        handleEvents()

        containerView.loadContainerModel(ShoppingCartContainerModel())
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(containerView)
        view.addSubview(totalView)

        containerView.snp.makeConstraints { make in
            make.top.equalTo(DemoUtil.navbarHeight())
            make.left.right.equalToSuperview()
            make.bottom.equalTo(totalView.snp.top)
        }

        totalView.snp.makeConstraints { make in
            make.height.equalTo(DemoUtil.safeBottomMargin() + 80)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    private func handleEvents() {
        eventDataController.addChildEDC(containerView.eventDataController)

        eventDataController.subscribeEvent(ShoppingCartContainerModel.dataUpdated, target: self) { [weak self] (data: ShoppingCartData) in
            self?.totalView.update(price: data.totalPrice())
        }
    }
}
