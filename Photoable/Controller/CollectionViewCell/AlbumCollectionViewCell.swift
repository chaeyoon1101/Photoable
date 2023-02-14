//
//  AlbumCollectionViewCell.swift
//  Photoable
//
//  Created by 임채윤 on 2023/02/13.
//

import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    static let identifier = "AlbumCollectionViewCell"
    var representedAssetIdentifier: String?

    var isEditingView: Bool? {
        didSet {
            if isEditingView == true {
                deleteButton.isHidden = false
            } else {
                deleteButton.isHidden = true
            }
        }
    }
    
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
    
    lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .light)
        
        button.setImage(UIImage(systemName: "minus.circle.fill", withConfiguration: imageConfig), for: .normal)
        button.tintColor = .red
        button.backgroundColor = .label
        button.layer.cornerRadius = 10.5
        button.isHidden = true
        
        return button
    }()
    
    override init(frame: CGRect) {
       super.init(frame: frame)
        isEditingView = false
       self.setUILayout()
   }
   
   required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }
    
    private func setUILayout() {
        let views = [image, titleLabel, countLabel, deleteButton]
        
        views.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
        }
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: self.topAnchor),
            image.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -40),
            image.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            image.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            countLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            countLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            deleteButton.topAnchor.constraint(equalTo: self.image.topAnchor, constant: -5),
            deleteButton.leadingAnchor.constraint(equalTo: self.image.leadingAnchor, constant: -5)
        ])
    }
}
