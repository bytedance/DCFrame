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
        return T()
    }
}

/// Base Cell class a DCBaseCellModel belongs to
open class DCBaseCell: UITableViewCell {
    
    static let dc_selectedCell = DCEventID()
    static let dc_currentSelectModel = DCSharedDataID()
    
    /// DCBaseCellModel the current Cell corresponds to
    public var baseCellModel: DCBaseCellModel {
        get {
            if let cellModel = p_baseCellModel {
                return cellModel
            } else {
                assert(false, "cellModel is not initialized, please use after cellModelDidLoad")
                return DCBaseCellModel()
            }
        }
        set {
            p_baseCellModel = newValue
        }
    }
    internal private(set) var p_baseCellModel: DCBaseCellModel?
    
    /// Boolean for whether the corresponding CellModel has been loaded
    public var isCellModelDidLoad: Bool {
        return p_baseCellModel != nil
    }
    
    /// EDC of the current Cell, reusing the EDC of the CellModel
    public var eventDataController: DCEventDataController {
        return baseCellModel.eventDataController
    }
    
    /// Perform operations on the TableView through this parameter, like updating data, scrolling to a specific position, etc
    public weak var dcHandler: DCBaseOperationProtocol?
    
    /// dcViewController of the corresbonding DCContainerTableView
    public weak var dcViewController: UIViewController?
    
    /// DCContainerTableView that loads the Cell
    public weak var containerTableView: DCContainerTableView?
    
    private(set) var isNeedReCreated = true // UITableView will release reusable stack when receiving a memory warning, so adding a flag on the view is required to recreate the Cell
    private var isSubscribeEvent = false
    private var isSubscribeData = false
    
