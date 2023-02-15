import UIKit

class PhotoCreateDateView: UIView {
    var createDateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        
        return label
    }()
    
    var createTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUILayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setLabel(date: Date?) {
        guard let date = date else {
            createDateLabel.text = "날짜를 알 수 없음"
            return
        }
        
        createDateLabel.text = date.dateFormat()
        createTimeLabel.text = date.timeFormat()
    }
    
    private func setUILayout() {
        let views = [createDateLabel, createTimeLabel]
        
        views.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            createDateLabel.topAnchor.constraint(equalTo: self.topAnchor),
            createDateLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            createDateLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            createTimeLabel.topAnchor.constraint(equalTo: createDateLabel.bottomAnchor),
            createTimeLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            createTimeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            createTimeLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
