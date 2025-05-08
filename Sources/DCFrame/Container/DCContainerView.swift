//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import UIKit

/// Container CollectionView, used for loading ContainerModel
public class DCContainerView: UICollectionView {

    /// A tag for the current DCContainerView
    public lazy var tagName = ""

    /// EDC of the DCContainerView, accepts events from all children ContainerModels, cellModels, and Cells
    public private(set) lazy var eventDataController: DCEventDataController = {
        let eventDataController = DCEventDataController()
        eventDataController.tag = String(describing: Self.self)
        return eventDataController
    }()

    /// Default color for the `DCSeparatorCell`
    public var cellSeparatorColor: UIColor?

    /// Default height of the `DCSeparatorCell`
    public var cellSeparatorHeight: CGFloat?

    /// Default selected color for the `DCCell`
    public var cellSelectedColor: UIColor?

    /// Default background color for the `DCCell`
    public var cellBackgroundColor: UIColor?

    /// Set hoverView offset
    public var hoverViewOffset: CGFloat?

    /// The scroll direction of the CollectionView
    public var scrollDirection: UICollectionView.ScrollDirection = .vertical

    /// DCContainerView doesn't have to conform to this protocol, used for passing through UICollectionView features
    public weak var dcDelegate: DCContainerViewDelegate?

    /// Assign the current `UIViewController` to this parrameter, and DCContainerView would automatically sync it with ContainerModel and CellModel
    public weak var dcViewController: UIViewController?

    /// View list data, mainly used for storing CellModels linearly
    public var dataController: DCContainerViewDataController {
        return p_dataController.directValue
    }

    /// ContainerModel of the current DCContainerView
    public private(set) var containerModel = DCContainerModel()
    public private(set) var isCollectionViewScrolling = false
    
    private(set) var layoutContainerModel = DCContainerModel()
    private(set) var indexPathsToDeleteForSupplementaryView = [IndexPath]()
    private(set) var indexPathsToInsertForSupplementaryView = [IndexPath]()

    private var p_dataController = DCProtector<DCContainerViewDataController>(DCContainerViewDataController())

    private var layoutThrottler = DCThrottler(timeInterval: 0.05)
    private let lock = DCContainerViewAroundLock()

    #if DEBUG
    var assert_collectionViewDataWillReload = false
    var assert_collectionViewCellForRowing = false
    #endif

    public convenience init() {
        self.init(frame: CGRect.zero)
    }

    public convenience init(frame: CGRect) {
        self.init(frame: frame, collectionViewLayout: nil)
    }

    private override init(frame: CGRect, collectionViewLayout: UICollectionViewLayout? = nil) {
        super.init(frame: frame, collectionViewLayout: DCContainerViewLayout())

        backgroundColor = .white
        clipsToBounds = true
        alwaysBounceVertical = true
        delegate = self
        dataSource = self
        contentInsetAdjustmentBehavior = .never

        initContainerModel(containerModel, parentModel: nil)
    }

    /// Load ContainerModel
    /// - Parameter containerModel: ContainerModel to be loaded
    public func loadContainerModel(_ containerModel: DCContainerModel) {
        #if DEBUG
        if assert_collectionViewCellForRowing {
            assert(false, "Synchronously calling loadContainerModel() in cellDidLoad() or cellModelDidUpdate() is prohibited")
        }
        #endif
        self.containerModel = containerModel
        DCThrottler.executeInMainThread {
            self.collectionViewReloadData()
        }
    }

    open func scrollViewDidEndScroll() {
        self.isCollectionViewScrolling = false

        dcDelegate?.dcScrollViewDidEndScroll?()
    }

    // MARK: - Private Functions

