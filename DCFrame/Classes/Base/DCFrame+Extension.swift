//
// Copyright (c) Bytedance Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//

extension Array {
    subscript (dc_safe index: Int) -> Element? {
        if index < count && index >= 0 {
            return self[index]
        }
        return nil
    }
}

extension UIView {
    var dc_height: CGFloat {
        set(v) {
            self.frame.size.height = v
        }
        get {
            return self.frame.size.height
        }
    }
    
    var dc_width: CGFloat {
        set(v) {
            self.frame.size.width = v
        }
        get {
            return self.frame.size.width
        }
    }
    
    var dc_size: CGSize {
        set(v) {
            self.frame.size = v
        }
        get {
            return self.frame.size
        }
    }
    
    var dc_left: CGFloat {
        set(v) {
            self.frame.origin.x = v
        }
        get {
            return self.frame.origin.x
        }
    }
    
    var dc_right: CGFloat {
        set(new) {
            self.frame.origin.x = new - self.frame.size.width
        }
        get {
            return  self.frame.origin.x + self.frame.size.width
        }
    }
    
    var dc_top: CGFloat {
        set(v) {
            frame.origin.y = v
        }
        get {
            return self.frame.origin.y
        }
    }
    
    var dc_bottom: CGFloat {
        set(v) {
            self.frame.origin.y = v - self.frame.size.height
        }
        get {
            return self.frame.origin.y + self.frame.size.height
        }
    }
    
    var dc_origin: CGPoint {
        set(v) {
            self.frame.origin = v
        }
        get {
            return self.frame.origin
        }
    }
    
    var dc_centerX: CGFloat {
        set(v) {
            self.center = CGPoint(x: v, y: self.center.y)
        }
        get {
            return self.center.x
        }
    }
    
    var dc_centerY: CGFloat {
        set(v) {
            self.center = CGPoint(x: self.center.x, y: v)
        }
        get {
            return self.center.y
        }
    }
    
    func dc_snapShotImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            self.layoutIfNeeded()
            self.layer.render(in: context)
        }
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}

extension UIImage {
    static func dc_verticalImage(with imagesArray: [UIImage]) -> UIImage? {
        var totalSize = CGSize.zero
        for image in imagesArray {
            let imageSize = image.size
            totalSize.height += imageSize.height
            totalSize.width = max(totalSize.width, imageSize.width)
        }
        
        UIGraphicsBeginImageContextWithOptions(totalSize, false, 0)
        var imageOffsetY: CGFloat = 0
        for image in imagesArray {
            image.draw(at: CGPoint(x: 0, y: imageOffsetY))
            imageOffsetY += image.size.height
        }
        let verticalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return verticalImage
    }
}
