//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import UIKit

public struct DCContainerLayoutData {
    public var contentBounds = CGRect.zero
    public var attributes = [UICollectionViewLayoutAttributes]()

    public init() {}
}

public struct DCContainerLayoutContext {
    public var topMargin: CGFloat?
    public var bottomMargin: CGFloat?
    public var leftMargin: CGFloat?
    public var rightMargin: CGFloat?
    public var verticalInterval: CGFloat?
    public var horizontalInterval: CGFloat?

    public init() {}
}
