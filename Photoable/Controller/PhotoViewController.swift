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
    var albumIdentifier: String?
    var albumName: String?
    var albumType: String?
    var photoSelectStatus: PhotoSelectStatus = .defaultStatus
    var isSelectedPhotos: [Bool] = []
    let imageManager = PHCachingImageManager()
    var selectedPhotoIdentifiers = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUILayout()
        configurationCollectionView()
        setToolbar()
        isSelectedPhotos = [Bool](repeating: false, count: assets.count)
        navigationItem.rightBarButtonItem = selectPhotoButtonItem
        PHPhotoLibrary.shared().register(self)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePhotoLibraryDidChange), name: NSNotification.Name("photoLibraryDidChange"), object: nil)
        moreButtonMenu = UIMenu(children: [
            UIAction(title: "삭제하기", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.deletePhotos()
            },
            UIAction(title: "앨범에 추가하기", image: UIImage(systemName: "rectangle.stack.badge.plus")) { _ in
                self.addPhotoToAlbum()
            }
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        navigationItem.title = albumName
        photoCollectionView.reloadData()
    }
    
    @objc private func selectPhotosStatus() {
        photoSelectStatus = .seletingPhotoStatus
        isSelectedPhotos = [Bool](repeating: false, count: assets.count + 1)
        DispatchQueue.main.async { [self] in
            navigationItem.rightBarButtonItem = cancleSelectPhotoButtonItem
            toolbar.isHidden = false
        }
    }
    
    @objc private func cancleSelectStatus() {
        DispatchQueue.main.async { [self] in
            navigationItem.rightBarButtonItem = selectPhotoButtonItem
            toolbar.isHidden = true
        }
        photoSelectStatus = .defaultStatus
        deselectAllPhoto()
    }
    
    @objc private func handlePhotoLibraryDidChange(notification: Notification) {
        print("photoViewController 변경")
        self.photoCollectionView.reloadData()
    }
    
    @objc private func tapMoreButton() {
        
    }
    
    private func addPhotoToAlbum() {
        let addPhotoToAlbumViewController = AddPhotoToAlbumViewController()
        addPhotoToAlbumViewController.assetIdentifiers = selectedPhotoIdentifiers
        self.cancleSelectStatus()
        self.present(addPhotoToAlbumViewController, animated: true)
    }
    
    private func deletePhotos() {
        var actions = [AlertModel]()
        let imageManager = ImageManager()
        let albumManager = AlbumManager()
        
        if albumType == "userAlbum" {
            actions.append(AlertModel(title: "앨범에서 제거", style: .default, handler: { [self] _ in
                albumManager.removeImages(assetIdentifiers: selectedPhotoIdentifiers, toAlbum: albumName ?? "이름 없음") { result in
                    switch result {
                    case .success((let albumName, let deletedImageCount)):
                        print("사진 \(deletedImageCount)장 \(albumName) 앨범에서 삭제 완료")
                    case .failure(let error):
                        print(error)
                    }
                    self.cancleSelectStatus()
                }
            }))
        }
        
        actions.append(AlertModel(title: "영구적으로 삭제", style: .destructive, handler: { [self] _ in
            imageManager.deleteImages(assetIdentifiers: selectedPhotoIdentifiers) { result in
                switch result {
                case .success(let deletedImageCount):
                    print("사진 \(deletedImageCount)장 삭제 완료")
                case .failure(let error):
                    print(error.localizedDescription)
                }
                self.cancleSelectStatus()
            }
        }))
        
        actions.append(AlertModel(title: "취소", style: .cancel, handler: { _ in
            print("취소")
        }))
        
        alert(title: "이 사진을 영구적으로 삭제하시겠습니까? \(albumType == "userAlbum" ? "아니면 이 앨범에서 제거하시겠습니까?" : "")", message: "", actions: actions)
    }
    
    private func deselectAllPhoto() {
        for index in 0..<assets.count {
            DispatchQueue.main.async {
                if let cell = self.photoCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? PhotosCollectionViewCell {
                    cell.isSelectedPhoto = false
                }
                self.isSelectedPhotos[index] = false
            }
        }
        photoSelectStatus = .defaultStatus
        selectedPhotoIdentifiers = []
        DispatchQueue.main.async {
            self.setToolbar()
        }
    }
    
    private func configurationCollectionView() {
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        let cellIdentifier = PhotosCollectionViewCell.identifier
        photoCollectionView.register(PhotosCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }
    
    private func setToolbar() {
        let moreButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: moreButtonMenu)
        
        if selectedPhotoIdentifiers.count == 0 {
            
            self.toolBarTitleLabel.text = "사진 선택"
            
            moreButton.isEnabled = false
        } else {
            
            self.toolBarTitleLabel.text = "\(self.selectedPhotoIdentifiers.count)장의 사진이 선택됨"
            
            moreButton.isEnabled = true
        }
        
        let titleView = UIBarButtonItem(customView: toolBarTitleLabel)
        let fiexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let items = [fiexibleSpace, titleView, fiexibleSpace, moreButton]
        
        
        self.toolbar.setItems(items, animated: true)
    }
    
    private lazy var selectPhotoButtonItem = UIBarButtonItem(title: "사진 선택", style: .done, target: self, action: #selector(selectPhotosStatus))
    
    private lazy var cancleSelectPhotoButtonItem = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(cancleSelectStatus))
    
    var moreButtonMenu: UIMenu = {
        let menu = UIMenu()
        
        return menu
    }()
    
    let toolBarTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "1장의 사진이 선택 됨"
        label.textAlignment = .center
        
        return label
    }()
    
    let photoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        return collectionView
    }()
    
    let toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.isHidden = true
        
        return toolbar
    }()
    
    private func setUILayout() {
        let views = [photoCollectionView, toolbar]
        
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
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
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
            selectedPhotoIdentifiers = []
            
            if cell.isSelectedPhoto == true {
                cell.isSelectedPhoto = false
                isSelectedPhotos[indexPath.item] = false
            } else {
                cell.isSelectedPhoto = true
                isSelectedPhotos[indexPath.item] = true
            }
            
            for index in 0..<isSelectedPhotos.count {
                if isSelectedPhotos[index] == true {
                    selectedPhotoIdentifiers.append(assets[index].localIdentifier)
                }
            }
            setToolbar()
            
        } else {
            let selectedPhotoViewController = SelectedPhotoViewController()
            selectedPhotoViewController.assets = assets
            selectedPhotoViewController.photoIndex = indexPath.row
            selectedPhotoViewController.albumType = albumType
            selectedPhotoViewController.albumName = albumName
            selectedPhotoViewController.albumIdentifier = albumIdentifier
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

extension PhotoViewController {
    private func alert(title: String, message: String, actions: [AlertModel] = []) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        actions.forEach { action in
            alert.addAction(UIAlertAction(title: action.title, style: action.style, handler: action.handler))
        }
        
        present(alert, animated: true)
    }
}
