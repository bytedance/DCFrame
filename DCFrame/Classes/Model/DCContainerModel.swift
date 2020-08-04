//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation

/// CellModel Container class, abbreviated as CM
/// A `DCContainerModel` can include both `DCBaseCellModel` and `DCContainerModel`
open class DCContainerModel: NSObject, DCBaseOperationProtocol {
    
    /// Array for storing Model; Only getters and setters are allowed, no direct operations on this array
    public var modelArray: [Any] {
        set {
            p_modelArray.write {
                $0 = newValue
            }
        }
        get {
            return p_modelArray.directValue
        }
    }
    private lazy var p_modelArray = DCProtector<[Any]>([Any]())
    
    /// Display status of the current CM. If set to true, reloadData() in DCContainerTableView will not load this CM
    public lazy var isHidden: Bool = false
    
    /// EDC of the current CM, will be reused by CellModels and Cells of this CM
    public private(set) lazy var eventDataController: DCEventDataController = {
        let eventDataController = DCEventDataController()
        eventDataController.tag = String(describing: Self.self)
        return eventDataController
    }()
    
    /// Perform operations on the TableView through this parameter, like updating data, scrolling to a specific position, etc
    public weak var dcHandler: DCBaseOperationProtocol?
    
    /// Reference to `dcViewController` feature in `DCContainrTableView`
    public weak var dcViewController: UIViewController?
    
    /// Load the `DCContainerTableView` of the current CM
    public weak var containerTableView: DCContainerTableView?
    
    /// Boolean for whether the current CM is loaded
    public private(set) var isContainerModelLoaded: Bool = false
    
    /// CellModel of the top separator, often used as `DCSeparatorModel`
    public var topSeparator: DCBaseCellModel?
    
    /// CellModel of the bottom separator, often used as `DCSeparatorModel`
    public var bottomSeparator: DCBaseCellModel?
    
    private var isFirstGradientDisplay: Bool = false
    
    var assert_containerModelDidLoad = true
    
    // MARK: - Functions for Adding Submodels
    
    /// Add a single Model
    /// - Parameter model: Model of type `DCBaseCellModel` or `DCContainerModel`
    public func addSubmodel(_ model: Any) {
        guard isValidModel(model) else {
            return
        }
        p_modelArray.write {
            $0.append(model)
        }
    }
    
    /// Add a simple DCBaseCell. This method essentially adds a `DCBaseCellModel`. For simple `DCBaseCell`, you can add it to the CM without creating a corresponding `DCBaseCellModel`
    /// - Parameters:
    ///   - cellClass: class of the `DCBaseCell`
    ///   - data: data to be carried, can be acquired by calling `getCellData()` in `DCBaseCell`
    ///   - isXibCell: whether the cell is created from xib
    ///   - closure: call back for editing the auto-generated CellModel, like setting `cellHeight` and other properties
    public func addSubmodel(_ cellClass: AnyClass, data: Any? = nil, isXibCell: Bool = true, closure: ((DCBaseCellModel) -> Void)? = nil) {
        let baseModel = DCBaseCellModel()
        baseModel.cellClass = cellClass
        baseModel.isXibCell = isXibCell
        baseModel.isAutomaticDimension = true
        baseModel.cellData = data
        closure?(baseModel)
        
        addSubmodel(baseModel)
    }
    
    /// Add a XibCell
    /// - Parameters:
    ///   - cellClass: class of the XibCell
    ///   - data: data to be carried, can be acquired by calling `getCellData()` in DCBaseCell
    ///   - closure: call back for editing the auto-generated CellModel, like setting `cellHeight` and other properties
    public func addXibCell(_ cellClass: AnyClass, data: Any? = nil, closure: ((DCBaseCellModel) -> Void)? = nil) {
        addSubmodel(cellClass, data: data, isXibCell: true, closure: closure)
    }
    
    /// Add a `DCBaseCell`
    /// - Parameters:
    ///   - cellClass: class of the `DCBaseCell`
    ///   - data: data to be carried, can be acquired by calling `getCellData()` in DCBaseCell
    ///   - closure: call back for editing the auto-generated CellModel, like setting `cellHeight` and other properties
    public func addSubCell(_ cellClass: AnyClass, data: Any? = nil, closure: ((DCBaseCellModel) -> Void)? = nil) {
        addSubmodel(cellClass, data: data, isXibCell: false, closure: closure)
    }
    
