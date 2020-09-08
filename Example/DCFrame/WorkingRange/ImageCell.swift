//
//  ImageCell.swift
//  DCFrame_Example
//
//  Created by 张政桢 on 2020/6/10.
//  Copyright © 2020 Bytedance. All rights reserved.
//

import DCFrame

class ImageCellModel: DCCellModel {
    var urlString: String?
    var image: UIImage?
    
    required init() {
        super.init()
        cellClass = ImageCell.self
    }
    
    override func cellModelDidLoad() {
        super.cellModelDidLoad()
        
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, let image = UIImage(data: data) else {
                return print("Error downloading \(urlString): " + String(describing: error))
            }
            DispatchQueue.main.async {
                self.image = image
                self.needReloadCellData()
            }
        }.resume()
    }
}

class ImageCell: DCCell<ImageCellModel> {
    private let myImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        return view
    }()

    private let activityView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        view.startAnimating()
        return view
    }()
    
    
    override func setupUI() {
        super.setupUI()
        contentView.addSubview(myImageView)
        contentView.addSubview(activityView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        activityView.center = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0)
        myImageView.frame = bounds
    }
    
    override func cellModelDidUpdate() {
        super.cellModelDidUpdate()
        setImage(image: cellModel.image)
    }

    private func setImage(image: UIImage?) {
        myImageView.image = image
        if image != nil {
            activityView.stopAnimating()
        } else {
            activityView.startAnimating()
        }
    }
}
