//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import UIKit

public protocol DCContainerLayoutable: AnyObject {
    func layoutAttributes(_ collectionView: DCCollectionView, containerModel: DCContainerModel, startOrigin: CGPoint) -> DCContainerLayoutData?
}
