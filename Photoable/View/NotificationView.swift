import UIKit

class NotificationView: UIView {
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUILayout()
        self.backgroundColor = .secondarySystemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUILayout() {
        let views = [messageLabel]
        
        views.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            messageLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            messageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20)
        ])
    }
}
