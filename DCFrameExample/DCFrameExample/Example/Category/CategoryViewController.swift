//
//  File.swift
//  DCFrame_Example
//

import UIKit
import DCFrame

class CategoryViewController: UIViewController {
    let titlesView = DCContainerView()
    let titlesContainerModel = CategoryTitlesContainerModel()

    let productsView = DCContainerView()
    let productsContainerModel = CategoryProductsContainerModel()

    let eventDataController = DCEventDataController()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        handleEvents()

        handleData()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(titlesView)
        view.addSubview(productsView)

        titlesView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: DemoUtil.safeBottomMargin(), right: 0)
        titlesView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        titlesView.showsVerticalScrollIndicator = false
        titlesView.loadContainerModel(titlesContainerModel)

        productsView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: DemoUtil.safeBottomMargin(), right: 0)
        productsView.loadContainerModel(productsContainerModel)
        productsView.dcDelegate = self

        titlesView.snp.makeConstraints { make in
            make.top.equalTo(DemoUtil.navbarHeight())
            make.left.bottom.equalToSuperview()
            make.width.equalTo(100)
        }

        productsView.snp.makeConstraints { make in
            make.top.equalTo(DemoUtil.navbarHeight())
            make.bottom.right.equalToSuperview()
            make.left.equalTo(titlesView.snp.right)
        }
    }

    private func handleEvents() {
        eventDataController.addChildEDC(titlesView.eventDataController)
        eventDataController.addChildEDC(productsView.eventDataController)

        eventDataController.subscribeEvent(CategoryTitleCell.didSelect, target: self) { [weak self] (cellModel: CategoryTitleCellModel) in
            self?.productsContainerModel.scrollTo(title: cellModel.title)
        }

        eventDataController.subscribeEvent(CategoryProductsContainerModel.showTitle, target: self) { [weak self] (title: String) in
            self?.titlesContainerModel.showTitle(title)
        }
    }

    private func handleData() {
        let mockData = CategoryData()
        
        titlesContainerModel.handleData(data: mockData)
        productsContainerModel.handleData(data: mockData)
    }
}

extension CategoryViewController: DCContainerViewDelegate {
    func dcScrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            eventDataController.shareData(scrollView.contentOffset.y, to: CategoryProductsContainerModel.scrollOffsetY)
        }
    }
}
