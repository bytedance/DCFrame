//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

public class DCThrottler: NSObject {
    public var timeInterval: TimeInterval?
    public typealias CallbackType = (() -> Void)

    private var isThrottling = DCProtector<Bool>(false)
    private var callbackDict = DCProtector<[String: CallbackType]>([String: CallbackType]())

    public init(timeInterval: TimeInterval = 0.05) {
        super.init()
        self.timeInterval = timeInterval
    }

    /// Execute within a set time interval, will be called back on the first call
    /// - Parameters:
    ///   - key: unique keyword for the execution, every execution has a different key value
    ///   - callback: call back method for the execution, { [weak self] in } is necessary to avoid memory leak
    public func execute(_ key: String = "default_key", _ callback: @escaping CallbackType) {
        callbackDict.write {
            $0[key] = callback
        }
        
        if isThrottling.directValue {
            return
        }
        isThrottling.directValue = true
        
        if Thread.isMainThread {
            startThrottle()
        } else {
            DispatchQueue.main.async {
                self.startThrottle()
            }
        }
    }

    /// Execute within a set time interval, will not execute immediately on the first call but on the next time interval
    /// - Parameters:
    ///   - key: unique keyword for the execution, every execution has a different key value
    ///   - callback: call back method for the execution, { [weak self] in } is necessary to avoid memory leak
    public func delayExecute(_ key: String = "default_key", _ callback: @escaping CallbackType) {
        if !isThrottling.directValue {
            execute(key) {
                // do nothing
            }
        }
        execute(key, callback)
    }

    private func startThrottle() {
        let isCanCallback = callbackDict.read {
            $0.keys.count > 0
        }
        guard let timeInterval = self.timeInterval, isCanCallback else {
            return
        }
        isThrottling.directValue = true

        let tmpCallbackDict = callbackDict.directValue
        callbackDict.write {
            $0.removeAll()
        }
     
        for (_, callback) in tmpCallbackDict {
            callback()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) { [weak self] in
            self?.throttleExecute()
        }
    }

    private func throttleExecute() {
        let isCanCallback = callbackDict.read {
            $0.keys.count > 0
        }
        if isCanCallback {
            startThrottle()
        } else {
            isThrottling.directValue = false
        }
    }
}
