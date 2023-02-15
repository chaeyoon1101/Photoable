import UIKit

class PhotosCollectionViewCell: UICollectionViewCell {
    static let identifier = "PhotosCollectionViewCell"
    var representedAssetIdentifier: String?
    
    var isSelectedPhoto: Bool? {
        didSet {
            if isSelectedPhoto == true {
                selectMark.isHidden = false
                imageView.layer.opacity = 0.5
            } else {
                selectMark.isHidden = true
                imageView.layer.opacity = 1
            }
        }
    }
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.backgroundColor = UIColor.systemBackground.cgColor
        
        return imageView
    }()
    
    let selectMark: UIImageView = {
        let imageView = UIImageView()
        imageView.frame.size = CGSize(width: 20, height: 20)
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.clipsToBounds = true
        imageView.isHidden = true
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUILayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUILayout() {
        let views = [imageView, selectMark]
        
        views.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            selectMark.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            selectMark.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
        ])
    }
}
