//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

/// Container TableView of DCFrame, used for loading ContainerModel
open class DCContainerTableView: UITableView {
    
    /// A tag for the current ContainerTableView
    public lazy var dc_tagName = ""
    
    /// EDC of the ContainerTableView, accepts events from all children CMs, cellModels, and Cells
    public private(set) lazy var eventDataController: DCEventDataController = {
        let eventDataController = DCEventDataController()
        eventDataController.tag = String(describing: Self.self)
        return eventDataController
    }()
    
    /// Current floating view
    public var currentHoverView: DCBaseCell? {
        return hoverViewsManager.currentHoverView
    }
    
    /// needReloadData access limit with a 0.05 second minimum interval between two calls
    public let refreshThrottler = DCThrottler(timeInterval: 0.05)
    
    /// Default color for the separator, determines the background color of `DCSeparatorCell`
    public var cellSeparatorColor: UIColor?
    
    /// Default height of the separator, determines the height of `DCSeparatorCell`
    public var cellSeparatorHeight: CGFloat?
    
    /// ContainerTableView doesn't have to conform to this protocol, used for passing through UITableView features
    public weak var dc_delegate: DCTableViewDelegate?
    
    public weak var dcHandler: DCBaseOperationProtocol?

    /// Assign the current `UIViewController` to this parrameter, and DCFrame would automatically sync it with CM and CellModel
    public weak var dcViewController: UIViewController?
    
    /// View list data, mainly used for storing CellModels linearly
    public var dataController: DCListDataController {
        return p_dataController.directValue
    }
    
    /// CM of the current ContainerTableView
    public private(set) var containerModel = DCContainerModel()
    public private(set) var isTableViewScrolling = false
    public private(set) var isAnimateUpdating = false
    public private(set) var isReloadingData = false
    
    private lazy var p_dataController = DCProtector<DCListDataController>(DCListDataController())
    private lazy var isNeedReloadData = false
    private lazy var isNeedReloadDataAtOnce = false
    private lazy var isNeedAnimateUpdate = false
    
    private lazy var hoverViewsManager = DCHoverViewManager()
    
    private lazy var animateUpdateLock: pthread_mutex_t = {
        var mutexLock = pthread_mutex_t()
        pthread_mutex_init(&mutexLock, nil)
        return mutexLock
    }()

    var assert_tableViewDataWillReload = false
    var assert_tableViewCellForRowing = false
    
    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    public init(frame: CGRect) {
        super.init(frame: frame, style: .plain)
        clipsToBounds = true
        
        delegate = self
        dataSource = self
        separatorStyle = .none
        
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
        
        hoverViewsManager.containerTableView = self
        
        subscribeEvent(DCBaseCell.dc_selectedCell) { [weak self] (data: Any?) in
            if let cellModel = data as? DCBaseCellModel {
                self?.shareData(cellModel, to: DCBaseCell.dc_currentSelectModel, broadcast: false)
            } else {
                self?.shareData(nil, to: DCBaseCell.dc_currentSelectModel, broadcast: false)
            }
        }
        
        initContainerModel()
    }
    
    /// Load ContainerModel
    /// - Parameter cm: ContainerModel to be loaded
    public func loadCM(_ cm: DCContainerModel) {
        containerModel = cm
        initContainerModel()
        needReloadData()
    }
    
    open func scrollViewDidEndScroll() {
        self.isTableViewScrolling = false
        
        if self.isNeedReloadData {
            self.isNeedReloadData = false
            self.needReloadData()
        }
        
        dc_delegate?.dc_scrollViewDidEndScroll?()
    }
    
    // MARK: - Private Functions
    
    private func initContainerModel() {
        containerModel.dcHandler = self
        containerModel.dcViewController = dcViewController
        containerModel.containerTableView = self
        
        if containerModel.eventDataController.parentEDC !== eventDataController {
            eventDataController.addChildEDC(containerModel.eventDataController)
        }
    }
    
    private func updateDataController() {
        if !containerModel.isContainerModelLoaded {
            containerModel.cmDidLoad()
            if containerModel.assert_containerModelDidLoad {
                assert(false, "super.cmDidLoad() has not been called")
            }
        }
        assert_tableViewDataWillReload = true
        containerModel.tableViewDataWillReload()
        assert_tableViewDataWillReload = false
        
        let tmpDataController = DCListDataController()
        setupDataController(tmpDataController, containerModel)
        
        pthread_mutex_lock(&animateUpdateLock)
        
        p_dataController.write {
            $0 = tmpDataController
        }
        
        pthread_mutex_unlock(&animateUpdateLock)
    }
    
