//
//  InteractiveCell.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/9.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import DCFrame

class InteractiveCellModel: DCCellModel {
    required init() {
        super.init()
        cellClass = InteractiveCell.self
        cellHeight = 41
    }
}

class InteractiveCell: DCCell<InteractiveCellModel> {
    static let likeTouch = DCEventID()
    static let commentTouch = DCEventID()
    static let shareTouch = DCEventID()
    
    private lazy var likeButton: UIButton = {
        return createButton(with: "Like")
    }()
    private lazy var commentButton: UIButton = {
        return createButton(with: "Comment")
    }()
    private lazy var shareButton: UIButton = {
        return createButton(with: "Share")
    }()
    private lazy var separator: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor(red: 200/255.0, green: 199/255.0, blue: 204/255.0, alpha: 1).cgColor
        return layer
    }()
    
    override func setupUI() {
        super.setupUI()
        contentView.addSubview(likeButton)
        contentView.addSubview(commentButton)
        contentView.addSubview(shareButton)
        contentView.layer.addSublayer(separator)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = contentView.bounds
        let leftPadding: CGFloat = 8.0
        
        likeButton.frame = CGRect(x: leftPadding, y: 0, width: likeButton.frame.width, height: bounds.size.height)
        commentButton.frame = CGRect(x: leftPadding + likeButton.frame.maxX, y: 0, width: commentButton.frame.width, height: bounds.size.height)
        shareButton.frame = CGRect(x: leftPadding + commentButton.frame.maxX, y: 0, width: shareButton.frame.width, height: bounds.size.height)
        
        let height: CGFloat = 0.5
        separator.frame = CGRect(x: leftPadding, y: bounds.size.height - height, width: bounds.size.width - leftPadding, height: height)
    }

    private func createButton(with title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor(red: 28/255.0, green: 30/255.0, blue: 28/255.0, alpha: 1.0), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        button.sizeToFit()
        button.addTarget(self, action: #selector(touch(sender:)), for: .touchUpInside)
        return button
    }
    
    @objc func touch(sender: UIButton) {
        switch sender {
        case likeButton:
            sendEvent(Self.likeTouch, data: sender.titleLabel?.text)
        case commentButton:
            sendEvent(Self.commentTouch, data: sender.titleLabel?.text)
        case shareButton:
            sendEvent(Self.shareTouch, data: sender.titleLabel?.text)
        default: break
        }
    }
}
