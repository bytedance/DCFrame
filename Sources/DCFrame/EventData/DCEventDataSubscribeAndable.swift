//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation

/// Base class for chainable subscribe action
public class DCEventDataSubscribeAndable {
    var edc: DCEventDataController
    var target: NSObject

    init(edc: DCEventDataController, target: NSObject) {
        self.edc = edc
        self.target = target
    }
}

/// Make subscribeEvent() chainable
final public class DCSubscribeEventAndable: DCEventDataSubscribeAndable {
    @discardableResult
    public func and(_ event: DCEventID, completion: @escaping (Any?) -> Void) -> DCSubscribeEventAndable {
        return edc.subscribeEvent(event, target: target, completion: completion)
    }

    @discardableResult
    public func and<T>(_ event: DCEventID, completion: @escaping (T) -> Void) -> DCSubscribeEventAndable {
        return edc.subscribeEvent(event, target: target, completion: completion)
    }

    @discardableResult
    public func and(_ events: [DCEventID], completion: @escaping (DCEventID) -> Void) -> DCSubscribeEventAndable {
        return edc.subscribeEvents(events, target: target, completion: completion)
    }

    @discardableResult
    public func and(_ events: [DCEventID], completion: @escaping (DCEventID, Any?) -> Void) -> DCSubscribeEventAndable {
        return edc.subscribeEvents(events, target: target, completion: completion)
    }

    @discardableResult
    public func and<T>(_ events: [DCEventID], completion: @escaping (DCEventID, T) -> Void) -> DCSubscribeEventAndable {
        return edc.subscribeEvents(events, target: target, completion: completion)
    }
}

/// Make subscribeData() chainable
final public class EDCSubscribeDataAndable: DCEventDataSubscribeAndable {
    @discardableResult
    public func and(_ sd: DCSharedDataID, completion: @escaping (Any?) -> Void) -> EDCSubscribeDataAndable {
        return edc.subscribeData(sd, target: target, completion: completion)
    }

    @discardableResult
    public func and<T>(_ sd: DCSharedDataID, completion: @escaping (T) -> Void) -> EDCSubscribeDataAndable {
        return edc.subscribeData(sd, target: target, completion: completion)
    }

    @discardableResult
    public func and<T>(_ sd: DCSharedDataID, completion: @escaping (T) -> Void, emptyCall: @escaping () -> Void) -> EDCSubscribeDataAndable {
        return edc.subscribeData(sd, target: target, completion: completion, emptyCall: emptyCall)
    }
}
