//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import UIKit

open class DCCell<T: DCCellModel>: DCBaseCell {
    public var cellModel: T {
        if let _cellModel = baseCellModel as? T {
            return _cellModel
        }
        #if DEBUG
        assert(false, "cellModel type matching error")
        #endif
        return T()
    }
}

/// Base Cell class a DCCellModel belongs to
open class DCBaseCell: UICollectionViewCell {

    /// DCCellModel the current Cell corresponds to
    public var baseCellModel: DCCellModel {
        get {
            if let cellModel = p_baseCellModel {
                return cellModel
            } else {
                assert(false, "cellModel is not initialized, please use after cellModelDidLoad")
                return DCCellModel()
            }
        }
        set {
            p_baseCellModel = newValue
        }
    }
    private var p_baseCellModel: DCCellModel?

    /// Boolean for whether the corresponding CellModel has been loaded
    public var isCellModelDidLoad: Bool {
        return p_baseCellModel != nil
    }

    /// EDC of the current Cell, reusing the EDC of the CellModel
    public var eventDataController: DCEventDataController {
        return baseCellModel.eventDataController
    }

    /// Perform operations on the CollectionView through this parameter, like updating data, scrolling to a specific position, etc
    public weak var dcHandler: DCBaseOperationable?

    /// dcViewController of the corresbonding DCCollectionView
    public weak var dcViewController: UIViewController?

    /// DCCollectionView that loads the Cell
    public weak var dcCollectionView: DCCollectionView?

    private(set) var isNeedReCreated = true // UICollectionView will release reusable stack when receiving a memory warning, so adding a flag on the view is required to recreate the Cell

    #if DEBUG
    var assert_cellModelDidUpdate = true
    var assert_setupUI = true
    var assert_didSelect = true
    #endif

    public override init(frame: CGRect) {
        super.init(frame: frame)
        p_init()
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        p_init()
    }

    private func p_init() {
        self.selectedBackgroundView = UIView()
        self.clipsToBounds = true

        self.setupUI()

        #if DEBUG
        if assert_setupUI {
            assert(false, "super.setupUI() has not been called")
        }
        #endif
    }

    /// Called when the Cell initializes. Setting up the UI by overriding this function is recommended
    open func setupUI() {
        #if DEBUG
        assert_setupUI = false
        #endif

        // override
    }

    /// Override `addSubview` function to add the subview to the contentView
    open override func addSubview(_ view: UIView) {
        if view !== contentView {
            contentView.addSubview(view)
        } else {
            super.addSubview(view)
        }
    }

    /// When the current view is scrolling, function will be called everytime it appears on the screen
    open func willDisplay() {
        // override
    }

    /// Opposite of willDisplay()
    open func didEndDisplaying() {
        // override
    }

    /// Celled if `DCBaseCell` is in the screen and is scrolling
    /// - Parameter scrollView: `UICollectionView` the Cell belongs to
    open func didScrollingInScreen(_ scrollView: UIScrollView) {
        // override
    }

    /// Called when there's a click on the Cell
    /// Caution: Floating views with CellModel set to isHoverTop cannot call back this function
    open func didSelect() {
        #if DEBUG
        assert_didSelect = false
        #endif

        if autoDeselect() {
            deselectCell()
        }
        // override
    }

    /// Boolean for whether deselecting the Cell automatically
    /// - Returns: returns false if Cell does not deselect automatially after it's clicked
    open func autoDeselect() -> Bool {
        return true
    }

    /// Deselect the Cell
    /// - Parameter animated: boolean for animated deselection
    final public func deselectCell(animated: Bool = true) {
        guard let indexPath = baseCellModel.indexPath else {
            return
        }

        dcCollectionView?.deselectItem(at: indexPath, animated: animated)
    }

    /// Select the Cell
    /// - Parameters:
    ///   - animated: boolean for animated selection
    ///   - scrollPosition: scroll position enumeration
    final public func selectCell(animated: Bool = true, scrollPosition: UICollectionView.ScrollPosition = []) {
        guard let indexPath = baseCellModel.indexPath else {
            return
        }

        dcCollectionView?.selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
    }

    /// Data related to UI update should be assigned in this function. It is not recommended to put complex logic calculations here, it will affect the scrolling performance
    open func cellModelDidUpdate() {
        #if DEBUG
        assert_cellModelDidUpdate = false
        #endif

        if backgroundColor == nil {
            if let color = dcCollectionView?.cellBackgroundColor {
                backgroundColor = color
            } else {
                backgroundColor = DCCollectionConfig.cellBackgroundColor
            }
        }

        if baseCellModel.isSelectionStyle {
            if let color = baseCellModel.getSelectedColor() {
                selectedBackgroundView?.backgroundColor = color
            } else if let color = dcCollectionView?.cellSelectedColor {
                selectedBackgroundView?.backgroundColor = color
            } else {
                selectedBackgroundView?.backgroundColor = DCCollectionConfig.selectedColor
            }
        } else {
            selectedBackgroundView?.backgroundColor = nil
        }

        if baseCellModel.isBackgroundCell {
            isUserInteractionEnabled = false
        }

        isNeedReCreated = false

        // override
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - Handle Data and Event

extension DCBaseCell {
    public func sharedData<T>(of sd: DCSharedDataID, default: T) -> T {
        return eventDataController.sharedData(of: sd, default: `default`)
    }

    public func sharedData(of sd: DCSharedDataID) -> Any? {
        return eventDataController.sharedData(of: sd)
    }

    public func shareData(_ data: Any?, to sd: DCSharedDataID) {
        eventDataController.shareData(data, to: sd)
    }

    public func shareData(_ data: Any?, to sd: DCSharedDataID, broadcast: Bool) {
        eventDataController.shareData(data, to: sd, broadcast: broadcast)
    }

    public func shareData(to sd: DCSharedDataID, closure: @escaping DCSharedDataCallbackBlock) {
        eventDataController.shareData(to: sd, broadcast: true, closure: closure)
    }

    public func shareData(to sd: DCSharedDataID, broadcast: Bool, closure: @escaping DCSharedDataCallbackBlock) {
        eventDataController.shareData(to: sd, broadcast: broadcast, closure: closure)
    }

    public func sendEvent(_ event: DCEventID) {
        sendEvent(event, data: nil)
    }

    public func sendEvent(_ event: DCEventID, data: Any?) {
        eventDataController.sendEvent(event, data: data)
    }
}
