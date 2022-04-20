//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation

public class DCCollectionDataController: NSObject {
    public var objects = [DCCellModel]()
    public var hoverObjects = [DCCellModel]()

    public func objectAtIndexPath(_ indexPath: IndexPath) -> DCCellModel? {
        guard let object = objects[dc_safe: indexPath.item] else {
            return nil
        }
        return object
    }

    public func addObject(_ object: DCCellModel) {
        objects.append(object)
    }

    public func forEach<T>(_ closure: (_ object: T, _ indexPath: IndexPath) -> Void) {
        for (itemIndex, object) in objects.enumerated() {
            if let _object = object as? T {
                let indexPath = IndexPath(item: itemIndex, section: 0)
                closure(_object, indexPath)
            }
        }
    }
}