    private func setupDataController(_ dataController: DCListDataController, _ parentCM: DCContainerModel) {
        func addCellModel(_ model: DCBaseCellModel) {
            if let topSeparator = model.topSeparator, !model.getIsHidden() {
                addCellModel(topSeparator)
            }
            model.containerModel = parentCM
            model.dcHandler = parentCM
            model.eventDataController = parentCM.eventDataController
            if !model.getIsHidden() {
                dataController.addObject(model)
            }
            if let bottomSeparator = model.bottomSeparator, !model.getIsHidden() {
                addCellModel(bottomSeparator)
            }
        }
        
        func addContainerModel(_ cm: DCContainerModel) {
            cm.dcViewController = dcViewController
            cm.containerTableView = self
            cm.dcHandler = parentCM
            if cm.eventDataController.parentEDC !== parentCM.eventDataController {
                parentCM.eventDataController.addChildEDC(cm.eventDataController)
            }
            
            if !cm.isContainerModelLoaded {
                cm.cmDidLoad()
                if cm.assert_containerModelDidLoad {
                    assert(false, "super.cmDidLoad() has not been called")
                }
            }
            assert_tableViewDataWillReload = true
            cm.tableViewDataWillReload()
            assert_tableViewDataWillReload = false
            if !cm.isHidden {
                setupDataController(dataController, cm)
            }
        }
        
        if !parentCM.isHidden, let topSeparator = parentCM.topSeparator {
            addCellModel(topSeparator)
        }
        
        for item in parentCM.modelArray {
            if let model = item as? DCBaseCellModel {
                addCellModel(model)
            } else if let cm = item as? DCContainerModel {
                addContainerModel(cm)
            }
        }
        
        if !parentCM.isHidden, let bottomSeparator = parentCM.bottomSeparator {
            addCellModel(bottomSeparator)
        }
    }
    
    private func getCellModel(_ indexPath: IndexPath?) -> DCBaseCellModel? {
        guard let indexPath = indexPath, let baseCellModel = p_dataController.directValue.objectAtIndexPath(indexPath) as? DCBaseCellModel else {
            return nil
        }
        return baseCellModel
    }
    
    private func throttleExecuteReloadData() {
        // To avoid repeatedly calling needReloadData and optimize scrolling performance
        if isReloadingData || isTableViewScrolling || isAnimateUpdating {
            isNeedReloadData = true
            return
        }
        isReloadingData = true
        
        func p_reloadData() {
            tableViewReloadData()
            isReloadingData = false
            if isNeedReloadData {
                isNeedReloadData = false
                needReloadData()
            }
        }
        
        if Thread.isMainThread {
            p_reloadData()
        } else {
            DispatchQueue.main.async {
                p_reloadData()
            }
        }
    }
    
    private func reloadDataWithIndexPath(_ indexPath: IndexPath) {
        if let baseCellModel = getCellModel(indexPath), let dcCell = baseCellModel.dcCell, dcCell.baseCellModel == baseCellModel {
            dcCell.cellModelDidUpdate()
        }
        for dcCell in hoverViewsManager.currentAlwaysHoverViews where dcCell.baseCellModel.indexPath == indexPath {
            dcCell.cellModelDidUpdate()
        }
        if let dcCell = hoverViewsManager.currentHoverView, dcCell.baseCellModel.indexPath == indexPath {
            dcCell.cellModelDidUpdate()
        }
    }
    
    private func tableViewReloadData() {
        updateDataController()
        dc_delegate?.dc_tableViewDataWillReload?(self)
        
        reloadData()
        
        hoverViewsManager.updateHoverDCViews()
        dc_delegate?.dc_tableViewDataDidReload?(self)
    }
    