    /// Add a separator Cell
    /// - Parameters:
    ///   - height: height of the separator Cell
    ///   - color: color of the separator Cell
    public func addSeparator(height: CGFloat? = nil, color: UIColor? = nil) {
        let separatorModel = DCSeparatorModel()
        if let _color = color {
            separatorModel.color = _color
        }
        if let _height = height {
            separatorModel.cellHeight = _height
        }
        addSubmodel(separatorModel)
    }
    
    /// Add a Model with the option of adding a separator Cell on top or bottom
    /// - Parameters:
    ///   - model: Model of type `DCBaseCellModel` or `DCContainerModel`
    ///   - separator: choice between .top/.bottom
    ///   - height: height of the separator Cell
    ///   - color: color of the separator Cell
    public func addSubmodel(_ model: Any, separator: DCSeparatorPositionType, height: CGFloat? = nil, color: UIColor? = nil) {
        let separatorModel = DCSeparatorModel()
        if let _color = color {
            separatorModel.color = _color
        }
        if let _height = height {
            separatorModel.cellHeight = _height
        }
        switch separator {
        case .top:
            if let _model = model as? DCBaseCellModel {
                _model.topSeparator = separatorModel
            } else if let _model = model as? DCContainerModel {
                _model.topSeparator = separatorModel
            }
            addSubmodel(model)
        case .bottom:
            if let _model = model as? DCBaseCellModel {
                _model.bottomSeparator = separatorModel
            } else if let _model = model as? DCContainerModel {
                _model.bottomSeparator = separatorModel
            }
            addSubmodel(model)
        }
    }
    
    /// Add a set of Models
    /// - Parameter models: an array of Models of type DCBaseCellModel or DCContainerModel
    public func addSubmodels(_ models: [Any]) {
        for model in models {
            addSubmodel(model)
        }
    }
    
    /// Add a set of Models with the option of adding a separator Cell on top or bottom
    /// - Parameters:
    ///   - models: an array of Models of type DCBaseCellModel or DCContainerModel
    ///   - separator: choice between .top/.bottom
    ///   - height: height of the separator Cell
    ///   - color: color of the separator Cell
    public func addSubmodels(_ models: [Any], separator: DCSeparatorPositionType, height: CGFloat? = nil, color: UIColor? = nil) {
        let separatorModel = DCSeparatorModel()
        if let _color = color {
            separatorModel.color = _color
        }
        if let _height = height {
            separatorModel.cellHeight = _height
        }
        switch separator {
        case .top:
            addSubmodel(separatorModel)
            addSubmodels(models)
        case .bottom:
            addSubmodels(models)
            addSubmodel(separatorModel)
        }
    }
    
    /// Insert a Model as the first element of the CM
    /// - Parameter model: Model to be inserted
    public func insertSubmodelToFront(_ model: Any) {
        insertSubmodel(model, at: 0)
    }
    
    /// Insert a Model as the n-th element of the CM
    /// - Parameters:
    ///   - model: Model to be inserted
    ///   - index: position of the Model in the CM
    public func insertSubmodel(_ model: Any, at index: Int) {
        guard isValidModel(model) else {
            return
        }
        p_modelArray.write {
            $0.insert(model, at: index)
        }
    }
    
    /// Insert a Model before a specific Model in the CM
    /// - Parameters:
    ///   - model: Model to be inserted
    ///   - before: the specified Model
    public func insertSubmodel(_ model: Any, before: Any) {
        guard isValidModel(model) && isValidModel(before) else {
            return
        }
        p_modelArray.write {
            var itemIndex = -1
            for (index, item) in $0.enumerated() where (item as? NSObject) === (before as? NSObject) {
                itemIndex = index
                break
            }
            if itemIndex != -1 {
                $0.insert(model, at: itemIndex)
            }
        }
    }
    
    /// Insert a Model after a specific Model in the CM
    /// - Parameters:
    ///   - model: Model to be inserted
    ///   - after: the specified Model
    public func insertSubmodel(_ model: Any, after: Any) {
        guard isValidModel(model) && isValidModel(after) else {
            return
        }
        p_modelArray.write {
            var itemIndex = -1
            for (index, item) in $0.enumerated() where (item as? NSObject) === (after as? NSObject) {
                itemIndex = index
                break
            }
            if itemIndex != -1 {
                if itemIndex < ($0.count - 1) {
                    $0.insert(model, at: itemIndex + 1)
                } else {
                    $0.append(model)
                }
            }
        }
    }
    
    /// Remove a specific Model
    /// - Parameter model: Model to be removed
    public func removeSubmodel(_ model: Any) {
        guard isValidModel(model) else {
            return
        }
        p_modelArray.write {
            var itemIndex = -1
            for (index, item) in $0.enumerated() where (item as? NSObject) === (model as? NSObject) {
                itemIndex = index
                break
            }
            if itemIndex != -1 {
                $0.remove(at: itemIndex)
            }
        }
    }
    
