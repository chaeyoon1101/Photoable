//
//  SelectedPhotosCollectionViewCell.swift
//  Photoable
//
//  Created by 임채윤 on 2023/02/12.
//

import UIKit
import AVFoundation
import Photos

class SelectedPhotosCollectionViewCell: UICollectionViewCell {
    static let identifier = "SelectedPhotosCollectionViewCell"
    var representedAssetIdentifier: String?
    
    let image: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUILayout()
        layoutSubviews()
    }
   
    required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }
    
    private func setUILayout() {
        let views = [image]

        views.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
        }

        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: self.topAnchor),
            image.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            image.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            image.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
}
