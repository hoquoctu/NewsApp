import UIKit

class LoginScreen: UIView {
    
    // MARK: - UI Components
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "NewsFlow"
        label.font = .systemFont(ofSize: 36, weight: .heavy)
        label.textColor = .systemBlue
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Đăng nhập để đọc báo và lưu bài viết"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.borderStyle = .roundedRect
        tf.backgroundColor = .systemGray6
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Mật khẩu"
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.backgroundColor = .systemGray6
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Đăng nhập", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemBlue
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let registerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Chưa có tài khoản? Đăng ký ngay", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let forgotPasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Quên mật khẩu?", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.contentHorizontalAlignment = .right
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .white
        
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(emailTextField)
        addSubview(passwordTextField)
        addSubview(loginButton)
        addSubview(registerButton)
        addSubview(forgotPasswordButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            emailTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 50),
            emailTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            emailTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            passwordTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            forgotPasswordButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 8),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            forgotPasswordButton.heightAnchor.constraint(equalToConstant: 30),
            
            loginButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 20),
            loginButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            loginButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            registerButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
