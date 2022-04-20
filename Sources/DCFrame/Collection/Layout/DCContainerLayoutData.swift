//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import UIKit

public class DCContainerLayoutData {
    public var backgroundCellIndexPaths = [IndexPath]()
    public var originHoverAttributes = [UICollectionViewLayoutAttributes]()
    public var hoverAttributes = [UICollectionViewLayoutAttributes]()
    public var currentHoverAttributes: UICollectionViewLayoutAttributes?
    public var contentBounds = CGRect.zero
    public var attributes = [UICollectionViewLayoutAttributes]()
    public var lineAttributesArray = [LineAttributes]()

    public class LineAttributes {
        public var lineFrame = CGRect.zero
        public var itemIndexPaths = [IndexPath]()
        
        public init(lineFrame: CGRect) {
            self.lineFrame = lineFrame
        }
    }
    
    public init() {}
}

public class DCContainerLayoutContext {
    public var topMargin: CGFloat?
    public var bottomMargin: CGFloat?
    public var leftMargin: CGFloat?
    public var rightMargin: CGFloat?
    public var verticalInterval: CGFloat?
    public var horizontalInterval: CGFloat?
    
    public init() {}
}
