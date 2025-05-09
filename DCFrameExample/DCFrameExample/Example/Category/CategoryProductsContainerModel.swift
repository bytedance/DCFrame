//
//  ShoppingCartContainerModel.swift
//  DCFrame_Example
//

import UIKit
import DCFrame

class CategoryProductsContainerModel: DCContainerModel {
    static let showTitle = DCEventID()
    static let scrollOffsetY = DCSharedDataID()

    var headerModelMap = [String: CategoryHeaderCellModel]()
    var headerModels = [CategoryHeaderCellModel]()

    private var currentTitle: String?

    func handleData(data: CategoryData) {
        headerModelMap.removeAll()
        headerModels.removeAll()
        removeAllSubModels()

        for (index, category) in data.categries.directValue.enumerated() {
            let headerModel = CategoryHeaderCellModel()
            headerModel.title = category.title

            if index == 0 {
                currentTitle = category.title
            }

            headerModelMap[category.title] = headerModel
            headerModels.append(headerModel)

            let containerMoel = DCContainerModel()
            containerMoel.layoutContext.leftMargin = 10
            containerMoel.layoutContext.topMargin = 10
            containerMoel.layoutContext.bottomMargin = 30
            containerMoel.layoutContext.horizontalInterval = 10
            containerMoel.layoutContext.verticalInterval = 10

            for item in category.products {
                let model = GridItemCellModel()
                model.text = item
                model.color = UIColor(red: 56 / 255.0, green: 151 / 255.0, blue: 240 / 255.0, alpha: 1)
                model.cellSize = CGSize(width: 80, height: 80)
                containerMoel.addSubModel(model)
            }

            addSubModels([headerModel, containerMoel])
        }

        containerViewHandler?.needUpdateLayout()
    }

    override func containerModelDidLoad() {
        super.containerModelDidLoad()

        subscribeData(Self.scrollOffsetY) { [weak self] (offsetY: CGFloat) in
            guard let title = self?.getCurrentTitle(offsetY) else {
                return
            }
            if title != self?.currentTitle {
                self?.sendEvent(Self.showTitle, data: title)
                self?.currentTitle = title
            }
        }
    }

    func scrollTo(title: String) {
        guard let indexPath = headerModelMap[title]?.indexPath else {
            return
        }

        dcContainerView?.scrollToItem(at: indexPath, at: .top, animated: true)
    }

    private func getCurrentTitle(_ offsetY: CGFloat) -> String? {
        for model in headerModels.reversed() {
            if let indexPath = model.indexPath, let y = dcContainerView?.layoutAttributesForItem(at: indexPath)?.frame.origin.y {
                if y <= offsetY {
                    return model.title
                }
            }
        }
        return nil
    }
}
