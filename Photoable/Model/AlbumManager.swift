//
//  AlbumManager.swift
//  Photoable
//
//  Created by 임채윤 on 2023/02/13.
//

import Foundation
import Photos
import UIKit

struct AlbumManager {
    func createAlbum(_ albumName: String, completion: @escaping (Result<String, Error>) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
        }, completionHandler: { success, error in
            if success {
                completion(.success(albumName))
            } else {
                if let error = error {
                    completion(.failure(error))
                }
            }
        })
    }
    
    func addImages(assets: [PHAsset], toAlbum albumName: String, completion: @escaping (Result<(String, Int), Error>) -> Void) {
        var images = [UIImage]()
        for asset in assets {
            if let cacheImage = ImageCache.shared.image(forKey: asset.localIdentifier) {
                images.append(cacheImage)
            } else {
                let imageManager = ImageManager()
                imageManager.fetchImage(asset: asset) { image in
                    images.append(image)
                }
            }
        }
        
        PHPhotoLibrary.shared().performChanges({
            var assetPlaceholders = [PHObjectPlaceholder]()
            for image in images {
                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                assetPlaceholders.append(assetChangeRequest.placeholderForCreatedAsset!)
            }
            
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: fetchAlbum(albumName: albumName))
            albumChangeRequest!.addAssets(NSArray(array: assetPlaceholders))
        }, completionHandler: { success, error in
            if success {
                completion(.success( (albumName, images.count)))
            } else {
                if let error = error {
                    completion(.failure(error))
                }
            }
        })
    }
    
    func fetchAlbum(userCollection: Bool, smartCollection: Bool) -> [AlbumModel] {
        var albums = [AlbumModel]()
        
        let smartCollections = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .any,
            options: nil)
        
        let userCollections = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .any,
            options: nil)
        
        if smartCollection {
            smartCollections.enumerateObjects { collection, index, stop in
                if collection.estimatedAssetCount > 0 {
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [
                        NSSortDescriptor(key: "creationDate", ascending: false)
                    ]
                    fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                    
                    let assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                    if let title = collection.localizedTitle, assets.count > 0 {
                        switch title {
                        case "Recents":
                            albums.append(AlbumModel(asset: assets, title: "모든 사진", count: assets.count))
                        case "Favorites":
                            albums.append(AlbumModel(asset: assets, title: "내가 좋아하는 사진", count: assets.count))
                        case "Hidden":
                            albums.append(AlbumModel(asset: assets, title: "숨겨진 사진", count: assets.count))
                        default:
                            break
                        }
                    }
                }
            }
        }
        
        if userCollection {
            userCollections.enumerateObjects { collection, index, stop in
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [
                    NSSortDescriptor(key: "creationDate", ascending: false)
                ]
                fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                
                let assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                albums.append(AlbumModel(asset: assets, title: collection.localizedTitle ?? "이름 없음", count: assets.count))
            }
        }
        
        return albums
    }
    
    func fetchAlbum(albumName: String) -> PHAssetCollection {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let firstObject = collections.firstObject {
            return firstObject
        }
        
        return PHAssetCollection()
    }
    
    
    
}
