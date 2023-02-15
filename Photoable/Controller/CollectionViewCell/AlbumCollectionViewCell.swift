import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    static let identifier = "AlbumCollectionViewCell"
    var representedAssetIdentifier: String?
    
    var isEditingView: Bool? {
        didSet {
            if isEditingView == true {
                deleteButton.isHidden = false
                imageView.layer.opacity = 0.5
            } else {
                deleteButton.isHidden = true
                imageView.layer.opacity = 1
            }
        }
    }
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        imageView.layer.backgroundColor = UIColor.secondarySystemBackground.cgColor
        
        imageView.layer.cornerRadius = 10
        
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 2
        
        return label
    }()
    
    let countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        
        return label
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .light)
        
        button.setImage(UIImage(systemName: "minus.circle.fill", withConfiguration: imageConfig), for: .normal)
        button.tintColor = .red
        button.isHidden = true
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isEditingView = false
        self.setUILayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUILayout() {
        let views = [imageView, titleLabel, countLabel, deleteButton]
        
        views.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -50),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
            countLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            countLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            countLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
            deleteButton.topAnchor.constraint(equalTo: self.imageView.topAnchor, constant: -10),
            deleteButton.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor, constant: -10)
        ])
    }
}
