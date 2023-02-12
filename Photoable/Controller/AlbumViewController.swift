import UIKit
import Photos

class AlbumViewController: UIViewController {

    var albums = [AlbumModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "나의 앨범"
        setUILayout()
        configurationCollectionView()
        pickPhoto()
        // Do any additional setup after loading the view.
    }
    
    private func pickPhoto() {
        let userCollections = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .any,
            options: nil)
        
        userCollections.enumerateObjects { collection, index, stop in
            if collection.estimatedAssetCount > 0 {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [
                    NSSortDescriptor(key: "creationDate", ascending: false)
                ]
                fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                
                let assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                if let title = collection.localizedTitle, assets.count > 0 {
                    switch title {
                    case "Recents":
                        self.albums.append(AlbumModel(asset: assets, title: "모든 사진", count: assets.count))
                    case "Favorites":
                        self.albums.append(AlbumModel(asset: assets, title: "내가 좋아하는 사진", count: assets.count))
                    case "Hidden":
                        self.albums.append(AlbumModel(asset: assets, title: "숨겨진 사진", count: assets.count))
                    default:
                        break
                    }
                }
                
            }
        }
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
        
        let imageManager = PHCachingImageManager()
        let album = self.albums[indexPath.item]
        
        guard let asset = album.asset.firstObject else {
            return UICollectionViewCell()
        }
        
        let thumbnailSize = CGSize(width: 1024 * UIScreen.main.scale, height: 1024 * UIScreen.main.scale)
        cell.representedAssetIdentifier = asset.localIdentifier
        
        if let cachedImage = ImageCache.shared.image(forKey: asset.localIdentifier) {
            DispatchQueue.main.async {
                cell.image.image = cachedImage
            }
        } else {
            imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                if cell.representedAssetIdentifier == asset.localIdentifier {
                    DispatchQueue.main.async {
                        cell.image.image = image
                        ImageCache.shared.setImage(image, forKey: asset.localIdentifier)
                    }
                }
            })
        }
        cell.titleLabel.text = album.title
        cell.countLabel.text = "사진 \(album.count)장"
        
        return cell
    }
}

extension AlbumViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 2 - 20
        let height = width + 40
        let size = CGSize(width: width, height: height)
        
        return size
    }
    
}