    private func animateDiffRows() -> (deletes: [IndexPath], inserts: [IndexPath], moves: [(from: IndexPath, to: IndexPath)]) {
        var deletes = [IndexPath]()
        var inserts = [IndexPath]()
        
        let newDataController = DCListDataController()
        setupDataController(newDataController, containerModel)
        
        var newModelSet = Set<DCBaseCellModel>()
        newDataController.forEach { (model: DCBaseCellModel, indexPath: IndexPath) in
            newModelSet.insert(model)
        }
        
        var oldModelDict = Dictionary<DCBaseCellModel, IndexPath>()
        p_dataController.read {
            $0.forEach { (model: DCBaseCellModel, indexPath: IndexPath) in
                if !newModelSet.contains(model) {
                    deletes.append(indexPath)
                }
                oldModelDict[model] = indexPath
            }
        }
        
        var moves = [(IndexPath, IndexPath)]()
        newDataController.forEach { (model: DCBaseCellModel, newIndexPath: IndexPath) in
            if let oldIndexPath = oldModelDict[model] {
                if oldIndexPath != newIndexPath {
                    moves.append((oldIndexPath, newIndexPath))
                }
            } else {
                inserts.append(newIndexPath)
            }
        }
        
        p_dataController.write {
            $0 = newDataController
        }
        
        return (deletes, inserts, moves)
    }
    
    private func getCell(_ indexPath: IndexPath) -> UITableViewCell {
        guard let model = getCellModel(indexPath), let cellClass = model.getCellClass() as? UITableViewCell.Type else {
            assert(false, "cellClass is not of type UITableViewCell")
            return UITableViewCell()
        }
        guard let cell = dequeueReusableCell(withIdentifier: model.reuseIdentifier) else {
            if model.isXibCell {
                register(UINib(nibName: String(describing: cellClass), bundle: model.xibBundle), forCellReuseIdentifier: model.reuseIdentifier)
                if let cell = dequeueReusableCell(withIdentifier: model.reuseIdentifier) {
                    return cell
                }
                if let cell = model.xibBundle.loadNibNamed(String(describing: cellClass), owner: self)?.first as? UITableViewCell {
                    return cell
                } else {
                    assert(false, "xibCell fails to load")
                    return UITableViewCell()
                }
            } else {
                return cellClass.init(style: .default, reuseIdentifier: model.reuseIdentifier)
            }
        }
        return cell
    }
    
    internal func updateCell(_ dcCell: DCBaseCell, _ baseCellModel: DCBaseCellModel, isHoverTop: Bool = false) {
        dcCell.dcViewController = dcViewController
        dcCell.containerTableView = self
        dcCell.dcHandler = baseCellModel.dcHandler
        dcCell.baseCellModel = baseCellModel
        
        if !isHoverTop {
            baseCellModel.dcCell = dcCell
        }
        
        // Boolean for determining if DCBaseCell is updated for the first time. If updated, it will not update again for better scrolling performance.
        var isFirstUpdated = false
        
        if !baseCellModel.isCellModelLoaded {
            baseCellModel.cellModelDidLoad()
            if baseCellModel.assert_cellModelDidLoad {
                assert(false, "super.cellModelDidLoad() has not been called")
            }
            dcCell.cellModelDidLoad()
            if dcCell.assert_cellModelDidLoad {
                assert(false, "super.cellModelDidLoad() has not been called")
            }
            isFirstUpdated = true
        } else if dcCell.isNeedReCreated {
            baseCellModel.cellReCreated()
            dcCell.cellModelDidLoad()
            if dcCell.assert_cellModelDidLoad {
                assert(false, "super.cellModelDidLoad() has not been called")
            }
            isFirstUpdated = true
        }
        
        // If view is not reused when scrolling, do not refresh for better scrolling performance
        if isFirstUpdated || !(isTableViewScrolling && baseCellModel.isUniqueIdentifier) {
            dcCell.cellModelDidUpdate()
            if dcCell.assert_cellModelDidUpdate {
                assert(false, "super.cellModelDidUpdate() has not been called")
            }
        }
    }
    
