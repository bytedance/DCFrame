//
//  Utils.swift
//  DCContainerView_Example
//

import UIKit

extension UIColor {
    public convenience init?(hex: String) {
        let hexColor = hex.hasPrefix("#") ? String(hex[hex.index(hex.startIndex, offsetBy: 1)...]) : hex
        let r, g, b: CGFloat

        if hexColor.count == 6 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0
            if scanner.scanHexInt64(&hexNumber) {
                r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                b = CGFloat(hexNumber & 0x0000ff) / 255
                self.init(red: r, green: g, blue: b, alpha: 1)
                return
            }
        }
        return nil
    }
}

class DemoUtil {
    static func isIPhoneX() -> Bool {
        if #available(iOS 11.0, tvOS 11.0, *), let window = UIApplication.shared.keyWindow {
            if window.safeAreaInsets.left > 0 || window.safeAreaInsets.bottom > 0 {
                return true
            }
        }
        return false
    }

    static func navbarHeight() -> CGFloat {
        return UIApplication.shared.statusBarFrame.height + 44
    }

    static func safeBottomMargin() -> CGFloat {
        if isIPhoneX() {
            return 34.0
        } else {
            return 0.0
        }
    }
}
