//
//  SelectedPhotoViewController.swift
//  Photoable
//
//  Created by 임채윤 on 2023/02/05.
//

import UIKit
import PhotosUI

class SelectedPhotoViewController: UIViewController {
    var photos = PHFetchResult<PHAsset>()
    var photoIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setToolbar()
        setUILayout()
        configurationCollectionView()
        self.tabBarController?.tabBar.isHidden = true
        PHPhotoLibrary.shared().register(self)
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.photoCollectionView.scrollToItem(at: IndexPath(row: self.photoIndex, section: 0), at: .top, animated: true)
        }
    }
    
    private func configurationCollectionView() {
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        let cellIdentifier = PhotosCollectionViewCell.identifier
        photoCollectionView.register(PhotosCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }
    
    private func setNavigationBar() {
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: nil)
        let photoCreateDateView = PhotoCreateDateView()
        photoCreateDateView.setLabel(date: photos[photoIndex].creationDate)
        self.navigationItem.titleView = photoCreateDateView
        self.navigationItem.rightBarButtonItem = rightButton
        
        let appearence = UINavigationBarAppearance()

        navigationController?.navigationBar.scrollEdgeAppearance = appearence
        navigationController?.isNavigationBarHidden = false
    }

    private func setToolbar() {
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "arrowshape.turn.up.forward"), style: .plain, target: self, action: #selector(tapShareButton))
        let favoriteButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(tapFavoriteButton))
        let deleteButton = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(tapDeleteButton))
        let addPhotoToAlbumButton = UIBarButtonItem(image: UIImage(systemName: "rectangle.stack.badge.plus"), style: .plain, target: self, action: #selector(tapAddPhotoToAlbumButton))
        let fiexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let items = [shareButton, fiexibleSpace, favoriteButton, fiexibleSpace, addPhotoToAlbumButton, fiexibleSpace, deleteButton]
        print("===============================")
        toolbar.setItems(items, animated: true)
    }
    
    @objc private func tapShareButton() {
        
    }
    
    @objc private func tapFavoriteButton() {
        
    }
                                           
    @objc private func tapDeleteButton() {
        let asset: PHAsset = self.photos[photoIndex]
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([asset] as NSArray)
        }, completionHandler: nil)
    }
    
    @objc private func tapAddPhotoToAlbumButton() {
        
    }
    
    var navigationTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        
        return label
    }()
    
    let photoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.isScrollEnabled = true
        collectionView.contentInsetAdjustmentBehavior = .never
        
        return collectionView
    }()
    
    let toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        
        return toolbar
    }()
    
    private func setUILayout() {
        self.view.backgroundColor = .systemBackground
        let views = [photoCollectionView, toolbar]
        
        views.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            photoCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            photoCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photoCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            photoCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

extension SelectedPhotoViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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
        
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFit, options: nil, resultHandler: { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                DispatchQueue.main.async {
                    cell.image.contentMode = .scaleAspectFit
                    cell.image.image = image
                }
            }
        })
        cell.backgroundColor = .blue
        
        return cell
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        photoIndex = Int(targetContentOffset.pointee.x / view.frame.width)
    }

    
    
//    func collectionView
}

extension SelectedPhotoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let height = view.frame.height
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

extension SelectedPhotoViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let change = changeInstance.changeDetails(for: photos) else {
            return
        }
        
        photos = change.fetchResultAfterChanges
        
        OperationQueue.main.addOperation {
            self.photoCollectionView.reloadSections(IndexSet(0...0))
        }
    }
}
