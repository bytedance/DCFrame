//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import UIKit

/// Model belonging to a Cell to provide and handle data
/// `cellClass` and `cellHeight` initialization are normally required, other protocols and properties can be set as needed
open class DCCellModel: NSObject, DCBaseModel {

    /// Class of the Cell that the CellModel belongs to
    public var cellClass: AnyClass?

    /// Whether to display the cell selected style
    public var isSelectionStyle = false

    /// The current height of the Cell
    public var cellHeight: CGFloat = 0

    /// The current size of the Cell
    public var cellSize: CGSize = .zero

    /// Whether the current cell is a background cell, the background cell will be sent to back of other cells
    public var isBackgroundCell = false

    /// Whether the current cell is laid out on a new line
    public var isNewLine = false

    /// An identifier for reusing a Cell, default as the class name of the Cell, used by `dequeueReusableCell()` to acquire reusable Cell
    public var reuseIdentifier: String {
        get {
            if let id = p_reuseIdentifier {
                return id
            }
            let reuseIdentifier = String(describing: getCellClass())
            p_reuseIdentifier = reuseIdentifier
            return reuseIdentifier
        }
        set {
            p_reuseIdentifier = newValue
        }
    }
    private var p_reuseIdentifier: String?

    /// Boolean for whether Cell is hidden, after assigned, `cellModelDidLoad()` will not call back
    public var isHidden: Bool = false

    /// Boolean for whether the Cell hovers above the view
    public var isHoverTop: Bool = false
    
    /// The corresponding IndexPath of the hoverTopCell in the CollectionView
    public var hoverIndexPath: IndexPath?

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
    private weak var p_eventDataController: DCEventDataController?

    /// Cell object that the current Model belongs to. This parameter will stay nil until Cell is displayed, usage is not recommended
    public weak var dcCell: DCBaseCell?

    /// Protocol that provides a set of common protocols for controling the list
    public weak var containerViewHandler: DCBaseOperationDelegate?

    /// The ContainerModel the current Model belongs to
    public weak var dcContainerModel: DCContainerModel?

    /// The corresponding IndexPath of the Cell in the CollectionView
    public var indexPath: IndexPath?

    /// Background color of the Cell under selected state
    public var selectedColor: UIColor?

    private(set) var isCellModelLoaded = false

    private var refreshThrottler = DCThrottler(timeInterval: 0.05)

    #if DEBUG
    var assert_cellModelDidLoad = true
    #endif

    public required override init() {
        super.init()
        // do nothing
    }

    /// Only called once in a lifecycle
    /// Called only when the Cell loads. Time consuming logics can be put here to reduce loading time of the page
    open func cellModelDidLoad() {
        #if DEBUG
        assert_cellModelDidLoad = false
        #endif

        isCellModelLoaded = true
        // override
    }

    /// Trigger the `cellModelDidUpdate()` function to update data in the current View. This function will not reset `cellHeight`
    public func needUpdateCellData() {
        // Access has to be limited to a certain degree to avoid frequent repeated call
        refreshThrottler.execute("needUpdateCellData") { [weak self] in
            guard let self = self else { return }
            DCThrottler.executeInMainThread {
                if self.dcCell?.baseCellModel === self {
                    self.dcCell?.cellModelDidUpdate()
                }
            }
        }
    }

    /// Get the offset of the current Cell in the CollectionView
    public func getCellOffset() -> CGPoint? {
        if let collectionView = dcContainerModel?.dcContainerView, let indexPath = self.indexPath {
            return collectionView.layoutAttributesForItem(at: indexPath)?.frame.origin
        }
        return nil
    }

    /// Directly assigning parameters like cellHeight is recommended
    /// Overriding functions below can achieve dynamically calculating and returning parameters

    open func getSelectedColor() -> UIColor? {
        return selectedColor
    }

    open func getCellClass() -> AnyClass {
        if cellClass == nil {
            var className = String(reflecting: Self.self)
            if className.count > 5 {
                className.removeLast(5)
            }
            cellClass = NSClassFromString(className)
        }

        assert(cellClass != nil, "\(type(of: self)) cellClass is not assigned")

        return cellClass ?? DCBaseCell.self
    }

    open func getCellHeight() -> CGFloat {
        return cellHeight
    }

    open func getCellSize() -> CGSize {
        return cellSize
    }

    open func getIsHidden() -> Bool {
        return isHidden
    }

    open func getIsHoverTop() -> Bool {
        return isHoverTop
    }
    
    func getCellSize(collectionViewWidth: CGFloat) -> CGSize {
        let cellSize = getCellSize()
        if cellSize != .zero {
            return cellSize
        }
        
        let cellHeight = getCellHeight()
        if cellHeight > 0 {
            return CGSize(width: collectionViewWidth, height: cellHeight)
        }
        
        if !isBackgroundCell {
            assert(false, "cellSize and cellHeight cannot be smaller than zero")
        }
        
        return cellSize
    }
}

// MARK: - Handle Event and data

extension DCCellModel {
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

    @discardableResult
    public func subscribeEvent(_ event: DCEventID, completion: @escaping (Any?) -> Void) -> DCSubscribeEventAndAbility {
        return eventDataController.subscribeEvent(event, target: self, completion: completion)
    }

    @discardableResult
    public func subscribeEvent<T>(_ event: DCEventID, completion: @escaping (T) -> Void) -> DCSubscribeEventAndAbility {
        return eventDataController.subscribeEvent(event, target: self, completion: completion)
    }

    @discardableResult
    public func subscribeEvents(_ events: [DCEventID], completion: @escaping (DCEventID) -> Void) -> DCSubscribeEventAndAbility {
        return eventDataController.subscribeEvents(events, target: self, completion: completion)
    }

    @discardableResult
    public func subscribeEvents(_ events: [DCEventID], completion: @escaping (DCEventID, Any?) -> Void) -> DCSubscribeEventAndAbility {
        return eventDataController.subscribeEvents(events, target: self, completion: completion)
    }

    @discardableResult
    public func subscribeEvents<T>(_ events: [DCEventID], completion: @escaping (DCEventID, T) -> Void) -> DCSubscribeEventAndAbility {
        return eventDataController.subscribeEvents(events, target: self, completion: completion)
    }

    @discardableResult
    public func subscribeData<T>(_ sd: DCSharedDataID, completion: @escaping (T) -> Void) -> DCSubscribeDataAndAbility {
        return eventDataController.subscribeData(sd, target: self, completion: completion)
    }

    @discardableResult
    public func subscribeData<T>(_ sd: DCSharedDataID, completion: @escaping (T) -> Void, emptyCall: @escaping () -> Void) -> DCSubscribeDataAndAbility {
        return eventDataController.subscribeData(sd, target: self, completion: completion, emptyCall: emptyCall)
    }
}