    var assert_cellModelDidLoad = true
    var assert_cellModelDidUpdate = true
    var assert_setupUI = true
    var assert_didSelect = true
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        if assert_setupUI {
            assert(false, "super.setupUI() has not been called")
        }
    }
    
    /// Called when the Cell initializes. Setting up the UI by overriding this function is recommended
    open func setupUI() {
        assert_setupUI = false
        
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
    
    /// Cell added by `addSubCell()` and `addXibCell()` can acquire transferred data with this function
    /// - Returns: cellData of the current Cell
    final public func getCellData() -> Any? {
        return baseCellModel.cellData
    }
    
    /// Acquire data in the CellModel with generics type conversion when the Cell is added through `addSubCell()` or `addXibCell()`
    /// Usually called in `cellModelDidUpdate()`
    /// - Parameter default: default value if the data is nil or type conversion fails
    /// - Returns: cellData of the current Cell
    final public func getCellData<T>(default: T) -> T {
        if let data = baseCellModel.cellData as? T {
            return data
        }
        return `default`
    }
    
    /// Modify `cellData` in `baseCellModel`
    /// - Parameter data: data object of any type
    final public func setCellData(_ data: Any?) {
        baseCellModel.cellData = data
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
    /// - Parameter scrollView: `UITableView` the Cell belongs to
    open func didScrollingInScreen(_ scrollView: UIScrollView) {
        // override
    }
    
    /// Called when there's a click on the Cell
    /// Caution: Floating views with CellModel set to isHoverTop cannot call back this function
    open func didSelect() {
        assert_didSelect = false
        if autoDeselect() {
            deselectCell()
        } else {
            sendEvent(Self.dc_selectedCell, data: baseCellModel)
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
        containerTableView?.deselectRow(at: indexPath, animated: animated)
        sendEvent(Self.dc_selectedCell, data: nil)
    }
    
    /// Select the Cell
    /// - Parameters:
    ///   - animated: boolean for animated selection
    ///   - scrollPosition: scroll position enumeration
    final public func selectCell(animated: Bool = true, scrollPosition: UITableView.ScrollPosition = .none) {
        guard let indexPath = baseCellModel.indexPath else {
            return
        }
        containerTableView?.selectRow(at: indexPath, animated: animated, scrollPosition: scrollPosition)
        sendEvent(Self.dc_selectedCell, data: baseCellModel)
    }
    
    /// Called once when loading a new baseCellModel. The function is called once in a cellModel lifecycle.
    open func cellModelDidLoad() {
        assert_cellModelDidLoad = false
        
        if isSubscribeData {
            eventDataController.removeAllSubscribeData(frome: self)
            isSubscribeData = false
        }
        if isSubscribeEvent {
            eventDataController.removeAllSubscribeEvent(frome: self)
            isSubscribeEvent = false
        }
        
        isNeedReCreated = false
        // override
    }
    
    /// Data related to UI update should be assigned in this function. Placing complex logic here is not recommended to maintain scrolling performance
    /// Data related to UI update should be reassigned here since the TableView Cell reuse logic causes the View to have only one instance
    open func cellModelDidUpdate() {
        assert_cellModelDidUpdate = false
        
        selectionStyle = baseCellModel.getSelectionStyle()
        
        if backgroundColor == nil {
            if let color = containerTableView?.cellBackgroundColor {
                backgroundColor = color
            } else {
                backgroundColor = DCConfig.shared.cellBackgroundColor
            }
        }
        
        if selectedBackgroundView?.backgroundColor == nil {
            if let color = baseCellModel.getSelectedColor() {
                selectedBackgroundView?.backgroundColor = color
            } else if let color = containerTableView?.cellSelectedColor {
                selectedBackgroundView?.backgroundColor = color
            } else {
                selectedBackgroundView?.backgroundColor = DCConfig.shared.selectedColor
            }
        }
 
        if (sharedData(of: Self.dc_currentSelectModel) as? DCBaseCellModel)  === baseCellModel {
            selectCell(animated: false, scrollPosition: .none)
        }
        
        // Display Cell with gradient
        if baseCellModel.isGradientDisplay && baseCellModel.getCellHeight() > CGFloat.leastNonzeroMagnitude {
            baseCellModel.isGradientDisplay = false
            contentView.alpha = 0
            UIView.animate(withDuration: DCDuration.Short, animations: {
                self.contentView.alpha = 1
            })
        }
        // override
    }
    
    /// Called back before a screenshot to make some screenshot layout changes
    open func beforeScreenshot() {
        // override
    }
    
    /// Called back after a screenshot to recover screenshot layout changes
    open func afterScreenshot() {
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
    
    public func shareData(to sd: DCSharedDataID, closure: @escaping EDCSharedDataCallback) {
        eventDataController.shareData(to: sd, broadcast: true, closure: closure)
    }
    
    public func shareData(to sd: DCSharedDataID, broadcast: Bool, closure: @escaping EDCSharedDataCallback) {
        eventDataController.shareData(to: sd, broadcast: broadcast, closure: closure)
    }
    
    public func sendEvent(_ event: DCEventID) {
        sendEvent(event, data: nil)
    }
    
    public func sendEvent(_ event: DCEventID, data: Any?) {
        eventDataController.sendEvent(event, data: data)
    }

    @discardableResult
    public func subscribeEvent(_ event: DCEventID, completion: @escaping (Any?) -> Void) -> DCSubscribeEventAndable {
        isSubscribeEvent = true
        return eventDataController.subscribeEvent(event, target: self, completion: completion)
    }
    
    @discardableResult
    public func subscribeEvent<T>(_ event: DCEventID, completion: @escaping (T) -> Void) -> DCSubscribeEventAndable {
        isSubscribeEvent = true
        return eventDataController.subscribeEvent(event, target: self, completion: completion)
    }
    
    @discardableResult
    public func subscribeEvents(_ events: [DCEventID], completion: @escaping (DCEventID) -> Void) -> DCSubscribeEventAndable {
        isSubscribeEvent = true
        return eventDataController.subscribeEvents(events, target: self, completion: completion)
    }
    
    @discardableResult
    public func subscribeEvents(_ events: [DCEventID], completion: @escaping (DCEventID, Any?) -> Void) -> DCSubscribeEventAndable {
        isSubscribeEvent = true
        return eventDataController.subscribeEvents(events, target: self, completion: completion)
    }
    
    @discardableResult
    public func subscribeEvents<T>(_ events: [DCEventID], completion: @escaping (DCEventID, T) -> Void) -> DCSubscribeEventAndable {
        isSubscribeEvent = true
        return eventDataController.subscribeEvents(events, target: self, completion: completion)
    }
    
    @discardableResult
    public func subscribeData<T>(_ sd: DCSharedDataID, completion: @escaping (T) -> Void) -> DCSubscribeDataAndable {
        isSubscribeData = true
        return eventDataController.subscribeData(sd, target: self, completion: completion)
    }
    
    @discardableResult
    public func subscribeData<T>(_ sd: DCSharedDataID, completion: @escaping (T) -> Void, emptyCall: @escaping () -> Void) -> DCSubscribeDataAndable {
        isSubscribeData = true
        return eventDataController.subscribeData(sd, target: self, completion: completion, emptyCall: emptyCall)
    }
}
