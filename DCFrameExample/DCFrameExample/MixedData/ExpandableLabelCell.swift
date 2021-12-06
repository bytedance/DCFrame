//
//  ExpandableLabelCell.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/8.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import DCFrame

class ExpandableLabelModel: DCCellModel {
    let text: String
    var isExpand = false
    
    fileprivate static let insets = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
    fileprivate static let font = UIFont.systemFont(ofSize: 17)

    init(text: String) {
        self.text = text
        super.init()
        
        cellClass = ExpandableLabelCell.self
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func getCellHeight() -> CGFloat {
        return isExpand ? Self.textHeight(text) : Self.singleLineHeight
    }
    
    static var singleLineHeight: CGFloat {
        return font.lineHeight + insets.top + insets.bottom
    }

    static func textHeight(_ text: String) -> CGFloat {
        let width = UIScreen.main.bounds.width
        let constrainedSize = CGSize(width: width - insets.left - insets.right, height: CGFloat.greatestFiniteMagnitude)
        let attributes = [NSAttributedString.Key.font: font]
        let options: NSStringDrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin]
        let bounds = (text as NSString).boundingRect(with: constrainedSize, options: options, attributes: attributes, context: nil)
        return ceil(bounds.height) + insets.top + insets.bottom
    }
}

class ExpandableLabelCell: DCCell<ExpandableLabelModel> {
    private let label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.font = ExpandableLabelModel.font
        return label
    }()
    
    private let separator: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor(red: 200 / 255.0, green: 199 / 255.0, blue: 204 / 255.0, alpha: 1).cgColor
        return layer
    }()
    
    override func setupUI() {
        super.setupUI()
        contentView.addSubview(label)
        contentView.layer.addSublayer(separator)
        contentView.backgroundColor = .white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        label.frame = bounds.inset(by: ExpandableLabelModel.insets)
        let height: CGFloat = 0.5
        let left = ExpandableLabelModel.insets.left
        separator.frame = CGRect(x: left, y: bounds.height - height, width: bounds.width - left, height: height)
    }
    
    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()
        label.text = cellModel.text
    }
    
    override func didSelect() {
        super.didSelect()
        
        cellModel.isExpand = !cellModel.isExpand
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.6, options: [], animations: {
            if #available(iOS 11.0, *) {
                self.containerTableView?.performBatchUpdates({
                    
                }, completion: { (_) in
                    
                })
            } else {
                // Fallback on earlier versions
            }
        })
    }
}
