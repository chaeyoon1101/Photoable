import UIKit
import Photos

class AlbumViewController: UIViewController {

    var albums = [AlbumModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUILayout()
        configurationCollectionView()
        pickPhoto()
        NotificationCenter.default.addObserver(self, selector: #selector(handlePhotoLibraryDidChange), name: NSNotification.Name("photoLibraryDidChange"), object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationItem.title = "나의 앨범"
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
        let albumManager = AlbumManager()
        self.albums = albumManager.fetchAlbum(userCollection: true, smartCollection: true)
    }
    
    @objc private func handlePhotoLibraryDidChange(notification: Notification) {
        pickPhoto()
        print("AlbumViewController 변경", albums.count)
        self.albumCollectionView.reloadData()
    }
    
    let albumCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        return collectionView
    }()
    
    private func configurationCollectionView() {
        albumCollectionView.delegate = self
        albumCollectionView.dataSource = self
        let cellIdentifier = AlbumCollectionViewCell.identifier
        albumCollectionView.register(AlbumCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }
    
    private func setUILayout() {
        let views = [albumCollectionView]
        
        views.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
        
        print("====== Set UI layout ======")
        NSLayoutConstraint.activate([
            albumCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            albumCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            albumCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            albumCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
        ])
    }
}

extension AlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = AlbumCollectionViewCell.identifier
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? AlbumCollectionViewCell else {
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
        let assets = self.albums[indexPath.item].asset
        let title = self.albums[indexPath.item].title
        let photoCollectionViewController = PhotoViewController()
        photoCollectionViewController.assets = assets
        photoCollectionViewController.albumTitle = title
        navigationController?.pushViewController(photoCollectionViewController, animated: true)
    }
}

extension AlbumViewController: UICollectionViewDelegateFlowLayout {
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

extension AlbumViewController {
    private func alert(title: String, message: String, actions: [AlertModel] = []) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { action in
            alert.addAction(UIAlertAction(title: action.title, style: action.style, handler: action.handler))
        }
        
        present(alert, animated: true)
    }
}

extension AlbumViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name("photoLibraryDidChange"), object: nil)
        }
    }
}
