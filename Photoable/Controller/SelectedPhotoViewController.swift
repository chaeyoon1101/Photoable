//
//  SelectedPhotoViewController.swift
//  Photoable
//
//  Created by 임채윤 on 2023/02/05.
//

import UIKit
import PhotosUI

class SelectedPhotoViewController: UIViewController {
    var assets = PHFetchResult<PHAsset>()
    var photoIndex = 0
    var albumIdentifier: String?
    var albumType: String?
    var albumName: String?
    let imageManager = PHCachingImageManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setToolbar(isFavorite: assets[photoIndex].isFavorite)
        setUILayout()
        configurationCollectionView()
        PHPhotoLibrary.shared().register(self)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(handlePhotoLibraryDidChange), name: NSNotification.Name("photoLibraryDidChange"), object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        DispatchQueue.main.async { [self] in
            self.photoCollectionView.scrollToItem(at: IndexPath(item: photoIndex, section: 0), at: .left, animated: false)
        }
        photoCollectionView.reloadData()
    }
    
    private func configurationCollectionView() {
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        let cellIdentifier = SelectedPhotosCollectionViewCell.identifier
        photoCollectionView.register(SelectedPhotosCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }
    
    private func setNavigationBar() {
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: nil)
        let photoCreateDateView = PhotoCreateDateView()
        photoCreateDateView.setLabel(date: assets[photoIndex].creationDate)
        self.navigationItem.titleView = photoCreateDateView
        self.navigationItem.rightBarButtonItem = rightButton
        
        let appearence = UINavigationBarAppearance()

        navigationController?.navigationBar.scrollEdgeAppearance = appearence
        navigationController?.isNavigationBarHidden = false
    }

    private func setToolbar(isFavorite: Bool) {
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "arrowshape.turn.up.forward"), style: .plain, target: self, action: #selector(tapShareButton))
        let favoriteButton = UIBarButtonItem(image: UIImage(systemName: isFavorite ? "heart.fill" : "heart"), style: .plain, target: self, action: #selector(tapFavoriteButton))
        let deleteButton = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(tapDeleteButton))
        let addPhotoToAlbumButton = UIBarButtonItem(image: UIImage(systemName: "rectangle.stack.badge.plus"), style: .plain, target: self, action: #selector(tapAddPhotoToAlbumButton))
        let fiexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let items = [shareButton, fiexibleSpace, favoriteButton, fiexibleSpace, addPhotoToAlbumButton, fiexibleSpace, deleteButton]
        
        toolbar.setItems(items, animated: true)
    }
    
    @objc func removeNotificationView(sender: UIGestureRecognizer) {
        guard let notificationView = sender.view else {
            return
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            notificationView.frame.origin.y -= 100
        })
    }
    
    private func showNotificationView(message: String) {
        let notificationView = NotificationView()
        notificationView.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: 100)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeNotificationView))
        notificationView.addGestureRecognizer(tapGesture)
        
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            let windows = windowScene.windows
            if let window = windows.first {
                window.addSubview(notificationView)
            }
        }
        
        notificationView.messageLabel.text = message
        
        UIView.animate(withDuration: 0.5, animations: {
            notificationView.frame.origin.y += 100
        })
            
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            UIView.animate(withDuration: 0.5, animations: {
                notificationView.frame.origin.y -= 100
            }, completion: { _ in
                notificationView.removeFromSuperview()
            })
        }
    }
    
    @objc private func tapShareButton() {
        
    }
    
    @objc private func tapFavoriteButton() {
        let isFavoritePhoto = self.assets[photoIndex].isFavorite
        PHPhotoLibrary.shared().performChanges({ [self] in
            let asset = self.assets[photoIndex]
            let changeRequest = PHAssetChangeRequest(for: asset)
            
            if isFavoritePhoto {
                changeRequest.isFavorite = false
            } else {
                changeRequest.isFavorite = true
            }
        }, completionHandler: { (_, error) in
            DispatchQueue.main.async {
                self.setToolbar(isFavorite: !isFavoritePhoto)
            }
            if let error = error {
                print("Error changing favorite: \(error.localizedDescription)")
            }
        })
    }
                                           
    @objc private func tapDeleteButton() {
        var actions = [AlertModel]()
        let imageManager = ImageManager()
        let albumManager = AlbumManager()
        let assetIdentifiers = [assets[photoIndex].localIdentifier]
        
        if albumType == "userAlbum" {
            actions.append(AlertModel(title: "앨범에서 제거", style: .default, handler: { [self] _ in
                albumManager.removeImages(assetIdentifiers: assetIdentifiers, toAlbum: albumIdentifier ?? "") { result in
                    switch result {
                    case .success((let albumName, let deletedImageCount)):
                        print("사진 \(deletedImageCount)장 \(albumName) 앨범에서 삭제 완료")
                        DispatchQueue.main.async {
                            self.showNotificationView(message: "사진 \(deletedImageCount)장 \(albumName) 앨범에서 삭제 완료")
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self.showNotificationView(message: "사진 삭제 실패, 오류가 발생했습니다.")
                        }
                        print(error)
                    }
                }
            }))
        }
        
        actions.append(AlertModel(title: "영구적으로 삭제", style: .destructive, handler: {_ in
            imageManager.deleteImages(assetIdentifiers: assetIdentifiers) { result in
                switch result {
                case .success(let deletedImageCount):
                    print("사진 \(deletedImageCount)장 삭제 완료")
                    DispatchQueue.main.async {
                        self.showNotificationView(message: "사진 \(deletedImageCount)장 삭제 완료")
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.showNotificationView(message: "사진 삭제 실패, 오류가 발생했습니다.")
                    }
                    print(error.localizedDescription)
                }
            }
        }))
        
        actions.append(AlertModel(title: "취소", style: .cancel, handler: { _ in
            print("취소")
        }))
        
        alert(title: "이 사진을 영구적으로 삭제하시겠습니까? \(albumType == "userAlbum" ? "아니면 이 앨범에서 제거하시겠습니까?" : "")", message: "", actions: actions)
    }
    
    @objc private func tapAddPhotoToAlbumButton() {
        let addPhotoToAlbumViewController = AddPhotoToAlbumViewController()
        
        addPhotoToAlbumViewController.assetIdentifiers = [assets[photoIndex].localIdentifier]
        self.present(addPhotoToAlbumViewController, animated: true)
    }
    
    @objc private func dismissViewController() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handlePhotoLibraryDidChange(notification: Notification) { print("SelectedViewController 변경")

        self.photoCollectionView.reloadData()
    }
    
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
            toolbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
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
}