    /// Remove all Models in the CM
    public func removeAllSubmodels() {
        p_modelArray.write {
            $0.removeAll()
        }
    }
    
    /// Get the height of the current CM
    /// Caution: If the current CM includes a `DCBaseCellModel` with `isAutomaticDimension` set to true, the correct height can only be acquired after that Cell is displayed
    /// - Returns: height of the CM
    public func getContainerModelHeight() -> CGFloat {
        return p_modelArray.read {
            var height: CGFloat = 0
            if let model = topSeparator, !model.getIsHidden() {
                height += model.getCellHeight()
            }
            for item in $0 {
                if let model = item as? DCBaseCellModel, !model.getIsHidden() {
                    let cellHeight = model.getCellHeight()
                    height += cellHeight
                    if let topModel = model.topSeparator {
                        height += topModel.getCellHeight()
                    }
                    if let bottomModel = model.bottomSeparator {
                        height += bottomModel.getCellHeight()
                    }
                } else if let containerModel = item as? DCContainerModel, !containerModel.isHidden {
                    height += containerModel.getContainerModelHeight()
                    if let topModel = containerModel.topSeparator {
                        height += topModel.getCellHeight()
                    }
                    if let bottomModel = containerModel.bottomSeparator {
                        height += bottomModel.getCellHeight()
                    }
                }
            }
            if let model = bottomSeparator, !model.getIsHidden() {
                height += model.getCellHeight()
            }
            return height
        }
    }
    
    private func isValidModel(_ model: Any) -> Bool {
        if (model as AnyObject) === self {
            assert(false, "Cannot add self as submodel")
            return false
        }
        if (model is DCContainerModel) || (model is DCBaseCellModel) {
            return true
        }
        assert(false, "Model type error")
        return false
    }
    
    /// Called only once during a lifecycle and is called when calling `needReloadData()` or `needAnimateUpdate()` for the first time
    /// Initializations can be placed here
    open func cmDidLoad() {
        isContainerModelLoaded = true
        assert_containerModelDidLoad = false
        // override
    }
    
    /// Called whenever `needReloadData()` is called
    open func tableViewDataWillReload() {
        // override
    }
    
    /// Load the corresponding Cells in the CM with gradient
    final public func setGradientDisplay(_ isGradientDisplay: Bool) {
        p_modelArray.read {
            for item in $0 {
                if let cm = item as? DCContainerModel {
                    cm.setGradientDisplay(isGradientDisplay)
                } else if let vm = item as? DCBaseCellModel {
                    vm.isGradientDisplay = isGradientDisplay
                }
            }
        }
    }
    
    /// Only gradient display Cells for the first time
    final public func gradientDisplayFirst() {
        if isFirstGradientDisplay {
            return
        }
        isFirstGradientDisplay = true
        setGradientDisplay(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + DCDuration.Normal) {
            self.setGradientDisplay(false)
        }
    }
    
    // MARK: - DCEventHandleProtocol
    
    final public func needReloadData() {
        dcHandler?.needReloadData()
    }
    
    final public func needReloadData(indexPath: IndexPath?) {
        dcHandler?.needReloadData(indexPath: indexPath)
    }
    
    final public func needReloadDataAtOnce() {
        dcHandler?.needReloadDataAtOnce()
    }
    
    final public func needAnimateUpdate() {
        dcHandler?.needAnimateUpdate()
    }
    
    final public func needAnimateUpdate(with animation: UITableView.RowAnimation) {
        dcHandler?.needAnimateUpdate(with: animation)
    }
    
    final public func needAnimateUpdate(completion: @escaping () -> Void) {
        dcHandler?.needAnimateUpdate(completion: completion)
    }
    
    final public func needAnimateUpdate(with animation: UITableView.RowAnimation, completion: @escaping () -> Void) {
        dcHandler?.needAnimateUpdate(with: animation, completion: completion)
    }
    
    final public func scrollTo(offsetY: CGFloat) {
        dcHandler?.scrollTo(offsetY: offsetY)
    }
    
    final public func scrollTo(offsetY: CGFloat, animated: Bool) {
        dcHandler?.scrollTo(offsetY: offsetY, animated: animated)
    }
    
    final public func getVisibleCells() -> [DCBaseCell] {
        if let dcCells = dcHandler?.getVisibleCells() {
            return dcCells
        }
        return [DCBaseCell]()
    }
}

// MARK: - Handle Events and data

extension DCContainerModel {
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
