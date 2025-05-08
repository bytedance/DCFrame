//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import UIKit

public protocol DCBaseOperationDelegate: AnyObject {
    func needUpdateLayout()
    func needUpdateLayoutAnimated()
    func needUpdateLayoutAnimated(completion: @escaping () -> Void)
    func getVisibleCells() -> [DCBaseCell]
    func scrollTo(_ offsetPoint: CGPoint)
    func scrollTo(_ offsetPoint: CGPoint, animated: Bool)
}
