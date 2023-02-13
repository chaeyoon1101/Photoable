//
//  ViewController.swift
//  Photoable
//
//  Created by 임채윤 on 2022/12/21.
//

import UIKit
import PhotosUI

class PhotoViewController: UIViewController {
    
    var assets = PHFetchResult<PHAsset>()
    var albumName: String?
    var albumType: String?
    var photoSelectStatus: PhotoSelectStatus = .defaultStatus
    var isSelectedPhotos: [Bool] = []
    let imageManager = PHCachingImageManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUILayout()
        configurationCollectionView()
        isSelectedPhotos = [Bool](repeating: false, count: assets.count)
        navigationItem.rightBarButtonItem = selectPhotoButtonItem
        NotificationCenter.default.addObserver(self, selector: #selector(handlePhotoLibraryDidChange), name: NSNotification.Name("photoLibraryDidChange"), object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        navigationItem.title = albumName
        photoCollectionView.reloadData()
    }
    
    @objc private func tapSelectPhotosButton() {
        photoSelectStatus = .seletingPhotoStatus
        navigationItem.rightBarButtonItem = cancleSelectPhotoButtonItem
        
    }
    
    @objc private func tapCancleSelectPhotoButton() {
        photoSelectStatus = .defaultStatus
        navigationItem.rightBarButtonItem = selectPhotoButtonItem
    }
    
    @objc private func handlePhotoLibraryDidChange(notification: Notification) {
        if let asset = notification.object as? PHFetchResult<PHAsset> {
            self.assets = asset
        }
        print("photoViewController 변경")
        self.photoCollectionView.reloadData()
    }
    
    private func configurationCollectionView() {
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        let cellIdentifier = PhotosCollectionViewCell.identifier
        photoCollectionView.register(PhotosCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }
    
    private lazy var selectPhotoButtonItem = UIBarButtonItem(title: "사진 선택", style: .done, target: self, action: #selector(tapSelectPhotosButton))
    
    private lazy var cancleSelectPhotoButtonItem = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(tapCancleSelectPhotoButton))
    
    let photoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        return collectionView
    }()
    
    
    private func setUILayout() {
        let views = [photoCollectionView]
        
        views.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
        
        print("====== Set UI layout ======")
        NSLayoutConstraint.activate([
            photoCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            photoCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photoCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            photoCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension PhotoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = PhotosCollectionViewCell.identifier
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? PhotosCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        
        let asset = self.assets[indexPath.item]
        cell.representedAssetIdentifier = asset.localIdentifier
        
        if let cachedImage = ImageCache.shared.image(forKey: asset.localIdentifier) {
            DispatchQueue.main.async {
                cell.image.image = cachedImage
            }
        } else {
            let thumbnailSize = CGSize(width: 1024 * UIScreen.main.scale, height: 1024 * UIScreen.main.scale)

            imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                if cell.representedAssetIdentifier == asset.localIdentifier {
                    DispatchQueue.main.async {
                        cell.image.image = image
                    }
                    ImageCache.shared.setImage(image, forKey: asset.localIdentifier)
                }
            })
        }
        
        if isSelectedPhotos[indexPath.item] == true {
            cell.isSelectedPhoto = true
        } else {
            cell.isSelectedPhoto = false
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if photoSelectStatus == .seletingPhotoStatus {
            guard let cell = collectionView.cellForItem(at: indexPath) as? PhotosCollectionViewCell else {
                return
            }
            
            if cell.isSelectedPhoto == true {
                cell.isSelectedPhoto = false
                isSelectedPhotos[indexPath.item] = false
            } else {
                cell.isSelectedPhoto = true
                isSelectedPhotos[indexPath.item] = true
            }
            
        } else {
            let selectedPhotoViewController = SelectedPhotoViewController()
            selectedPhotoViewController.assets = assets
            selectedPhotoViewController.photoIndex = indexPath.row
            selectedPhotoViewController.albumType = albumType
            selectedPhotoViewController.albumName = albumName
            navigationController?.pushViewController(selectedPhotoViewController, animated: true)
        }
    }
}

extension PhotoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 4 - 1
        let height = width
        let size = CGSize(width: width, height: height)
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension PhotoViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let change = changeInstance.changeDetails(for: assets) else {
            return
        }
        
        assets = change.fetchResultAfterChanges
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name("photoLibraryDidChange"), object: change.fetchResultAfterChanges)
        }
    }
}
