//
//  ProductImageCell.swift
//  Goshsha Capstone
//
//  Created by Amber Chang on 2/27/25.
//

import UIKit

class ProductImageCell: UICollectionViewCell {
    
    private var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    // Configure the cell with image and highlight if selected
    func configure(with image: UIImage, isSelected: Bool) {
        imageView.image = image
        if isSelected {
            layer.borderColor = UIColor.black.cgColor
            layer.borderWidth = 4
            layer.cornerRadius = 8
        } else {
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0
        }
    }
}
