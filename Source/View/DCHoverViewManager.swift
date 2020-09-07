//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import UIKit

class DCHoverViewManager: NSObject {
    public weak var containerTableView: DCContainerTableView?

    private var alwaysHoverIndexArray = [IndexPath]()
    private var isAlwaysHoverDict = [IndexPath: Bool]()
    private var hoverIndexArray = [IndexPath]()
    private var currentIndexPath: IndexPath?

    private(set) var currentHoverView: DCBaseCell?
    private(set) var currentAlwaysHoverViews = [DCBaseCell]()
    
    private lazy var hoverViewsCache: NSCache<NSIndexPath, DCBaseCell> = {
        let cache = NSCache<NSIndexPath, DCBaseCell>()
        cache.countLimit = 30
        return cache
    }()

    public func updateHoverDCViews() {
        guard let containerTableView = self.containerTableView else {
            return
        }
        alwaysHoverIndexArray.removeAll()
        hoverIndexArray.removeAll()
        currentIndexPath = nil
        currentHoverView?.removeFromSuperview()
        currentHoverView = nil
        isAlwaysHoverDict.removeAll()
        for view in currentAlwaysHoverViews {
            view.removeFromSuperview()
        }
        currentAlwaysHoverViews.removeAll()

        for (rowIndex, item) in containerTableView.dataController.objects.enumerated() {
            guard let baseCellModel = item as? DCBaseCellModel else {
                continue
            }
            let indexPath = IndexPath(row: rowIndex, section: 0)

            if baseCellModel.getIsHoverTop() || baseCellModel.getIsAlwaysHoverTop() {
                hoverIndexArray.append(indexPath)
            }
            if baseCellModel.getIsAlwaysHoverTop() {
                alwaysHoverIndexArray.append(indexPath)
            }
        }

        for indexPath in alwaysHoverIndexArray {
            if let dcCell = getHoverDCCell(indexPath) {
                dcCell.isHidden = true
                containerTableView.addSubview(dcCell)
                currentAlwaysHoverViews.append(dcCell)
            }
            isAlwaysHoverDict[indexPath] = true
        }
        
        handleHoverViews()
    }

    public func handleHoverViews() {
        guard let tableView = containerTableView else {
            return
        }
        var offsetY = tableView.contentOffset.y + tableView.contentInset.top

        if currentAlwaysHoverViews.count > 0 {
            for (index, indexPath) in alwaysHoverIndexArray.enumerated() {
                if let hoverView = currentAlwaysHoverViews[dc_safe: index] {
                    if let hoverTopY = getHoverTopY(indexPath), hoverTopY < offsetY {
                        hoverView.frame = CGRect(x: 0, y: offsetY, width: tableView.frame.width, height: hoverView.baseCellModel.getCellHeight())
                        offsetY += hoverView.dc_height
                        if hoverView.isHidden {
                            hoverView.isHidden = false
                            hoverView.cellModelDidUpdate()
                        }
                    } else {
                        hoverView.isHidden = true
                    }
                }
            }
        }

        var tmpCur: IndexPath?
        var tmpNext: IndexPath?
        for indexPath in hoverIndexArray {
            if let hoverTopY = getHoverTopY(indexPath), hoverTopY >= offsetY {
                tmpNext = indexPath
                break
            }
            if isAlwaysHoverDict[indexPath] == nil {
                tmpCur = indexPath
            } else {
                tmpCur = nil
            }
        }

        if let indexPath = tmpCur {
            let topOffset = offsetY

            if currentIndexPath != indexPath {
                currentIndexPath = indexPath
                currentHoverView?.removeFromSuperview()
                currentHoverView = nil

                if let hoverView = getHoverDCCell(indexPath) {
                    currentHoverView = hoverView
                    currentHoverView?.dc_top = topOffset
                    containerTableView?.addSubview(hoverView)
                }
            }
            
            if let currentHoverView = currentHoverView {
                if let nextIndexPath = tmpNext, let nextTopY = getHoverTopY(nextIndexPath), let hoverViewHeight = getHoverViewHeight(indexPath) {
                    let hoverBottomY = hoverViewHeight + offsetY
                    if nextTopY < hoverBottomY {
                        currentHoverView.frame = CGRect(x: 0, y: topOffset + (nextTopY - hoverBottomY), width: tableView.frame.width, height: currentHoverView.baseCellModel.getCellHeight())
                    } else {
                        currentHoverView.frame = CGRect(x: 0, y: topOffset, width: tableView.frame.width, height: currentHoverView.baseCellModel.getCellHeight())
                    }
                } else {
                    currentHoverView.frame = CGRect(x: 0, y: topOffset, width: tableView.frame.width, height: currentHoverView.baseCellModel.getCellHeight())
                }
            }
        } else {
            currentHoverView?.removeFromSuperview()
            currentHoverView = nil
            currentIndexPath = nil
        }
    }

    private func getHoverTopY(_ indexPath: IndexPath) -> CGFloat? {
        guard let tableView = containerTableView else {
            return nil
        }
        return tableView.rectForRow(at: indexPath).origin.y
    }

    private func getHoverViewHeight(_ indexPath: IndexPath) -> CGFloat? {
        guard let baseCellModel = getDCCellModel(indexPath) else {
            return nil
        }
        return baseCellModel.getCellHeight()
    }

    private func getDCCellModel(_ indexPath: IndexPath) -> DCBaseCellModel? {
        guard let baseCellModel = containerTableView?.dataController.objectAtIndexPath(indexPath) as? DCBaseCellModel else {
            return nil
        }
        return baseCellModel
    }

    private func getHoverDCCell(_ indexPath: IndexPath) -> DCBaseCell? {
        let key = NSIndexPath(row: indexPath.row, section: indexPath.section)
        let cellModel = getDCCellModel(indexPath)
        if let cell = hoverViewsCache.object(forKey: key), cell.baseCellModel === cellModel {
            cell.cellModelDidUpdate()
            return cell
        }
        if let cell = createDCCell(indexPath) {
            hoverViewsCache.setObject(cell, forKey: key)
            return cell
        }
        return nil
    }
    
    private func createDCCell(_ indexPath: IndexPath) -> DCBaseCell? {
        guard let baseCellModel = getDCCellModel(indexPath), let cellClass = baseCellModel.getCellClass() as? UITableViewCell.Type else {
            return nil
        }
        guard let containerTableView = self.containerTableView else {
            return nil
        }
        var tmpDCCell: DCBaseCell?
        if baseCellModel.isXibCell {
            if let cell = baseCellModel.xibBundle.loadNibNamed(String(describing: cellClass), owner: containerTableView)?.first as? DCBaseCell {
                tmpDCCell = cell
            }
        } else {
            if let cell = cellClass.init(style: .default, reuseIdentifier: String(describing: cellClass)) as? DCBaseCell {
                tmpDCCell = cell
            }
        }
        if let dcCell = tmpDCCell {
            dcCell.frame = CGRect(x: 0, y: 0, width: containerTableView.frame.width, height: baseCellModel.getCellHeight())
            dcCell.layer.zPosition = baseCellModel.isAlwaysHoverTop ? 2000 : 1000
            containerTableView.updateCell(dcCell, baseCellModel, isHoverTop: true)
            return dcCell
        } else {
            return nil
        }
    }
}
