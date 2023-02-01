//
//  ViewController.swift
//  Photoable
//
//  Created by 임채윤 on 2022/12/21.
//

import UIKit
import PhotosUI

class PhotosViewController: UIViewController {

    var photos = [UIImage]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickPhoto()
        // Do any additional setup after loading the view.
    }
    
    private func getPermissionIfNecessary(completion: @escaping (Bool) -> (Void)) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                if status == .authorized {
                    completion(true)
                }
            }
        case .authorized:
            completion(true)
        default:
            completion(false)
        }
    }
    
    private func pickPhoto() {
        getPermissionIfNecessary { permission in
            if permission {
                let allPhotosOptions = PHFetchOptions()
                allPhotosOptions.sortDescriptors = [
                    NSSortDescriptor(key: "creationDate", ascending: false)
                ]
                
                let allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
                
                allPhotos.enumerateObjects { (asset, count, stop) in
                    let targetSize = CGSize(width: UIScreen.main.bounds.width, height: CGFloat(asset.pixelHeight) * UIScreen.main.bounds.width / CGFloat(asset.pixelWidth))
                    let imageManager = PHImageManager.default()
                    let options = PHImageRequestOptions()
                    options.isSynchronous = true
                    imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: PHImageContentMode.aspectFit, options: options, resultHandler: { [weak self] (image, info) in
                        if let image = image {
                            self?.photos.append(image)
                        }
                    })
                    print(count)
                }
                print(self.photos)
            } else {
                // 권한이 허용되지 않았다고 alert 띄우기
            }
        }
        
        
    }

}