    deinit {
        delegate = nil
        dataSource = nil
        pthread_mutex_destroy(&animateUpdateLock)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DCContainerTableView: DCBaseOperationProtocol {
    /// Call this function to reload view if Model data changes in CM
    final public func needReloadData() {
        if assert_tableViewDataWillReload {
            assert(false, "Recursive call occurred, calling needReloadData() in tableViewDataWillReload() is prohibited")
        }
        if assert_tableViewCellForRowing {
            assert(false, "Synchronously calling needReloadData() in cellModelDidLoad() or cellModelDidUpdate() is prohibited")
        }
        refreshThrottler.execute("needReloadData") { [weak self] in
            self?.throttleExecuteReloadData()
        }
    }
    
    /// Call this function to reload Cell with a specific indexPath
    /// - Parameter indexPath: IndexPath of the Cell in its ContainerTableView
    final public func needReloadData(indexPath: IndexPath?) {
        guard let indexPath = indexPath else {
            return
        }
        if Thread.isMainThread {
            reloadDataWithIndexPath(indexPath)
        } else {
            DispatchQueue.main.async {
                self.reloadDataWithIndexPath(indexPath)
            }
        }
    }
    
    /// Same as needReloadData() without the 0.05 second time interval limit
    final public func needReloadDataAtOnce() {
        if assert_tableViewDataWillReload {
            assert(false, "Recursive call occurred, calling needReloadDataAtOnce() in tableViewDataWillReload() is prohibited")
        }
        if assert_tableViewCellForRowing {
            assert(false, "Synchronously calling needReloadDataAtOnce() in cellModelDidLoad() or cellModelDidUpdate() is prohibited")
        }
        if isAnimateUpdating {
            isNeedReloadDataAtOnce = true
            return
        }
        
        if Thread.isMainThread && (!isTableViewScrolling)  {
            tableViewReloadData()
        } else {
            DispatchQueue.main.async {
                self.tableViewReloadData()
            }
        }
    }
    
    /// Animated update on the current view when CM changes, call this function to reload view with automatic diff
    final public func needAnimateUpdate() {
        needAnimateUpdate(completion: {
            // do nothing
        })
    }
    
    final public func needAnimateUpdate(with animation: UITableView.RowAnimation) {
        needAnimateUpdate(with: animation) {
            // do nothing
        }
    }
    
    final public func needAnimateUpdate(completion: @escaping () -> Void) {
        needAnimateUpdate(with: .fade, completion: completion)
    }
    
    final public func needAnimateUpdate(with animation: UITableView.RowAnimation, completion: @escaping () -> Void) {
        if isReloadingData || isAnimateUpdating {
            isNeedAnimateUpdate = true
            return
        }
        isAnimateUpdating = true
        
        dc_delegate?.dc_beginAnimateUpdate?(self)
        dc_delegate?.dc_tableViewDataWillReload?(self)
        
        // To avoid CATransaction callback not executing and isAnimateUpdating not recovering
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            endAnimateUpdate()
        }
        
        func endAnimateUpdate() {
            guard isAnimateUpdating else {
                return
            }
            isAnimateUpdating = false
            if isNeedAnimateUpdate {
                isNeedAnimateUpdate = false
                needAnimateUpdate(with: animation, completion: completion)
            }
            if isNeedReloadData {
                isNeedReloadData = false
                needReloadData()
            }
            if isNeedReloadDataAtOnce {
                isNeedReloadDataAtOnce = false
                needReloadDataAtOnce()
            }
            completion()
            dc_delegate?.dc_endAnimateUpdate?(self)
            dc_delegate?.dc_tableViewDataDidReload?(self)
        }
        
        func animateUpdate() {
            for view in getVisibleCells() where view.isHidden {
                view.cellModelDidUpdate()
            }
  
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                endAnimateUpdate()
            })
            
            pthread_mutex_lock(&animateUpdateLock)
            beginUpdates()
            
            let diffs = animateDiffRows()
            
            if diffs.deletes.count > 0 {
                deleteRows(at: diffs.deletes, with: animation)
            }
            if diffs.inserts.count > 0 {
                insertRows(at: diffs.inserts, with: animation)
            }
            diffs.moves.forEach {
                moveRow(at: $0.from, to: $0.to)
            }
            
            endUpdates()
            pthread_mutex_unlock(&animateUpdateLock)
            
            CATransaction.commit()
            
            hoverViewsManager.updateHoverDCViews()
        }
        
