import UIKit
import Photos

class AlbumViewController: UIViewController {

    var albums = [AlbumModel]()
    var albumEditStatus: AlbumEditStatus = .defaultStatus
    let albumManager = AlbumManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUILayout()
        configurationCollectionView()
        pickPhoto()
        PHPhotoLibrary.shared().register(self)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePhotoLibraryDidChange), name: NSNotification.Name("photoLibraryDidChange"), object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationBar()
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
        self.albums = albumManager.fetchAlbum(userCollection: true, smartCollection: true)
    }
    
    private func setNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationItem.title = "나의 앨범"
//        let settingBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: nil)
        navigationItem.rightBarButtonItems = [editBarButtonItem]
    }
    
    @objc private func handlePhotoLibraryDidChange(notification: Notification) {
        pickPhoto()
        print("AlbumViewController 변경", albums.count)
        self.albumCollectionView.reloadData()
    }
    
    @objc private func tapEditAlbumButton() {
        navigationItem.rightBarButtonItems = [editCompleteBarButtonItem]
        albumEditStatus = .editingStatus
        changeDeleteButtonsShowing()
    }
    
    @objc private func tapEditCompleteButton() {
        navigationItem.rightBarButtonItems = [editBarButtonItem]
        albumEditStatus = .defaultStatus
        changeDeleteButtonsShowing()
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
        
        if let keyWindow = UIApplication.shared.keyWindow {
            keyWindow.addSubview(notificationView)
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
    
    private lazy var editBarButtonItem = UIBarButtonItem(title: "편집", style: .done, target: self, action: #selector(tapEditAlbumButton))
    
    private lazy var editCompleteBarButtonItem = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(tapEditCompleteButton))
    
    let albumCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        return collectionView
    }()
    
    private func changeDeleteButtonsShowing() {
        for index in 0..<albums.count {
            DispatchQueue.main.async {
                if let cell = self.albumCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? AlbumCollectionViewCell {
                    cell.isEditingView = self.albumEditStatus == .editingStatus && self.albums[index].albumType == "userAlbum" ? true : false
                    cell.imageView.layer.opacity = self.albumEditStatus == .editingStatus ? 0.5 : 1
                }
            }
        }
    }
    
    @objc private func deleteAlbum(sender: UIButton) {
        albumManager.deleteAlbum(identifier: albums[sender.tag].identifier) { result in
            switch result {
            case .success(let albumName):
                DispatchQueue.main.async {
                    self.showNotificationView(message: "\(albumName) 앨범 삭제 완료")
                }
                print("\(albumName) 앨범 삭제 완료")
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showNotificationView(message: "앨범 삭제 실패, 오류가 발생했습니다.")
                }
                print("\(error.localizedDescription)")
            }
        }
    }
    
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
            albumCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            albumCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
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
        
        cell.deleteButton.tag = indexPath.item
        cell.deleteButton.addTarget(self, action: #selector(deleteAlbum), for: .touchUpInside)
        cell.isEditingView = self.albumEditStatus == .editingStatus && album.albumType == "userAlbum" ? true : false
        cell.titleLabel.text = album.title
        cell.countLabel.text = "사진 \(album.count)장"
        
        guard let asset = album.asset.firstObject else {
            let emptyAlbumImage = UIImage(systemName: "photo.on.rectangle.angled")?.withRenderingMode(.alwaysTemplate)
            
            cell.imageView.tintColor = .secondaryLabel
            cell.imageView.image = emptyAlbumImage
            cell.imageView.contentMode = .scaleAspectFit
            
            return cell
        }
        
        cell.imageView.contentMode = .scaleAspectFill
        let imageManager = ImageManager()
        
        if let cachedImage = ImageCache.shared.image(forKey: asset.localIdentifier) {
            DispatchQueue.main.async {
                cell.imageView.image = cachedImage
            }
        } else {
            DispatchQueue.main.async {
                imageManager.fetchImage(asset: asset, cellIdentifier: asset.localIdentifier, completion: { image in
                    cell.imageView.image = image
                })
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if albumEditStatus == .editingStatus {
            return
        }
        let assets = self.albums[indexPath.item].asset
        let title = self.albums[indexPath.item].title
        let albumType = self.albums[indexPath.item].albumType
        let albumIdentifier = self.albums[indexPath.item].identifier
        let photoCollectionViewController = PhotoViewController()
        photoCollectionViewController.assets = assets
        photoCollectionViewController.albumName = title
        photoCollectionViewController.albumType = albumType
        photoCollectionViewController.albumIdentifier = albumIdentifier
        navigationController?.pushViewController(photoCollectionViewController, animated: true)
    }
}

extension AlbumViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 2 - 5
        let height = width + 40
        let size = CGSize(width: width, height: height)
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
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
