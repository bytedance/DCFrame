//
//  DemosSeparateLine.swift
//  DCFrame_Example
//

import UIKit
import SnapKit

extension String {
    func textHeight(width: CGFloat, font: UIFont) -> CGFloat {
        let constrainedSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let attributes = [NSAttributedString.Key.font: font]
        let options: NSStringDrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin]
        let bounds = (self as NSString).boundingRect(with: constrainedSize, options: options, attributes: attributes, context: nil)
        return ceil(bounds.height)
    }
}

extension UIView {
    
    @discardableResult
    func addBottomLine(leftMargin: CGFloat = 0, rightMargin: CGFloat = 0) -> UIView {
        let line = UIView()
        let height: CGFloat = 1.0 / UIScreen.main.scale

        line.backgroundColor = UIColor.lightGray
        addSubview(line)

        line.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalTo(leftMargin)
            make.right.equalTo(-rightMargin)
            make.height.equalTo(height)
        }

        return line
    }
}
