//
//  PhotosCollectionViewCell.swift
//  Photoable
//
//  Created by 임채윤 on 2023/02/01.
//

import UIKit

class PhotosCollectionViewCell: UICollectionViewCell {
    static let identifier = "PhotosCollectionViewCell"
    var representedAssetIdentifier: String?
    
    var isSelectedPhoto: Bool? {
        didSet {
            if isSelectedPhoto == true {
                selectMark.isHidden = false
            } else {
                selectMark.isHidden = true
            }
        }
    }
    
    let image: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    let selectMark: UIImageView = {
        let imageView = UIImageView()
        imageView.frame.size = CGSize(width: 20, height: 20)
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.backgroundColor = .label
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.clipsToBounds = true
        imageView.isHidden = true
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUILayout()
    }
   
   required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }
    
    private func setUILayout() {
        let views = [image, selectMark]
        
        views.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: self.topAnchor),
            image.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            image.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            image.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            selectMark.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            selectMark.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
        ])
    }
}