    private func initContainerModel(_ model: DCContainerModel, parentModel: DCContainerModel?) {
        assert(model.dcViewController == nil || model.dcViewController === dcViewController, "Ensure that the dcViewController parameter is not used in containerModelDidLoad()")
        model.dcViewController = dcViewController

        assert(model.dcContainerView == nil || model.dcContainerView === self, "Ensure that the dcContainerView parameter is not used in containerModelDidLoad()")
        model.dcContainerView = self

        assert(model.containerViewHandler == nil || model.containerViewHandler === self, "Ensure that the containerViewHandler parameter is not used in containerModelDidLoad()")
        model.containerViewHandler = self

        assert(model.parentContainerModel == nil || model.parentContainerModel === parentModel, "Ensure that the parentContainerModel parameter is not used in containerModelDidLoad()")
        model.parentContainerModel = parentModel

        var tmpEventDataController = eventDataController
        if let edc = parentModel?.eventDataController {
            tmpEventDataController = edc
        }

        assert(model.eventDataController.parentEDC == nil || model.eventDataController.parentEDC === tmpEventDataController, "Ensure that the eventDataController parameter is not used in containerModelDidLoad()")
        if model.eventDataController.parentEDC !== tmpEventDataController {
            tmpEventDataController.addChildEDC(model.eventDataController)
        }


        if !model.isContainerModelLoaded {
            model.containerModelDidLoad()

            #if DEBUG
            if model.assert_containerModelDidLoad {
                assert(false, "super.containerModelDidLoad() has not been called")
            }
            #endif
        }
    }

    private func updateDataController() {
        initContainerModel(containerModel, parentModel: nil)

        #if DEBUG
        assert_collectionViewDataWillReload = true
        #endif

        containerModel.collectionViewDataWillReload()

        #if DEBUG
        assert_collectionViewDataWillReload = false
        #endif

        let tmpDataController = getDataController(containerModel)

        lock.around {
            p_dataController.write {
                $0 = tmpDataController
            }
        }
    }
    
    private func getDataController(_ currentContainerModel: DCContainerModel) -> DCContainerViewDataController {
        let dataController = DCContainerViewDataController()
        let layoutCM = handleDataController(dataController, currentContainerModel)
        layoutContainerModel = layoutCM
        indexPathsToDeleteForSupplementaryView = [IndexPath]()
        indexPathsToInsertForSupplementaryView = [IndexPath]()
        
        return dataController
    }
    
    private func handleDataController(_ dataController: DCContainerViewDataController, _ currentContainerModel: DCContainerModel) -> DCContainerModel {
        let layoutCM = DCContainerModel()
        layoutCM.customLayout = currentContainerModel.customLayout
        layoutCM.layoutContext = currentContainerModel.layoutContext

        func addCellModel(_ model: DCCellModel) {
            model.dcContainerModel = currentContainerModel
            model.containerViewHandler = self
            model.eventDataController = currentContainerModel.eventDataController

            if !model.getIsHidden() {
                model.indexPath = IndexPath.init(item: dataController.objects.count, section: 0)
                dataController.addObject(model)
                layoutCM.addSubModel(model)
            }

            if let cellClass = model.getCellClass() as? UICollectionViewCell.Type {
                register(cellClass, forCellWithReuseIdentifier: model.reuseIdentifier)
                if model.getIsHoverTop() {
                    model.hoverIndexPath = IndexPath.init(item: dataController.hoverObjects.count, section: 0)
                    dataController.hoverObjects.append(model)
                    register(cellClass, forSupplementaryViewOfKind: DCContainerView.elementKindHoverTop, withReuseIdentifier: model.reuseIdentifier)
                }
            } else {
                assert(false, "cellClass is not of type UICollectionViewCell")
            }
        }

        func addContainerModel(_ childContainerModel: DCContainerModel) {
            initContainerModel(childContainerModel, parentModel: currentContainerModel)

            #if DEBUG
            assert_collectionViewDataWillReload = true
            #endif

            childContainerModel.collectionViewDataWillReload()

            #if DEBUG
            assert_collectionViewDataWillReload = false
            #endif

            if !childContainerModel.isHidden {
                let childLayoutCM = handleDataController(dataController, childContainerModel)
                layoutCM.addSubModel(childLayoutCM)
                childLayoutCM.parentContainerModel = layoutCM
            }
        }

        for item in currentContainerModel.modelArray {
            if let model = item as? DCCellModel {
                addCellModel(model)
            } else if let containerModel = item as? DCContainerModel {
                addContainerModel(containerModel)
            }
        }
        
        return layoutCM
    }