        if Thread.isMainThread {
            animateUpdate()
        } else {
            DispatchQueue.main.async {
                animateUpdate()
            }
        }
    }

    final public func getVisibleCells() -> [DCBaseCell] {
        var dcCells = [DCBaseCell]()
        for cell in visibleCells {
            if let dcCell = cell as? DCBaseCell {
                dcCells.append(dcCell)
            }
        }
        if let hoverView = hoverViewsManager.currentHoverView {
            dcCells.append(hoverView)
        }
        for dcCell in hoverViewsManager.currentAlwaysHoverViews where !dcCell.isHidden {
            dcCells.append(dcCell)
        }
        return dcCells
    }
    
    final public func scrollTo(offsetY: CGFloat) {
        scrollTo(offsetY: offsetY, animated: true)
    }
    
    final public func scrollTo(offsetY: CGFloat, animated: Bool) {
        setContentOffset(CGPoint(x: 0, y: offsetY), animated: animated)
    }
}

extension DCContainerTableView: UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return p_dataController.directValue.objects.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let spacer = dc_delegate?.dc_tableView?(tableView, cellForRowAt: indexPath) {
            return spacer
        }
        
        let cell = getCell(indexPath)
        if let dcCell = cell as? DCBaseCell, let baseCellModel = getCellModel(indexPath) {
            assert_tableViewCellForRowing = true
            updateCell(dcCell, baseCellModel)
            assert_tableViewCellForRowing = false
        }
        return cell
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let baseCellModel = getCellModel(indexPath) {
            baseCellModel.indexPath = indexPath
            let cellHeight = baseCellModel.getCellHeight()
            if cellHeight < 0 {
                assert(false, "cellHeight cannot be smaller than zero")
            }
            if cellHeight > CGFloat.ulpOfOne {
                return cellHeight
            } else if baseCellModel.isAutomaticDimension {
                return UITableView.automaticDimension
            }
        }
        return 0
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let baseCellModel = getCellModel(indexPath), baseCellModel.isAutomaticDimension, baseCellModel.getCellHeight() <= CGFloat.ulpOfOne {
            baseCellModel.cellHeight = cell.dc_height
        }
        if let dcCell = cell as? DCBaseCell {
            dcCell.willDisplay()
        }
        dc_delegate?.dc_tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let dcCell = cell as? DCBaseCell {
            dcCell.didEndDisplaying()
        }
        dc_delegate?.dc_tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if let shouldHighlight = dc_delegate?.dc_tableView?(tableView, shouldHighlightRowAt: indexPath) {
            return shouldHighlight
        }
        return true
    }
    
    open func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        dc_delegate?.dc_tableView?(tableView, didHighlightRowAt: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        dc_delegate?.dc_tableView?(tableView, didUnhighlightRowAt: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let baseCellModel = getCellModel(indexPath), let dcCell = baseCellModel.dcCell {
            dcCell.didSelect()
            if dcCell.assert_didSelect {
                assert(false, "super.didSelect() has not been called")
            }
            dc_delegate?.dc_didSelectedCellModel?(baseCellModel)
        }
        dc_delegate?.dc_tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        dc_delegate?.dc_tableView?(tableView, didDeselectRowAt: indexPath)
    }
    
    // MARK: - UIScrollViewDelegate
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hoverViewsManager.handleHoverViews()
        
        if scrollView.isDragging || scrollView.isDecelerating {
            self.isTableViewScrolling = true
        }
        
        // Pass the scrolling state to the DCBaseCell on the screen
        for view in getVisibleCells() {
            view.didScrollingInScreen(scrollView)
        }
        
        dc_delegate?.dc_scrollViewDidScroll?(scrollView)
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dc_delegate?.dc_scrollViewWillBeginDragging?(scrollView)
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidEndScroll()
        }
        dc_delegate?.dc_scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        dc_delegate?.dc_scrollViewWillBeginDecelerating?(scrollView)
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidEndScroll()
        dc_delegate?.dc_scrollViewDidEndDecelerating?(scrollView)
    }
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        dc_delegate?.dc_scrollViewDidEndScrollingAnimation?(scrollView)
    }
    
    open func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        if let shouldScrollToTop = dc_delegate?.dc_scrollViewShouldScrollToTop?(scrollView) {
            return shouldScrollToTop
        }
        return scrollsToTop
    }
    
    open func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        dc_delegate?.dc_scrollViewDidScrollToTop?(scrollView)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let value = dc_delegate?.dc_gestureRecognizer?(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) {
            return value
        }
        return false
    }
}

extension DCContainerTableView {
    // MARK: - Handle Data and Events
    
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
