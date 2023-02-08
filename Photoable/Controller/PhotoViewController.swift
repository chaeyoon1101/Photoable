//
//  ViewController.swift
//  Photoable
//
//  Created by 임채윤 on 2022/12/21.
//

import UIKit
import PhotosUI

class PhotoViewController: UIViewController {

    var photos = PHFetchResult<PHAsset>()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setUILayout()
        configurationCollectionView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getPermissionIfNecessary()
    }
    
    private func getPermissionIfNecessary() {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized, .limited:
            pickPhoto()
            
        case .denied:
            print("======== denied ===========")
            let actions = [
                AlertModel(title: "설정 변경하러 가기", style: .default, handler: { _ in
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }),
                AlertModel(title: "확인", style: .default, handler: { _ in print("확인") })
            ]
            DispatchQueue.main.async {
                self.alert(title: "사진 접근 권한", message: "사진 접근 권한이 거부 되었어요", actions: actions)
            }
            
        case .restricted, .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                switch status {
                case .authorized, .limited:
                    self.pickPhoto()
                case .notDetermined, .restricted:
                    let actions = [
                        AlertModel(title: "설정 변경하러 가기", style: .default, handler: { _ in
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }),
                        AlertModel(title: "확인", style: .default, handler: { _ in print("확인") })
                    ]
                    DispatchQueue.main.async {
                        self.alert(title: "사진 접근 권한", message: "사진 접근 권한이 허용 되지 않았어요", actions: actions)
                    }
                   
                case .denied:
                    let actions = [
                        AlertModel(title: "설정 변경하러 가기", style: .default, handler: { _ in
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }),
                        AlertModel(title: "확인", style: .default, handler: { _ in print("확인") })
                    ]
                    DispatchQueue.main.async {
                        self.alert(title: "사진 접근 권한", message: "사진 접근 권한이 거부 되었어요", actions: actions)
                    }
                
                @unknown default:
                    break
                }
            }
        @unknown default:
            break
        }
    }
    
    private func pickPhoto() {
        let allPhotosOptions = PHFetchOptions()
        
        allPhotosOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        self.photos = PHAsset.fetchAssets(with: allPhotosOptions)
        
        self.photoCollectionView.reloadData()
    }

    private func configurationCollectionView() {
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        let cellIdentifier = PhotosCollectionViewCell.identifier
        photoCollectionView.register(PhotosCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }
    
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
        print("=========== Photos Count == \(photos.count) =================")
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = PhotosCollectionViewCell.identifier
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? PhotosCollectionViewCell else {
            return UICollectionViewCell()
        }

        let imageManager = PHCachingImageManager()
        let asset = self.photos[indexPath.item]
        let thumbnailSize = CGSize(width: 1024 * UIScreen.main.scale, height: 1024 * UIScreen.main.scale)
        cell.representedAssetIdentifier = asset.localIdentifier
        
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                DispatchQueue.main.async {
                    cell.image.image = image
                }
            }
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPhotoViewController = SelectedPhotoViewController()
        selectedPhotoViewController.photos = photos
        selectedPhotoViewController.photoIndex = indexPath.row
        
        selectedPhotoViewController.modalPresentationStyle = .fullScreen
        present(selectedPhotoViewController, animated: true)
//        navigationController?.pushViewController(selectedPhotoViewController, animated: true)
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

extension PhotoViewController {
    private func alert(title: String, message: String, actions: [AlertModel] = []) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { action in
            alert.addAction(UIAlertAction(title: action.title, style: action.style, handler: action.handler))
        }
        
        present(alert, animated: true)
    }
}