extension SelectedPhotoViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = SelectedPhotosCollectionViewCell.identifier
        let asset = self.assets[indexPath.item]
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? SelectedPhotosCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.imageView.contentMode = .scaleAspectFit
        
        cell.representedAssetIdentifier = asset.localIdentifier
        
        if let cachedImage = ImageCache.shared.image(forKey: asset.localIdentifier) {
            DispatchQueue.main.async {
                cell.imageView.image = cachedImage
            }
        } else {
            let thumbnailSize = CGSize(width: 1024 * UIScreen.main.scale, height: 1024 * UIScreen.main.scale)

            imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                if cell.representedAssetIdentifier == asset.localIdentifier {
                    DispatchQueue.main.async {
                        cell.imageView.image = image
                    }
                    ImageCache.shared.setImage(image, forKey: asset.localIdentifier)
                }
            })
        }
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissViewController))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        cell.addGestureRecognizer(swipeDown)
        
        return cell
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        photoIndex = Int(targetContentOffset.pointee.x / view.frame.width)
        setToolbar(isFavorite: assets[photoIndex].isFavorite)
        self.setNavigationBar()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceIndexPath = IndexPath(item: 0, section: 0)
        let destinationIndexPath = IndexPath(item: photoIndex, section: 0)
        
        collectionView.performBatchUpdates {
            collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath )
        }
    }
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
        guard let change = changeInstance.changeDetails(for: assets) else {
            return
        }
        
        assets = change.fetchResultAfterChanges
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name("photoLibraryDidChange"), object: change.fetchResultAfterChanges)
        }
    }
}

extension SelectedPhotoViewController {
    private func alert(title: String, message: String, actions: [AlertModel] = []) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        actions.forEach { action in
            alert.addAction(UIAlertAction(title: action.title, style: action.style, handler: action.handler))
        }
        
        present(alert, animated: true)
    }
}
