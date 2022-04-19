//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation

public typealias DCSharedDataCallbackBlock = (() -> Any?)

final public class DCEventDataController: NSObject {
    /// Tag the EDC for testing purposes
    public var tag = ""

    /// Parent EDC of the current node
    public private(set) var parentEDC: DCEventDataController? {
        set {
            p_parentEDC.write {
                $0.value = newValue
            }
        }
        get {
            return p_parentEDC.directValue.value
        }
    }
    private var p_parentEDC = DCProtector<EDCWeakEventDataController>(EDCWeakEventDataController())

    private var childsEDCList = DCProtector<[EDCChildItem]>([EDCChildItem]())
    private var dataDict = DCProtector<[Int64: Any]>([Int64: Any]())

    private var subscribeDataDict = EDCEventDataDict()
    private var subscribeEventDict = EDCEventDataDict()

    private var handleChildEDCQueue = DispatchQueue(label: "com.dcframe.DCEventDataController.handleChildEDCQueue", qos: .default)

    /// Root EDC node for the event data response chain
    public var rootEDC: DCEventDataController {
        var nowEDC = self
        while let _nowEDC = nowEDC.parentEDC {
            nowEDC = _nowEDC
        }
        return nowEDC
    }

#if DEBUG
    /// Output the event data response chain for the current EDC node
    public func printEDChain() {
        var nowEDC: DCEventDataController? = self
        var index  = 0
        while nowEDC != nil {
            if let _nowEDC = nowEDC {
                print("\(index). EDChain: \(String(format: "%p", _nowEDC))  \(_nowEDC.tag)")
                index += 1
            }
            nowEDC = nowEDC?.parentEDC
        }
    }
#endif

    /// Add an EDC child node and link it with its parent
    /// - Parameter childEDC: a child EDC node
    public func addChildEDC(_ childEDC: DCEventDataController) {
        if childEDC === self {
            assert(false, "adding self as a child EDC is not allowed")
            return
        }

        if childEDC.parentEDC === self {
            assert(false, "repetitively adding the same child EDC is not allowed")
            return
        }

        if let _parentEDC = childEDC.parentEDC {
            _parentEDC.removeChildEDC(childEDC)
        }

        childEDC.parentEDC = self
        childsEDCList.write {
            let item = EDCChildItem()
            item.childEDC = childEDC
            $0.append(item)
        }

        handleChildEDCQueue.async {
            self.childsEDCList.write {
                $0 = $0.filter({ $0.childEDC != nil })
            }
        }
    }

    /// Add multiple EDC child nodes
    /// - Parameter childsEDC: an array of EDC children
    public func addChildsEDC(_ childsEDC: [DCEventDataController]) {
        for item in childsEDC {
            addChildEDC(item)
        }
    }

    /// Remove a EDC node (after removal, child EDC node can no longer communicate with reponse tree above its parent EDC node)
    /// - Parameter childEDC: the child EDC node to be removed
    public func removeChildEDC(_ childEDC: DCEventDataController) {
        self.childsEDCList.write {
            for index in (0..<$0.count).reversed() {
                if let item = $0[dc_safe: index], item.childEDC === childEDC {
                    childEDC.parentEDC = nil
                    $0.remove(at: index)
                }
            }
        }
    }

    /// Remove all EDC nodes
    public func removeAllChildEDC() {
        childsEDCList.write {
            for item in $0 {
                item.childEDC?.parentEDC = nil
            }
            $0.removeAll()
        }
    }

    /// Remove all data subscriptions on the target class object
    /// - Parameter target: class object that handles the data subscription
    public func removeAllSubscribeData(frome target: NSObject) {
        subscribeDataDict.removeAll(from: target)
    }

    /// Remove all Event subscriptions on the target class object
    /// - Parameter target: class object that handles the Event subscription
    public func removeAllSubscribeEvent(frome target: NSObject) {
        subscribeEventDict.removeAll(from: target)
    }

    // MARK: - Data Sharing

    /// Get shared data based on a DCSharedDataID
    /// - Parameters:
    ///   - sd: shared data ID
    ///   - default: default data
    /// - Returns: return the shared data, or return default data if there's no data fetched
    public func sharedData<T>(of sd: DCSharedDataID, default: T) -> T {
        if let data = sharedData(of: sd) as? T {
            return data
        }
        return `default`
    }

    /// Get shared data based on a DCSharedDataID with no default value
    /// - Parameter sd: shared data ID
    /// - Returns: return the shared data
    public func sharedData(of sd: DCSharedDataID) -> Any? {
        let data = dataDict.read {
            return $0[sd.ID]
        }
        if let _data = data {
            if let dataCallBack = _data as? DCSharedDataCallbackBlock {
                return dataCallBack()
            } else {
                return _data
            }
        } else {
            if let _parentEDC = parentEDC {
                return _parentEDC.sharedData(of: sd)
            } else {
                return nil
            }
        }
    }

