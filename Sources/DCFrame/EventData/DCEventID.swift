//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation

/// Define unique identifier of an Event
final public class DCEventID: DCEDCUniqueID {
    // nothing
}

/// Define unique identifier of Shared Data
final public class DCSharedDataID: DCEDCUniqueID {
    // nothing
}

public class DCEDCUniqueID: Equatable {
    private static var globalID = DCProtector<Int64>(0)
    private(set) var ID: Int64
    public lazy var tag = ""
    public init() {
        DCEDCUniqueID.globalID.write {
            $0 += 1
        }
        ID = DCEDCUniqueID.globalID.directValue
    }

    public convenience init(tag: String) {
        self.init()
        self.tag = tag
    }

    public static func == (lhs: DCEDCUniqueID, rhs: DCEDCUniqueID) -> Bool {
        return lhs.ID == rhs.ID
    }
}