    private func getCellModel(_ indexPath: IndexPath?) -> DCCellModel? {
        guard let indexPath = indexPath, let baseCellModel = p_dataController.directValue.objectAtIndexPath(indexPath) else {
            return nil
        }
        return baseCellModel
    }

    private func collectionViewReloadData() {
        updateDataController()

        dcDelegate?.dcContainerViewWillUpdate?(self)
        reloadData()
        dcDelegate?.dcContainerViewDidUpdate?(self)
    }

    private func animateDiffRows() -> (deletes: [IndexPath], inserts: [IndexPath], moves: [(from: IndexPath, to: IndexPath)]) {
        var deletes = [IndexPath]()
        var inserts = [IndexPath]()

        let newDataController = getDataController(containerModel)

        var newModelSet = Set<DCCellModel>()
        newDataController.forEach { (model: DCCellModel, _: IndexPath) in
            newModelSet.insert(model)
        }

        var oldModelDict = [DCCellModel: IndexPath]()
        var oldHoverModelDic = [DCCellModel: IndexPath]()
        p_dataController.read {
            $0.forEach { (model: DCCellModel, indexPath: IndexPath) in
                if !newModelSet.contains(model) {
                    deletes.append(indexPath)
                }
                oldModelDict[model] = indexPath
            }
            
            for (itemIndex, model) in $0.hoverObjects.enumerated() {
                let hoverIndexPath = IndexPath(item: itemIndex, section: 0)
                if !newModelSet.contains(model) {
                    indexPathsToDeleteForSupplementaryView.append(hoverIndexPath)
                }
                oldHoverModelDic[model] = hoverIndexPath
            }
        }

        var moves = [(IndexPath, IndexPath)]()
        newDataController.forEach { (model: DCCellModel, newIndexPath: IndexPath) in
            if let oldIndexPath = oldModelDict[model] {
                if oldIndexPath != newIndexPath {
                    moves.append((oldIndexPath, newIndexPath))
                }
            } else {
                inserts.append(newIndexPath)
            }
            
            if model.getIsHoverTop(), let newHoverIndexPath = model.hoverIndexPath {
                if let oldHoverIndexPath = oldHoverModelDic[model] {
                    if oldHoverIndexPath != newHoverIndexPath {
                        indexPathsToDeleteForSupplementaryView.append(oldHoverIndexPath)
                        indexPathsToInsertForSupplementaryView.append(newHoverIndexPath)
                    }
                } else {
                    indexPathsToInsertForSupplementaryView.append(newHoverIndexPath)
                }
            }
        }

        p_dataController.write {
            $0 = newDataController
        }

        return (deletes, inserts, moves)
    }

    private func getCell(_ indexPath: IndexPath) -> UICollectionViewCell {
        guard let model = getCellModel(indexPath) else {
            assert(false, "`getCellModel` function returned nil")
            register(UICollectionViewCell.self, forCellWithReuseIdentifier: "error_cell")
            return dequeueReusableCell(withReuseIdentifier: "error_cell", for: indexPath)
        }

        return dequeueReusableCell(withReuseIdentifier: model.reuseIdentifier, for: indexPath)
    }

    func updateCell(_ dcCell: DCBaseCell, _ baseCellModel: DCCellModel, isHoverTop: Bool = false) {
        let isReusing = dcCell.isCellModelDidLoad && dcCell.baseCellModel !== baseCellModel
        
        dcCell.dcViewController = dcViewController
        dcCell.dcContainerView = self
        dcCell.containerViewHandler = baseCellModel.containerViewHandler
        dcCell.baseCellModel = baseCellModel

        if !isHoverTop {
            baseCellModel.dcCell = dcCell
        }

        if !baseCellModel.isCellModelLoaded || dcCell.isNeedReCreated || isReusing {
            if !baseCellModel.isCellModelLoaded {
                
                baseCellModel.cellModelDidLoad()
                #if DEBUG
                if baseCellModel.assert_cellModelDidLoad {
                    assert(false, "super.cellModelDidLoad() has not been called")
                }
                #endif
                
                dcCell.cellModelDidLoad()
                #if DEBUG
                if dcCell.assert_cellModelDidLoad {
                    assert(false, "super.cellModelDidLoad() has not been called")
                }
                #endif
            } else if dcCell.isNeedReCreated {
                dcCell.cellModelDidLoad()
                #if DEBUG
                if dcCell.assert_cellModelDidLoad {
                    assert(false, "super.cellModelDidLoad() has not been called")
                }
                #endif
            }

            dcCell.cellModelDidUpdate()

            #if DEBUG
            if dcCell.assert_cellModelDidUpdate {
                assert(false, "super.cellModelDidUpdate() has not been called")
            }
            #endif
        }
    }

