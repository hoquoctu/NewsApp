import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    private let loginScreen = LoginScreen()
    
    override func loadView() {
        view = loginScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
    }
    
    private func setupActions() {
        loginScreen.loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        loginScreen.registerButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
    }
    
    @objc private func handleLogin() {
        guard let email = loginScreen.emailTextField.text, !email.isEmpty,
              let password = loginScreen.passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Lỗi", message: "Vui lòng nhập đầy đủ email và mật khẩu.")
            return
        }
        
        loginScreen.loginButton.setTitle("Đang đăng nhập...", for: .normal)
        loginScreen.loginButton.isEnabled = false
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.loginScreen.loginButton.setTitle("Đăng nhập", for: .normal)
                self?.loginScreen.loginButton.isEnabled = true
                
                if let error = error {
                    self?.showAlert(title: "Đăng nhập thất bại", message: error.localizedDescription)
                    return
                }
                
                // Chuyển sang TabBar
                let tabBar = MainTabBarController()
                tabBar.modalPresentationStyle = .fullScreen
                self?.present(tabBar, animated: true)
            }
        }
    }
    
    @objc private func handleRegister() {
        let registerVC = RegisterViewController()
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
