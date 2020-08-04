//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation

/// An `pthread_mutex_t` wrapper.
final public class DCAroundLock {
    private var mutexLock: pthread_mutex_t

    public init() {
        mutexLock = pthread_mutex_t()
        pthread_mutex_init(&mutexLock, nil)
    }
    
    deinit {
        pthread_mutex_destroy(&mutexLock)
    }

    private func lock() {
        pthread_mutex_lock(&mutexLock)
    }

    private func unlock() {
        pthread_mutex_unlock(&mutexLock)
    }

    /// Executes a closure returning a value while acquiring the lock.
    ///
    /// - Parameter closure: The closure to run.
    ///
    /// - Returns:           The value the closure generated.
    public func around<T>(_ closure: () -> T) -> T {
        lock(); defer { unlock() }
        return closure()
    }

    /// Execute a closure while acquiring the lock.
    ///
    /// - Parameter closure: The closure to run.
    public func around(_ closure: () -> Void) {
        lock(); defer { unlock() }
        return closure()
    }
}

/// A thread-safe wrapper around a value.
final public class DCProtector<T> {
    private let lock = DCAroundLock()
    private var value: T

    public init(_ value: T) {
        self.value = value
    }

    /// The contained value. Unsafe for anything more than direct read or write.
    public var directValue: T {
        get { return lock.around { value } }
        set { lock.around { value = newValue } }
    }

    /// Synchronously read or transform the contained value.
    ///
    /// - Parameter closure: The closure to execute.
    ///
    /// - Returns:           The return value of the closure passed.
    public func read<U>(_ closure: (T) -> U) -> U {
        return lock.around { closure(self.value) }
    }

    /// Synchronously modify the protected value.
    ///
    /// - Parameter closure: The closure to execute.
    ///
    /// - Returns:           The modified value.
    @discardableResult
    public func write<U>(_ closure: (inout T) -> U) -> U {
        return lock.around { closure(&self.value) }
    }
}