    deinit {
        delegate = nil
        dataSource = nil
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DCContainerView: DCBaseOperationDelegate {

    /// Animated update on the current view when ContainerModel changes, call this function to reload view with automatic diff
    final public func needUpdateLayout() {
        layoutThrottler.execute("needUpdateLayout") { [weak self] in
            guard let self = self else { return }
            DCThrottler.executeInMainThread {
                UIView.performWithoutAnimation {
                    self.needUpdateLayoutAnimated()
                }
            }
        }
    }

    final public func needUpdateLayoutAnimated() {
        needUpdateLayoutAnimated(completion: {
            // do nothing
        })
    }

    final public func needUpdateLayoutAnimated(completion: @escaping () -> Void) {
        #if DEBUG
        if assert_collectionViewCellForRowing {
            assert(false, "Synchronously calling needUpdateLayoutAnimated() in cellDidLoad() or cellModelDidUpdate() is prohibited")
        }
        #endif

        dcDelegate?.dcBeginAnimateUpdate?(self)
        dcDelegate?.dcContainerViewWillUpdate?(self)

        func endAnimateUpdate() {
            completion()
            dcDelegate?.dcEndAnimateUpdate?(self)
            dcDelegate?.dcContainerViewDidUpdate?(self)
        }

        func animateUpdate() {
            lock.around {
                performBatchUpdates { [weak self] in
                    guard let self = self else {
                        return
                    }
                    let diffs = animateDiffRows()
                    if diffs.deletes.count > 0 {
                        self.deleteItems(at: diffs.deletes)
                    }
                    if diffs.inserts.count > 0 {
                        self.insertItems(at: diffs.inserts)
                    }
                    diffs.moves.forEach {
                        self.moveItem(at: $0.from, to: $0.to)
                    }
                } completion: { _ in
                    endAnimateUpdate()
                }
            }
        }

        DCThrottler.executeInMainThread {
            animateUpdate()
        }
    }

    final public func getVisibleCells() -> [DCBaseCell] {
        var dcCells = [DCBaseCell]()
        for cell in visibleCells {
            if let dcCell = cell as? DCBaseCell {
                dcCells.append(dcCell)
            }
        }
        
        for cell in visibleSupplementaryViews(ofKind: DCContainerView.elementKindHoverTop) {
            if let dcCell = cell as? DCBaseCell {
                dcCells.append(dcCell)
            }
        }

        return dcCells
    }

    final public func scrollTo(_ offsetPoint: CGPoint) {
        scrollTo(offsetPoint, animated: true)
    }

    final public func scrollTo(_ offsetPoint: CGPoint, animated: Bool) {
        if scrollDirection == .vertical {
            setContentOffset(CGPoint(x: 0, y: offsetPoint.y), animated: animated)
        } else {
            setContentOffset(CGPoint(x: offsetPoint.x, y: 0), animated: animated)
        }
    }
}

extension DCContainerView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return p_dataController.directValue.objects.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == DCContainerView.elementKindHoverTop else {
            assert(false, "`viewForSupplementaryElementOfKind` is wrong")
            register(UICollectionReusableView.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: "error_cell")
            return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "error_cell", for: indexPath)
        }
        