    /// Share data with a closure and send a "data changed" notification
    /// - Parameters:
    ///   - sd: shared data ID
    ///   - closure: data to be returned in the closure
    public func shareData(to sd: DCSharedDataID, closure: @escaping DCSharedDataCallbackBlock) {
        shareData(to: sd, broadcast: true, closure: closure)
    }

    /// Share data with a closure with the option of broadcasting a "data changed" notification
    /// - Parameters:
    ///   - sd: shared data ID
    ///   - broadcast: whether notifying the data change to child nodes, child nodes will receive the notification if they subscribed to the data
    ///   - closure: data to be returned in the closure
    public func shareData(to sd: DCSharedDataID, broadcast: Bool, closure: @escaping DCSharedDataCallbackBlock) {
        dataDict.write {
            $0[sd.ID] = closure
        }
        if broadcast {
            updateData(sd)
        }
    }

    /// Share data and send a "data changed" notification
    /// - Parameters:
    ///   - data: data to be shared
    ///   - sd: shared data ID
    public func shareData(_ data: Any?, to sd: DCSharedDataID) {
        shareData(data, to: sd, broadcast: true)
    }

    /// Share data with the option of broadcasting a "data changed" notification
    /// - Parameters:
    ///   - data: data to be shared
    ///   - sd: shared data ID
    ///   - broadcast: whether notifying the data change to child nodes, child nodes will receive the notification if they subscribed to the data
    public func shareData(_ data: Any?, to sd: DCSharedDataID, broadcast: Bool) {
        dataDict.write {
            $0[sd.ID] = data
        }
        if broadcast {
            updateData(sd)
        }
    }

    /// Remove shared data without broadcasting
    /// - Parameter sd: shared data ID
    public func removeSharedData(with sd: DCSharedDataID) {
        shareData(nil, to: sd, broadcast: false)
    }

    private func updateData(_ sd: DCSharedDataID) {
        var isNeedClear = false
        for item in subscribeDataDict.getItems(with: sd) {
            if item.target != nil {
                item.completion?(sharedData(of: sd))
            } else {
                isNeedClear = true
            }
        }
        if isNeedClear {
            subscribeDataDict.needClear(with: sd)
        }

        for item in childsEDCList.directValue {
            if let _childEDC = item.childEDC {
                _childEDC.updateData(sd)
            }
        }
    }

    // MARK: - Send Event

    /// Send an Event and pass the Event from current node to its children nodes
    /// - Parameter event: Event ID
    public func sendEvent(_ event: DCEventID) {
        sendEvent(event, data: nil)
    }

    /// Send an Event with data and pass the Event from current node to its children nodes
    /// - Parameters:
    ///   - event: Event ID
    ///   - data: data to be carried
    public func sendEvent(_ event: DCEventID, data: Any?) {
        var isNeedClear = false
        for item in subscribeEventDict.getItems(with: event) {
            if item.target != nil {
                item.completion?(data)
            } else {
                isNeedClear = true
            }
        }
        if isNeedClear {
            subscribeEventDict.needClear(with: event)
        }
        if let _parentEDC = parentEDC {
            _parentEDC.sendEvent(event, data: data)
        }
    }

    // MARK: - Subscribe to Event

    /// Subscribe to an Event and take in the data that comes with the Event
    @discardableResult
    public func subscribeEvent(_ event: DCEventID, target: NSObject, completion: @escaping (Any?) -> Void) -> DCSubscribeEventAndable {
        subscribeEventDict.addItem(uniqueID: event, target: target) { (data) in
            completion(data)
        }
        return DCSubscribeEventAndable(edc: self, target: target)
    }

    /// Subscribe to an Event and take in the data with a specified type that comes with the Event; Will return assertion failure if type is unmatched
    @discardableResult
    public func subscribeEvent<T>(_ event: DCEventID, target: NSObject, completion: @escaping (T) -> Void) -> DCSubscribeEventAndable {
        return subscribeEvent(event, target: target) { (data) in
            if let _data = data as? T {
                completion(_data)
            } else if let _completion = completion as? (()) -> Void {
                _completion(())
            } else {
                assert(false, "Subscribed Event's data has an unmatched type")
            }
        }
    }

    /// Subscribe to a set of Events, will be called back if it matches any of the Events; If multiple Events are matched, multiple callbacks will be performed
    @discardableResult
    public func subscribeEvents(_ events: [DCEventID], target: NSObject, completion: @escaping (DCEventID) -> Void) -> DCSubscribeEventAndable {
        for event in events {
            subscribeEvent(event, target: target) {
                completion(event)
            }
        }
        return DCSubscribeEventAndable(edc: self, target: target)
    }

    /// Subscribe to a set of Events and accept the data that comes with the Events
    @discardableResult
    public func subscribeEvents(_ events: [DCEventID], target: NSObject, completion: @escaping (DCEventID, Any?) -> Void) -> DCSubscribeEventAndable {
        for event in events {
            subscribeEvent(event, target: target) { (data) in
                completion(event, data)
            }
        }
        return DCSubscribeEventAndable(edc: self, target: target)
    }

