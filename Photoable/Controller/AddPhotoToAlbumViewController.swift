//
//  AddPhotoToAlbumViewController.swift
//  Photoable
//
//  Created by 임채윤 on 2023/02/13.
//

import UIKit
import Photos

class AddPhotoToAlbumViewController: UIViewController {
    
    var albums = [AlbumModel]()
    var assetIdentifiers = [String]()
    let albumManager = AlbumManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUILayout()
        configurationCollectionView()
        fetchAlbum()
        PHPhotoLibrary.shared().register(self)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePhotoLibraryDidChange), name: NSNotification.Name("photoLibraryDidChange"), object: nil)
        self.view.backgroundColor = .systemBackground
        // Do any additional setup after loading the view.
    }
    
    private func fetchAlbum() {
        self.albums = albumManager.fetchAlbum(userCollection: true, smartCollection: false)
    }
    
    @objc private func dismissViewController() {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
        
    }
    
    @objc private func handlePhotoLibraryDidChange(notification: Notification) {
        fetchAlbum()
        print("AlbumViewController 변경", albums.count)
        self.albumCollectionView.reloadData()
    }
    
    @objc private func tapCreateAlbumButton() {
        let alert = UIAlertController(title: "새로운 앨범", message: "앨범의 이름을 입력해주세요", preferredStyle: .alert)
        let cancleAction = UIAlertAction(title: "취소", style: .default, handler: nil)
        let createAction = UIAlertAction(title: "생성", style: .default, handler: { action in
            let albumName = alert.textFields?[0].text ?? ""
            self.createAlbum(albumName: albumName)
            
        })
        
        alert.addTextField { (inputNewNickName) in
            inputNewNickName.placeholder = "앨범 이름"
        }
        alert.addAction(cancleAction)
        alert.addAction(createAction)
        present(alert,animated: true,completion: nil)
    }
    
    
    private func createAlbum(albumName: String) {
        albumManager.createAlbum(albumName) { result in
            switch result {
            case .success(let albumName):
                print("\(albumName) 앨범 삭제 완료")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    private func configurationCollectionView() {
        albumCollectionView.delegate = self
        albumCollectionView.dataSource = self
        let cellIdentifier = AddPhotoToAlbumCollectionViewCell.identifier
        albumCollectionView.register(AddPhotoToAlbumCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }
    
    private lazy var navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar(frame: .zero)
        let navigationItem = UINavigationItem(title: "앨범에 추가")
        let rightItem = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(dismissViewController))
        let leftItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(tapCreateAlbumButton))
        
        navigationBar.pushItem(navigationItem, animated: false)
        navigationBar.topItem?.rightBarButtonItem = rightItem
        navigationBar.topItem?.leftBarButtonItem = leftItem
        
        return navigationBar
    }()

    let albumCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        return collectionView
    }()
    

    
    private func setUILayout() {
        let views = [navigationBar, albumCollectionView]
        
        views.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
        
        print("====== Set UI layout ======")
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            albumCollectionView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 20),
            albumCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            albumCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            albumCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)
        ])
    }
}

extension AddPhotoToAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = AddPhotoToAlbumCollectionViewCell.identifier
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? AddPhotoToAlbumCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let album = self.albums[indexPath.item]
        
        cell.titleLabel.text = album.title
        cell.countLabel.text = "사진 \(album.count)장"
        
        guard let asset = album.asset.firstObject else {
            let emptyAlbumImage = UIImage(systemName: "photo.on.rectangle.angled")?.withRenderingMode(.alwaysTemplate)
            
            cell.image.tintColor = .secondaryLabel
            cell.image.image = emptyAlbumImage
            cell.image.contentMode = .scaleAspectFit
            
            return cell
        }
        
        cell.image.contentMode = .scaleAspectFill
        
        let imageManager = ImageManager()
        
        if let cachedImage = ImageCache.shared.image(forKey: asset.localIdentifier) {
            DispatchQueue.main.async {
                cell.image.image = cachedImage
            }
        } else {
            DispatchQueue.main.async {
                imageManager.fetchImage(asset: asset, cellIdentifier: asset.localIdentifier, completion: { image in
                    cell.image.image = image
                })
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(assetIdentifiers)
        albumManager.addImages(assetIdentifiers: assetIdentifiers, toAlbum: albums[indexPath.item].identifier) { result in
            switch result {
            case .success((let albumName, let imageCount)):
                self.dismissViewController()
                print("\(albumName) 앨범에 사진 \(imageCount)장 추가")
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension AddPhotoToAlbumViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 2 - 20
        let height = width + 40
        let size = CGSize(width: width, height: height)
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
}

extension AddPhotoToAlbumViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name("photoLibraryDidChange"), object: nil)
        }
    }
}

