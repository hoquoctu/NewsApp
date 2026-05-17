import UIKit

class ArticleCell: UITableViewCell {
    
    static let identifier = "ArticleCell"
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.06
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let articleImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 12
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = UIColor(red: 0.22, green: 0.54, blue: 0.87, alpha: 1.0) // Blue 400
        label.backgroundColor = UIColor(red: 0.9, green: 0.95, blue: 0.98, alpha: 1.0) // Blue 50
        label.layer.cornerRadius = 6
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(articleImageView)
        containerView.addSubview(categoryLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            articleImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            articleImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            articleImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -14),
            articleImageView.widthAnchor.constraint(equalToConstant: 100),
            articleImageView.heightAnchor.constraint(equalToConstant: 100),
            
            categoryLabel.topAnchor.constraint(equalTo: articleImageView.topAnchor),
            categoryLabel.leadingAnchor.constraint(equalTo: articleImageView.trailingAnchor, constant: 12),
            // Padding around text
            categoryLabel.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: articleImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            
            timeLabel.bottomAnchor.constraint(equalTo: articleImageView.bottomAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: articleImageView.trailingAnchor, constant: 12)
        ])
    }
    
    // MARK: - Configuration
    func configure(with article: Article) {
        titleLabel.text = article.title
        categoryLabel.text = "  \(article.categoryName.uppercased())  "
        timeLabel.text = "⏱ \(article.readingTime) min read"
        
        // Load image using native extension
        articleImageView.loadImage(from: article.thumbnailUrl)
    }
}