    /// Subscribe to a set of Events and take in the data with a specified type that comes with the Event; Will return assertion failure if type is unmatched
    @discardableResult
    public func subscribeEvents<T>(_ events: [DCEventID], target: NSObject, completion: @escaping (DCEventID, T) -> Void) -> DCSubscribeEventAndable {
        for event in events {
            subscribeEvent(event, target: target) { (data: T) in
                completion(event, data)
            }
        }
        return DCSubscribeEventAndable(edc: self, target: target)
    }

    // MARK: - Subscribe to Data

    /// Subscribe to data, will call back the initial nil data
    /// - Parameters:
    ///   - sd: Shared Data ID
    ///   - target: class object that handles the data subscription
    ///   - completion: data change notification call back
    /// - Returns: Chainable for repetitive data subscription
    @discardableResult
    public func subscribeData(_ sd: DCSharedDataID, target: NSObject, completion: @escaping (Any?) -> Void) -> EDCSubscribeDataAndable {
        completion(sharedData(of: sd))
        subscribeDataDict.addItem(uniqueID: sd, target: target) { (data) in
            completion(data)
        }
        return EDCSubscribeDataAndable(edc: self, target: target)
    }

    /// Subscribe to data with a specified type, will return assertion failure if type unmatched
    /// - Parameters:
    ///   - sd: Shared Data ID
    ///   - target: class object that handles the data subscription
    ///   - completion: data change notification call back
    /// - Returns: Chainable for repetitive data subscription
    @discardableResult
    public func subscribeData<T>(_ sd: DCSharedDataID, target: NSObject, completion: @escaping (T) -> Void) -> EDCSubscribeDataAndable {
        return subscribeData(sd, target: target, completion: completion, emptyCall: nil)
    }

    /// Subscribe to data with a specified type, can handle nil data
    /// - Parameters:
    ///   - sd: Shared Data ID
    ///   - target: class object that handles the data subscription
    ///   - completion: data change notification call back
    ///   - emptyCall: found nil data call back
    /// - Returns: Chainable for repetitive data subscription
    @discardableResult
    public func subscribeData<T>(_ sd: DCSharedDataID, target: NSObject, completion: @escaping (T) -> Void, emptyCall: (() -> Void)? = nil) -> EDCSubscribeDataAndable {
        func check(_ data: Any?) {
            if let data = data as? T {
                completion(data)
            } else if data == nil {
                emptyCall?()
            } else {
                assert(false, "Subscribed data has an unmatched data type")
            }
        }
        return subscribeData(sd, target: target) { (data) in
            check(data)
        }
    }

    // MARK: - Define Private Classes

    final private class EDCChildItem {
        weak var childEDC: DCEventDataController?
    }

    final private class EDCDataEventItem {
        var completion: ((Any?) -> Void)?
        weak var target: NSObject?
    }

    final private class EDCWeakEventDataController {
        weak var value: DCEventDataController?
    }

    final private class EDCEventDataDict {
        private var dict = DCProtector<[Int64: [EDCDataEventItem]]>([Int64: [EDCDataEventItem]]())
        private var handleItemQueue = DispatchQueue(label: "com.dcframe.EDCEventDataDict.handleItemQueue", qos: .default)

        func addItem(uniqueID: DCEDCUniqueID, target: NSObject, completion: @escaping (Any?) -> Void) {
            dict.write {
                var tmpItems: [EDCDataEventItem]
                if let items = $0[uniqueID.ID] {
                    tmpItems = items
                } else {
                    tmpItems = [EDCDataEventItem]()
                }

                let item = EDCDataEventItem()
                item.completion = completion
                item.target = target
                tmpItems.append(item)
                $0[uniqueID.ID] = tmpItems
            }

            handleItemQueue.async {
                self.dict.write {
                    if let items = $0[uniqueID.ID] {
                        var itemSet = Set<NSObject>()
                        var tmpItems = items
                        for index in (0..<items.count).reversed() {
                            if let item = items[dc_safe: index] {
                                if let target = item.target {
                                    if itemSet.contains(target) {
                                        tmpItems.remove(at: index)
                                        assert(false, "Can't subscribe to the same Event or data repetitively")
                                    } else {
                                        itemSet.insert(target)
                                    }
                                } else {
                                    tmpItems.remove(at: index)
                                }
                            }
                        }
                        $0[uniqueID.ID] = tmpItems
                    }
                }
            }
        }

        func needClear(with uniqueID: DCEDCUniqueID) {
            handleItemQueue.async {
                self.dict.write {
                    if let items = $0[uniqueID.ID] {
                        $0[uniqueID.ID] = items.filter({ $0.target != nil })
                    }
                }
            }
        }

        func getItems(with uniqueID: DCEDCUniqueID) -> [EDCDataEventItem] {
            return dict.read {
                var tmpItems: [EDCDataEventItem]
                if let items = $0[uniqueID.ID] {
                    tmpItems = items
                } else {
                    tmpItems = [EDCDataEventItem]()
                }
                return tmpItems
            }
        }

        func removeAll(from target: NSObject) {
            self.dict.write {
                for (key, items) in $0 {
                    $0[key] = items.filter({ $0.target !== target && $0.target != nil })
                }
            }
        }
    }
}
