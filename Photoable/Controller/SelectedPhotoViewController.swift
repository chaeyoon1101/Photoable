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
        setUILayout()
        configurationCollectionView()
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
//        print(navigationController?.navigationBar.frame.size)
        navigationController?.isNavigationBarHidden = false
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
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.isScrollEnabled = true
        collectionView.backgroundColor = .gray
        
        return collectionView
    }()
    
    private func setUILayout() {
        self.view.backgroundColor = .systemBackground
        let views = [photoCollectionView]
        
        views.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
        NSLayoutConstraint.activate([
            photoCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            photoCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photoCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            photoCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension SelectedPhotoViewController: UICollectionViewDataSource {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }

    
    
//    func collectionView
}

extension SelectedPhotoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = collectionView.frame.height
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


