import UIKit

class ProfileScreen: UIView {
    
    let headerView: UIView = {
        let view = UIView()
        // Premium blue gradient or color
        view.backgroundColor = UIColor(red: 0.12, green: 0.35, blue: 0.75, alpha: 1.0)
        view.layer.cornerRadius = 30
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.crop.circle.fill")
        iv.tintColor = .systemGray4
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .white
        iv.layer.cornerRadius = 55
        iv.clipsToBounds = true
        iv.layer.borderWidth = 4
        iv.layer.borderColor = UIColor.white.cgColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let infoCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emailIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "envelope.fill"))
        iv.tintColor = UIColor(red: 0.12, green: 0.35, blue: 0.75, alpha: 1.0)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let phoneIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "phone.fill"))
        iv.tintColor = UIColor(red: 0.12, green: 0.35, blue: 0.75, alpha: 1.0)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let phoneLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let logoutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Đăng xuất", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0)
        btn.layer.cornerRadius = 16
        btn.layer.shadowColor = UIColor.red.cgColor
        btn.layer.shadowOpacity = 0.2
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowRadius = 8
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        backgroundColor = UIColor(white: 0.96, alpha: 1.0) // Light gray background
        
        addSubview(headerView)
        addSubview(infoCard)
        addSubview(avatarImageView)
        
        infoCard.addSubview(nameLabel)
        infoCard.addSubview(emailIcon)
        infoCard.addSubview(emailLabel)
        infoCard.addSubview(phoneIcon)
        infoCard.addSubview(phoneLabel)
        
        addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            // Header View
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 240),
            
            // Info Card
            infoCard.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -50),
            infoCard.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            infoCard.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            infoCard.heightAnchor.constraint(equalToConstant: 220),
            
            // Avatar (overlapping header and card)
            avatarImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: infoCard.topAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 110),
            avatarImageView.heightAnchor.constraint(equalToConstant: 110),
            
            // Name Label
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),
            
            // Email
            emailIcon.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 30),
            emailIcon.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 24),
            emailIcon.widthAnchor.constraint(equalToConstant: 22),
            emailIcon.heightAnchor.constraint(equalToConstant: 22),
            
            emailLabel.centerYAnchor.constraint(equalTo: emailIcon.centerYAnchor),
            emailLabel.leadingAnchor.constraint(equalTo: emailIcon.trailingAnchor, constant: 16),
            emailLabel.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -24),
            
            // Phone
            phoneIcon.topAnchor.constraint(equalTo: emailIcon.bottomAnchor, constant: 20),
            phoneIcon.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 24),
            phoneIcon.widthAnchor.constraint(equalToConstant: 22),
            phoneIcon.heightAnchor.constraint(equalToConstant: 22),
            
            phoneLabel.centerYAnchor.constraint(equalTo: phoneIcon.centerYAnchor),
            phoneLabel.leadingAnchor.constraint(equalTo: phoneIcon.trailingAnchor, constant: 16),
            phoneLabel.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -24),
            
            // Logout Button
            logoutButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -40),
            logoutButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            logoutButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            logoutButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
}
