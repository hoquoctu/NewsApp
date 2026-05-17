import UIKit

class CategoryCell: UICollectionViewCell {
    static let identifier = "CategoryCell"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 1.5
        contentView.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure(with category: Category, isSelected: Bool) {
        titleLabel.text = category.name
        
        if isSelected {
            contentView.backgroundColor = UIColor(red: 1.0, green: 0.54, blue: 0.0, alpha: 1.0) // Orange 400
            contentView.layer.borderColor = UIColor(red: 1.0, green: 0.54, blue: 0.0, alpha: 1.0).cgColor
            titleLabel.textColor = .white
        } else {
            contentView.backgroundColor = .white
            contentView.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
            titleLabel.textColor = .darkGray
        }
    }
}
