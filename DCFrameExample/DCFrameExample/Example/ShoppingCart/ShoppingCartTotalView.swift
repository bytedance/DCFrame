//
//  ShoppingCartTotalView.swift
//  DCFrame_Example
//

import UIKit

class ShoppingCartTotalView: UIView {
    private let priceLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    private func setupUI() {
        backgroundColor = UIColor(red: 56 / 255.0, green: 151 / 255.0, blue: 240 / 255.0, alpha: 1)
        addSubview(priceLabel)

        priceLabel.font = .boldSystemFont(ofSize: 18)
        priceLabel.textColor = .black
        priceLabel.text = "Total: $0"
        priceLabel.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.top.equalTo(20)
        }
    }

    func update(price: Int64) {
        priceLabel.text = String(format: "Total: $%.2f", Double(price) / 100)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