        guard let model = p_dataController.directValue.hoverObjects[dc_safe: indexPath.item] else {
            assert(false, "hoverCellModel returned nil")
            register(UICollectionReusableView.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: "error_cell")
            return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "error_cell", for: indexPath)
        }
        
        let cell = dequeueReusableSupplementaryView(ofKind: DCContainerView.elementKindHoverTop, withReuseIdentifier: model.reuseIdentifier, for: indexPath)
        if let dcCell = cell as? DCBaseCell {
        #if DEBUG
            assert_collectionViewCellForRowing = true
        #endif
            
            updateCell(dcCell, model)
            
        #if DEBUG
            assert_collectionViewCellForRowing = false
        #endif
        }
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let spacer = dcDelegate?.dcContainerView?(collectionView, cellForRowAt: indexPath) {
            return spacer
        }

        let cell = getCell(indexPath)
        if let dcCell = cell as? DCBaseCell, let baseCellModel = getCellModel(indexPath) {
            #if DEBUG
            assert_collectionViewCellForRowing = true
            #endif

            updateCell(dcCell, baseCellModel, isHoverTop: baseCellModel.getIsHoverTop())

            #if DEBUG
            assert_collectionViewCellForRowing = false
            #endif
        }
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let baseCellModel = getCellModel(indexPath) {
            return baseCellModel.getCellSize(collectionViewWidth: collectionView.frame.size.width)
        }
        return .zero
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let dcCell = cell as? DCBaseCell {
            dcCell.willDisplay()
        }
        dcDelegate?.dcContainerView?(collectionView, willDisplay: cell, forRowAt: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let dcCell = cell as? DCBaseCell {
            dcCell.didEndDisplaying()
        }
        dcDelegate?.dcContainerView?(collectionView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        guard elementKind == DCContainerView.elementKindHoverTop, let dcCell = view as? DCBaseCell else { return }
        
        dcCell.willDisplay()
        dcDelegate?.dcContainerView?(collectionView, willDisplay: dcCell, forRowAt: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        guard elementKind == DCContainerView.elementKindHoverTop, let dcCell = view as? DCBaseCell else { return }
        
        dcCell.didEndDisplaying()
        dcDelegate?.dcContainerView?(collectionView, didEndDisplaying: dcCell, forRowAt: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return dcDelegate?.dcContainerView?(collectionView, shouldHighlightRowAt: indexPath) ?? true
    }

    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        dcDelegate?.dcContainerView?(collectionView, didHighlightRowAt: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        dcDelegate?.dcContainerView?(collectionView, didUnhighlightRowAt: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let baseCellModel = getCellModel(indexPath), let dcCell = baseCellModel.dcCell {
            dcCell.didSelect()

            #if DEBUG
            if dcCell.assert_didSelect {
                assert(false, "super.didSelect() has not been called")
            }
            #endif

            dcDelegate?.dcDidSelectedCellModel?(baseCellModel)
        }
        dcDelegate?.dcContainerView?(collectionView, didSelectRowAt: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        dcDelegate?.dcContainerView?(collectionView, didDeselectRowAt: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return dcDelegate?.dcContainerView?(collectionView, canMoveItemAt: indexPath) ?? false
    }

    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        dcDelegate?.dcContainerView?(collectionView, moveItemAt: sourceIndexPath, to: destinationIndexPath)
    }

    // MARK: - UIScrollViewDelegate

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging || scrollView.isDecelerating {
            self.isCollectionViewScrolling = true
        }

        dcDelegate?.dcScrollViewDidScroll?(scrollView)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dcDelegate?.dcScrollViewWillBeginDragging?(scrollView)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidEndScroll()
        }
        dcDelegate?.dcScrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }

    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        dcDelegate?.dcScrollViewWillBeginDecelerating?(scrollView)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidEndScroll()
        dcDelegate?.dcScrollViewDidEndDecelerating?(scrollView)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        dcDelegate?.dcScrollViewDidEndScrollingAnimation?(scrollView)
    }

    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        if let shouldScrollToTop = dcDelegate?.dcScrollViewShouldScrollToTop?(scrollView) {
            return shouldScrollToTop
        }
        return scrollsToTop
    }

    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        dcDelegate?.dcScrollViewDidScrollToTop?(scrollView)
    }

    // MARK: - UIGestureRecognizerDelegate

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let value = dcDelegate?.dcGestureRecognizer?(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) {
            return value
        }
        return false
    }
}

extension DCContainerView {
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

extension DCContainerView {
    public static let elementKindHoverTop: String = "DCContainerViewElementKindHoverTop"
}
