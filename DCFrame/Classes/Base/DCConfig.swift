//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation

/// Configure default separator height, color, selected cell color, and cell background color
final public class DCConfig {
    public static let shared = DCConfig()
    
    public var cellSeparatorHeight: CGFloat = 6
    public var cellSeparatorColor = UIColor(red: 242 / 255.0, green: 242 / 255.0, blue: 242 / 255.0, alpha: 1.0)
    public var selectedColor = UIColor(red: 242 / 255.0, green: 242 / 255.0, blue: 242 / 255.0, alpha: 1.0)
    public var cellBackgroundColor = UIColor.white
}
