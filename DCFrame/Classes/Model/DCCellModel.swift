//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation

open class DCCellModel: DCBaseCellModel {
    public required override init() {
        super.init()
    }
}

/// Model belonging to a Cell to provide and handle data
/// `cellClass` and `cellHeight` initialization are normally required, other protocols and properties can be set as needed
open class DCBaseCellModel: NSObject {
    /// Selected state for the corresponding Cell
    public lazy var selectionStyle: UITableViewCell.SelectionStyle = .none
    
    /// Class of the Cell that the CellModel belongs to
    public lazy var cellClass: AnyClass = DCBaseCell.self
    
    /// The current height of the Cell. If not initialized, `isAutomaticDimension` has to be set as true
    public lazy var cellHeight: CGFloat = 0
    
    /// Option for calculating the `cellHeight` automatically, if `cellHeight` has been initialized, option will be ignored.
    public lazy var isAutomaticDimension = false
    
    /// Set to true is the Cell uses xib for layout
    public lazy var isXibCell = false
    
    /// Bundle for acquiring xib, default as the cellClass's bundle
    public lazy var xibBundle: Bundle = {
        return Bundle(for: getCellClass())
    }()
    
    /// A parameter for assigning values to Cell if Cell data is not customized
    /// In ContainerModel, `addSubCell()` provides data for Cells using this parameter
    public var cellData: Any?
    
    /// Top separator for a Cell, hides and shows together following the current Model
    public var topSeparator: DCBaseCellModel?
    
    /// Bottom separator for a Cell, hides and shows following the current Model
    public var bottomSeparator: DCBaseCellModel?
    
    /// An identifier for reusing a Cell, default as the class name of the Cell, used by `dequeueReusableCell()` to acquire reusable Cell
    public var reuseIdentifier: String {
        get {
            if let id = p_reuseIdentifier {
                return id
            }
            return String(describing: getCellClass())
        }
        set {
            p_reuseIdentifier = newValue
        }
    }
    private var p_reuseIdentifier: String?
    
    /// Set to true if Cell cannot be reused, after assigned, `celModelDidUpdate()` won't be called repeatedly to improve scrolling performance
    public var isUniqueIdentifier: Bool = false
    
    /// Boolean for whether Cell is hidden, after assigned, `cellModelDidLoad()` will not call back
    public lazy var isHidden: Bool = false
    
    /// Boolean for whether the Cell hovers above the view
    public lazy var isHoverTop: Bool = false
    
    /// Boolean for whether the Cell always hovers above the view. After assigned, other Cells that have `isHoverTop` set to be true would hover below the current Cell
    public lazy var isAlwaysHoverTop: Bool = false
    
    /// Boolean for whether the Cell is displayed with gradient when loading
    public lazy var isGradientDisplay: Bool = false
    
    /// Boolean for whether the Cell is displayed when `dcScreenshot()` takes a screenshot
    public lazy var willBeInScreenShot: Bool = true
    
    /// The EDC of the current Model with a default value of the ContainerModel's EDC
    public var eventDataController: DCEventDataController {
        get {
            if let edc = p_eventDataController {
                return edc
            } else {
                assert(false, "eventDataController has not been initialized, can be used after cellModelDidLoad()")
                return DCEventDataController()
            }
        }
        set {
            p_eventDataController = newValue
        }
    }
    private var p_eventDataController: DCEventDataController?
    
    /// Cell object that the current Model belongs to. This parameter will stay nil until Cell is displayed, usage is not recommended
    public weak var dcCell: DCBaseCell?
    
    /// Protocol that provides a set of common protocols for controling the list, including `needReloadData()`, `getVisibleCells()`
    public weak var dcHandler: DCBaseOperationProtocol?
    
    /// The ContainerModel the current Model belongs to
    public weak var containerModel: DCContainerModel?
    
    /// The corresponding IndexPath of the Cell in the TableView
    public var indexPath: IndexPath?
    
    /// Background color of the Cell under selected state
    public var selectedColor: UIColor
    
    private(set) var isCellModelLoaded: Bool = false
    private lazy var refreshThrottler = DCThrottler(timeInterval: 0.05)
    
    internal var assert_cellModelDidLoad = true
    
