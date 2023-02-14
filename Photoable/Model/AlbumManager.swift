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
    
    func addImages(assetIdentifiers: [String], toAlbum albumName: String, completion: @escaping (Result<(String, Int), Error>) -> Void) {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: nil)
        
        PHPhotoLibrary.shared().performChanges({
            assets.enumerateObjects { asset, index, stop in
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: fetchAlbum(albumName: albumName))
                albumChangeRequest?.addAssets([asset] as NSArray)
            }
        }, completionHandler: { (success, error) in
            if success {
                completion(.success( (albumName, assets.count)))
            } else {
                if let error = error {
                    completion(.failure(error))
                }
            }
        })
    }
    
    func removeImages(assetIdentifiers: [String], toAlbum albumName: String, completion: @escaping (Result<(String, Int), Error>) -> Void) {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: nil)
        
        PHPhotoLibrary.shared().performChanges({
            assets.enumerateObjects { asset, index, stop in
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: fetchAlbum(albumName: albumName))
                albumChangeRequest?.removeAssets([asset] as NSArray)
            }
        }, completionHandler: { (success, error) in
            if success {
                completion(.success( (albumName, assets.count)))
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
                    print(collection.localIdentifier)
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [
                        NSSortDescriptor(key: "creationDate", ascending: false)
                    ]
                    fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                    
                    let assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                    if let title = collection.localizedTitle, assets.count > 0 {
                        switch title {
                        case "Recents":
                            albums.append(AlbumModel(asset: assets, identifier: collection.localIdentifier, title: "모든 사진", count: assets.count, albumType: "smartAlbum"))
                        case "Favorites":
                            albums.append(AlbumModel(asset: assets, identifier: collection.localIdentifier, title: "내가 좋아하는 사진", count: assets.count, albumType: "smartAlbum"))
                        case "Hidden":
                            albums.append(AlbumModel(asset: assets, identifier: collection.localIdentifier, title: "숨겨진 사진", count: assets.count, albumType: "smartAlbum"))
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
                albums.append(AlbumModel(asset: assets, identifier: collection.localIdentifier, title: collection.localizedTitle ?? "이름 없음", count: assets.count, albumType: "userAlbum"))
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
    
    func fetchAlbum(identifier: String) -> PHAssetCollection {
        guard let album = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [identifier], options: nil).firstObject else {
            return PHAssetCollection()
        }
        
        return album
    }
    
    func deleteAlbum(identifier: String, completion: @escaping (Result<String, Error>) -> Void) {
        let album = fetchAlbum(identifier: identifier)
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.deleteAssetCollections([album] as NSFastEnumeration)
        }, completionHandler: { success, error in
            if success {
                completion(.success(album.localizedTitle ?? ""))
            } else {
                if let error = error {
                    completion(.failure(error))
                }
            }
        })
    }
    
    
}
