//
//  AddPhotoToAlbumCollectionViewCell.swift
//  Photoable
//
//  Created by 임채윤 on 2023/02/14.
//

import UIKit

class AddPhotoToAlbumCollectionViewCell: UICollectionViewCell {
    static let identifier = "AddPhotoToAlbumCollectionViewCell"
    var representedAssetIdentifier: String?
    
    var image: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = 10
        
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 2
        
        return label
    }()
    
    let countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        
        return label
    }()
    
    override init(frame: CGRect) {
       super.init(frame: frame)
       self.setUILayout()
   }
   
   required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }
    
    private func setUILayout() {
        let views = [image, titleLabel, countLabel]
        
        views.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
        }
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: self.topAnchor),
            image.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -40),
            image.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            image.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            countLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            countLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
        ])
    }
}
