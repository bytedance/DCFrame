//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation

/// Base class for chainable subscribe action
public class DCEventDataSubscribeBaseAndAbility {
    var edc: DCEventDataController
    var target: NSObject

    init(edc: DCEventDataController, target: NSObject) {
        self.edc = edc
        self.target = target
    }
}

/// Make subscribeEvent() chainable
final public class DCSubscribeEventAndAbility: DCEventDataSubscribeBaseAndAbility {
    @discardableResult
    public func and(_ event: DCEventID, completion: @escaping (Any?) -> Void) -> DCSubscribeEventAndAbility {
        return edc.subscribeEvent(event, target: target, completion: completion)
    }

    @discardableResult
    public func and<T>(_ event: DCEventID, completion: @escaping (T) -> Void) -> DCSubscribeEventAndAbility {
        return edc.subscribeEvent(event, target: target, completion: completion)
    }

    @discardableResult
    public func and(_ events: [DCEventID], completion: @escaping (DCEventID) -> Void) -> DCSubscribeEventAndAbility {
        return edc.subscribeEvents(events, target: target, completion: completion)
    }

    @discardableResult
    public func and(_ events: [DCEventID], completion: @escaping (DCEventID, Any?) -> Void) -> DCSubscribeEventAndAbility {
        return edc.subscribeEvents(events, target: target, completion: completion)
    }

    @discardableResult
    public func and<T>(_ events: [DCEventID], completion: @escaping (DCEventID, T) -> Void) -> DCSubscribeEventAndAbility {
        return edc.subscribeEvents(events, target: target, completion: completion)
    }
}

/// Make subscribeData() chainable
final public class DCSubscribeDataAndAbility: DCEventDataSubscribeBaseAndAbility {
    @discardableResult
    public func and(_ sd: DCSharedDataID, completion: @escaping (Any?) -> Void) -> DCSubscribeDataAndAbility {
        return edc.subscribeData(sd, target: target, completion: completion)
    }

    @discardableResult
    public func and<T>(_ sd: DCSharedDataID, completion: @escaping (T) -> Void) -> DCSubscribeDataAndAbility {
        return edc.subscribeData(sd, target: target, completion: completion)
    }

    @discardableResult
    public func and<T>(_ sd: DCSharedDataID, completion: @escaping (T) -> Void, emptyCall: @escaping () -> Void) -> DCSubscribeDataAndAbility {
        return edc.subscribeData(sd, target: target, completion: completion, emptyCall: emptyCall)
    }
}
