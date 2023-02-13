//
//  ImageManager.swift
//  Photoable
//
//  Created by 임채윤 on 2023/02/13.
//

import Photos
import UIKit

struct ImageManager {
    func fetchImage(asset: PHAsset, cellIdentifier: String, completion: @escaping (UIImage) -> Void)  {
        let imageManager = PHCachingImageManager()
        let thumbnailSize = CGSize(width: 1024 * UIScreen.main.scale, height: 1024 * UIScreen.main.scale)
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            if cellIdentifier == asset.localIdentifier, let image = image {
                ImageCache.shared.setImage(image, forKey: asset.localIdentifier)
                completion(image)
            }
        })
    }
    
    func fetchImage(asset: PHAsset, completion: @escaping (UIImage) -> Void) {
        let imageManager = PHCachingImageManager()
        let thumbnailSize = CGSize(width: 1024 * UIScreen.main.scale, height: 1024 * UIScreen.main.scale)
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            if let image = image {
                ImageCache.shared.setImage(image, forKey: asset.localIdentifier)
                completion(image)
            }
        })
    }
}