    public override init() {
        selectedColor = DCConfig.shared.selectedColor
        super.init()
    }

    /// Only called once in a lifecycle
    /// Called only when the Cell loads. Time consuming logics can be put here to reduce loading time of the page
    open func cellModelDidLoad() {
        assert_cellModelDidLoad = false
        
        isCellModelLoaded = true
        // override
    }
    
    /// Initialize parameters of the CellModel that are used by the Cell in `CellModelDidLoad()`
    /// Since UITableView would clear the reusable Cell stack when there's a memory warning, layout issue may occur if Cell's data are not reset here
    open func cellReCreated() {
        // override
    }

    /// Trigger the `cellModelDidUpdate()` function to update data in the current View. This function will not reset `cellHeight`
    public func needReloadCellData() {
        // Access has to be limited to a certain degree to avoid frequent repeated call
        refreshThrottler.execute("needReloadViewData") { [weak self] in
            guard let `self` = self else { return }
            self.dcHandler?.needReloadData(indexPath: self.indexPath)
        }
    }
    
    /// Get the vertical offset of the current Cell in the list
    public func getCellOffsetY() -> CGFloat? {
        if let tableView = containerModel?.containerTableView, let indexPath = self.indexPath {
            return tableView.rectForRow(at: indexPath).origin.y
        }
        return nil
    }
    
    
    /**
     * Directly assigning parameters like cellHeight is recommended
     * Overriding functions below can achieve dynamically calculating and returning parameters
     */
    
    open func getSelectedColor() -> UIColor {
        return selectedColor
    }
    
    open func getCellClass() -> AnyClass {
        return cellClass
    }
    
    open func getCellHeight() -> CGFloat {
        return cellHeight
    }
    
    open func getIsHidden() -> Bool {
        return isHidden
    }
    
    open func getIsHoverTop() -> Bool {
        return isHoverTop
    }
    
    open func getIsAlwaysHoverTop() -> Bool {
        return isAlwaysHoverTop
    }
    
    open func getSelectionStyle() -> UITableViewCell.SelectionStyle {
        return selectionStyle
    }
}

// MARK: - Handle Event and data

extension DCBaseCellModel {
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
    public func subscribeEvent(_ event: DCEventID, completion: @escaping () -> Void) -> DCSubscribeEventAndable {
        return eventDataController.subscribeEvent(event, target: self, completion: completion)
    }
    
    @discardableResult
    public func subscribeEvent(_ event: DCEventID, completion: @escaping (Any?) -> Void) -> DCSubscribeEventAndable {
        return eventDataController.subscribeEvent(event, target: self, completion: completion)
    }
    
    @discardableResult
    public func subscribeEvent<T>(_ event: DCEventID, completion: @escaping (T) -> Void) -> DCSubscribeEventAndable {
        return eventDataController.subscribeEvent(event, target: self, completion: completion)
    }
    
    @discardableResult
    public func subscribeEvents(_ events: [DCEventID], completion: @escaping (DCEventID) -> Void) -> DCSubscribeEventAndable {
        return eventDataController.subscribeEvents(events, target: self, completion: completion)
    }
    
    @discardableResult
    public func subscribeEvents(_ events: [DCEventID], completion: @escaping (DCEventID, Any?) -> Void) -> DCSubscribeEventAndable {
        return eventDataController.subscribeEvents(events, target: self, completion: completion)
    }
    
    @discardableResult
    public func subscribeEvents<T>(_ events: [DCEventID], completion: @escaping (DCEventID, T) -> Void) -> DCSubscribeEventAndable {
        return eventDataController.subscribeEvents(events, target: self, completion: completion)
    }
    
    @discardableResult
    public func subscribeData<T>(_ sd: DCSharedDataID, completion: @escaping (T) -> Void) -> DCSubscribeDataAndable {
        return eventDataController.subscribeData(sd, target: self, completion: completion)
    }
    
    @discardableResult
    public func subscribeData<T>(_ sd: DCSharedDataID, completion: @escaping (T) -> Void, emptyCall: @escaping () -> Void) -> DCSubscribeDataAndable {
        return eventDataController.subscribeData(sd, target: self, completion: completion, emptyCall: emptyCall)
    }
}
