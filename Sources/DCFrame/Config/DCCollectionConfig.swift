//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

import UIKit

/// Configure default separator height, color, selected cell color, and cell background color
public enum DCCollectionConfig {
    public static var cellSeparatorHeight: CGFloat = 6
    public static var cellSeparatorColor = UIColor(red: 242 / 255.0, green: 242 / 255.0, blue: 242 / 255.0, alpha: 1.0)
    public static var selectedColor = UIColor(red: 242 / 255.0, green: 242 / 255.0, blue: 242 / 255.0, alpha: 1.0)
    public static var cellBackgroundColor = UIColor.white
}
